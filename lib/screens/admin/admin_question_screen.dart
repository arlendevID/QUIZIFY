import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../services/api/quiz_api.dart';

class AdminQuestionScreen extends StatefulWidget {
  const AdminQuestionScreen({super.key});

  @override
  State<AdminQuestionScreen> createState() => _AdminQuestionScreenState();
}

class _AdminQuestionScreenState extends State<AdminQuestionScreen> {
  bool _hasLoadedArguments = false;
  int? _quizTemplateId;
  String _quizTitle = 'Quiz';
  late Future<List<dynamic>> _questionsFuture;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_hasLoadedArguments) {
      return;
    }

    final arguments = ModalRoute.of(context)?.settings.arguments;

    if (arguments is Map<String, dynamic>) {
      _quizTemplateId = int.tryParse('${arguments['quizTemplateId']}');
      _quizTitle = arguments['quizTitle']?.toString() ?? _quizTitle;
    }

    _questionsFuture = _quizTemplateId == null
        ? Future<List<dynamic>>.value([])
        : QuizApi.getQuestionsByTemplate(_quizTemplateId!);
    _hasLoadedArguments = true;
  }

  void _refreshQuestions() {
    final templateId = _quizTemplateId;
    if (templateId == null) {
      return;
    }

    setState(() {
      _questionsFuture = QuizApi.getQuestionsByTemplate(templateId);
    });
  }

  Future<void> _openForm({Map<String, dynamic>? question}) async {
    final templateId = _quizTemplateId;
    if (templateId == null) {
      return;
    }

    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => _QuestionFormDialog(
        quizTemplateId: templateId,
        question: question,
        onSubmit: (payload) async {
          if (question == null) {
            await QuizApi.createTemplateQuestion(payload);
          } else {
            await QuizApi.updateTemplateQuestion(
              question['id'] as int,
              payload,
            );
          }
        },
      ),
    );

    if (saved == true && mounted) {
      _refreshQuestions();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            question == null
                ? 'Soal berhasil ditambahkan'
                : 'Soal berhasil diperbarui',
          ),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  Future<void> _deleteQuestion(Map<String, dynamic> question) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Hapus Soal'),
          content: const Text('Hapus soal ini dari template quiz?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    try {
      await QuizApi.deleteTemplateQuestion(question['id'] as int);

      if (!mounted) {
        return;
      }

      _refreshQuestions();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Soal berhasil dihapus'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal menghapus soal'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final templateId = _quizTemplateId;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 18, 22, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_rounded),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Kelola Soal',
                          style: AppTextStyles.headingLarge.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          _quizTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Tambah soal',
                    onPressed: templateId == null ? null : () => _openForm(),
                    icon: const Icon(Icons.add_circle_rounded),
                    color: AppColors.primary,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: templateId == null
                    ? Center(
                        child: Text(
                          'Quiz template tidak ditemukan.',
                          style: AppTextStyles.bodyMedium,
                        ),
                      )
                    : FutureBuilder<List<dynamic>>(
                        future: _questionsFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          if (snapshot.hasError) {
                            return Center(
                              child: Text(
                                'Gagal memuat soal.',
                                style: AppTextStyles.bodyMedium,
                              ),
                            );
                          }

                          final questions = snapshot.data ?? [];

                          if (questions.isEmpty) {
                            return Center(
                              child: Text(
                                'Belum ada soal untuk template ini.',
                                style: AppTextStyles.bodyMedium,
                              ),
                            );
                          }

                          return ListView.separated(
                            itemCount: questions.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final question =
                                  questions[index] as Map<String, dynamic>;

                              return _QuestionAdminCard(
                                number: index + 1,
                                question: question,
                                onEdit: () => _openForm(question: question),
                                onDelete: () => _deleteQuestion(question),
                              );
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: templateId == null ? null : () => _openForm(),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
    );
  }
}

class _QuestionAdminCard extends StatelessWidget {
  final int number;
  final Map<String, dynamic> question;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _QuestionAdminCard({
    required this.number,
    required this.question,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final answer = question['correct_answer']?.toString() ?? '-';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.surfaceSoft,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(
                    '$number',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  question['question']?.toString() ?? '-',
                  style: AppTextStyles.labelLarge.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Edit',
                onPressed: onEdit,
                icon: const Icon(Icons.edit_rounded),
              ),
              IconButton(
                tooltip: 'Hapus',
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline_rounded),
                color: AppColors.error,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'A. ${question['option_a'] ?? '-'}',
            style: AppTextStyles.bodySmall,
          ),
          Text(
            'B. ${question['option_b'] ?? '-'}',
            style: AppTextStyles.bodySmall,
          ),
          Text(
            'C. ${question['option_c'] ?? '-'}',
            style: AppTextStyles.bodySmall,
          ),
          Text(
            'D. ${question['option_d'] ?? '-'}',
            style: AppTextStyles.bodySmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Jawaban benar: $answer',
            style: AppTextStyles.caption.copyWith(color: AppColors.primary),
          ),
        ],
      ),
    );
  }
}

class _QuestionFormDialog extends StatefulWidget {
  final int quizTemplateId;
  final Map<String, dynamic>? question;
  final Future<void> Function(Map<String, dynamic> payload) onSubmit;

  const _QuestionFormDialog({
    required this.quizTemplateId,
    required this.question,
    required this.onSubmit,
  });

  @override
  State<_QuestionFormDialog> createState() => _QuestionFormDialogState();
}

class _QuestionFormDialogState extends State<_QuestionFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _questionController;
  late final TextEditingController _optionAController;
  late final TextEditingController _optionBController;
  late final TextEditingController _optionCController;
  late final TextEditingController _optionDController;
  late String _correctAnswer;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final question = widget.question;
    _questionController = TextEditingController(
      text: question?['question']?.toString() ?? '',
    );
    _optionAController = TextEditingController(
      text: question?['option_a']?.toString() ?? '',
    );
    _optionBController = TextEditingController(
      text: question?['option_b']?.toString() ?? '',
    );
    _optionCController = TextEditingController(
      text: question?['option_c']?.toString() ?? '',
    );
    _optionDController = TextEditingController(
      text: question?['option_d']?.toString() ?? '',
    );
    _correctAnswer = question?['correct_answer']?.toString() ?? 'A';
  }

  @override
  void dispose() {
    _questionController.dispose();
    _optionAController.dispose();
    _optionBController.dispose();
    _optionCController.dispose();
    _optionDController.dispose();
    super.dispose();
  }

  Map<String, dynamic> _payload() {
    return {
      'quiz_template_id': widget.quizTemplateId,
      'question': _questionController.text.trim(),
      'option_a': _optionAController.text.trim(),
      'option_b': _optionBController.text.trim(),
      'option_c': _optionCController.text.trim(),
      'option_d': _optionDController.text.trim(),
      'correct_answer': _correctAnswer,
    };
  }

  String? _requiredText(String? value) {
    return value == null || value.trim().isEmpty ? 'Wajib diisi' : null;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.question == null ? 'Tambah Soal' : 'Edit Soal'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _questionController,
                decoration: const InputDecoration(labelText: 'Pertanyaan'),
                maxLines: 3,
                validator: _requiredText,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _optionAController,
                decoration: const InputDecoration(labelText: 'Option A'),
                validator: _requiredText,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _optionBController,
                decoration: const InputDecoration(labelText: 'Option B'),
                validator: _requiredText,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _optionCController,
                decoration: const InputDecoration(labelText: 'Option C'),
                validator: _requiredText,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _optionDController,
                decoration: const InputDecoration(labelText: 'Option D'),
                validator: _requiredText,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _correctAnswer,
                decoration: const InputDecoration(labelText: 'Jawaban benar'),
                items: const [
                  DropdownMenuItem(value: 'A', child: Text('A')),
                  DropdownMenuItem(value: 'B', child: Text('B')),
                  DropdownMenuItem(value: 'C', child: Text('C')),
                  DropdownMenuItem(value: 'D', child: Text('D')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _correctAnswer = value;
                    });
                  }
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.pop(context, false),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: _isSubmitting
              ? null
              : () async {
                  if (_formKey.currentState?.validate() != true) {
                    return;
                  }

                  setState(() {
                    _isSubmitting = true;
                  });

                  try {
                    await widget.onSubmit(_payload());

                    if (!context.mounted) {
                      return;
                    }

                    Navigator.pop(context, true);
                  } catch (_) {
                    if (!context.mounted) {
                      return;
                    }

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Gagal menyimpan soal'),
                        backgroundColor: AppColors.error,
                      ),
                    );
                  } finally {
                    if (mounted) {
                      setState(() {
                        _isSubmitting = false;
                      });
                    }
                  }
                },
          child: Text(_isSubmitting ? 'Menyimpan...' : 'Simpan'),
        ),
      ],
    );
  }
}
