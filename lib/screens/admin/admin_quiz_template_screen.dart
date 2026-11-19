import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../routes/route_names.dart';
import '../../services/api/quiz_api.dart';

class AdminQuizTemplateScreen extends StatefulWidget {
  const AdminQuizTemplateScreen({super.key});

  @override
  State<AdminQuizTemplateScreen> createState() =>
      _AdminQuizTemplateScreenState();
}

class _AdminQuizTemplateScreenState extends State<AdminQuizTemplateScreen> {
  late Future<List<dynamic>> _templatesFuture;

  @override
  void initState() {
    super.initState();
    _templatesFuture = QuizApi.getQuizTemplates();
  }

  void _refreshTemplates() {
    setState(() {
      _templatesFuture = QuizApi.getQuizTemplates();
    });
  }

  Future<void> _openForm({Map<String, dynamic>? template}) async {
    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => _QuizTemplateFormDialog(
        template: template,
        onSubmit: (payload) async {
          if (template == null) {
            await QuizApi.createQuizTemplate(payload);
          } else {
            await QuizApi.updateQuizTemplate(template['id'] as int, payload);
          }
        },
      ),
    );

    if (saved == true && mounted) {
      _refreshTemplates();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            template == null
                ? 'Quiz berhasil ditambahkan'
                : 'Quiz berhasil diperbarui',
          ),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  Future<void> _deleteTemplate(Map<String, dynamic> template) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Hapus Template'),
          content: Text(
            'Hapus "${template['title'] ?? 'Quiz'}" dari daftar template?',
          ),
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
      await QuizApi.deleteQuizTemplate(template['id'] as int);

      if (!mounted) {
        return;
      }

      _refreshTemplates();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Quiz berhasil dihapus'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal menghapus quiz'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
                    child: Text(
                      'Admin Quiz',
                      style: AppTextStyles.headingLarge.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Tambah template',
                    onPressed: () => _openForm(),
                    icon: const Icon(Icons.add_circle_rounded),
                    color: AppColors.primary,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: FutureBuilder<List<dynamic>>(
                  future: _templatesFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Gagal memuat quiz template.',
                          style: AppTextStyles.bodyMedium,
                        ),
                      );
                    }

                    final templates = snapshot.data ?? [];

                    if (templates.isEmpty) {
                      return Center(
                        child: Text(
                          'Belum ada quiz template.',
                          style: AppTextStyles.bodyMedium,
                        ),
                      );
                    }

                    return ListView.separated(
                      itemCount: templates.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final template =
                            templates[index] as Map<String, dynamic>;
                        return _QuizTemplateAdminCard(
                          template: template,
                          onManageQuestions: () {
                            Navigator.pushNamed(
                              context,
                              RouteNames.adminTemplateQuestions,
                              arguments: {
                                'quizTemplateId': template['id'],
                                'quizTitle': template['title'],
                              },
                            ).then((_) {
                              if (context.mounted) {
                                _refreshTemplates();
                              }
                            });
                          },
                          onEdit: () => _openForm(template: template),
                          onDelete: () => _deleteTemplate(template),
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
        onPressed: () => _openForm(),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
    );
  }
}

class _QuizTemplateAdminCard extends StatelessWidget {
  final Map<String, dynamic> template;
  final VoidCallback onManageQuestions;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _QuizTemplateAdminCard({
    required this.template,
    required this.onManageQuestions,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final questionCount = template['template_questions_count'] ?? 0;

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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.surfaceSoft,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.quiz_rounded, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  template['title']?.toString() ?? 'Quiz',
                  style: AppTextStyles.labelLarge.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  template['description']?.toString() ?? '-',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodySmall,
                ),
                const SizedBox(height: 8),
                Text(
                  '${template['slug']} - $questionCount soal',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: onManageQuestions,
                  icon: const Icon(Icons.list_alt_rounded, size: 18),
                  label: const Text('Kelola Soal'),
                ),
              ],
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
    );
  }
}

class _QuizTemplateFormDialog extends StatefulWidget {
  final Map<String, dynamic>? template;
  final Future<void> Function(Map<String, dynamic> payload) onSubmit;

  const _QuizTemplateFormDialog({
    required this.template,
    required this.onSubmit,
  });

  @override
  State<_QuizTemplateFormDialog> createState() =>
      _QuizTemplateFormDialogState();
}

class _QuizTemplateFormDialogState extends State<_QuizTemplateFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _slugController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _difficultyController;
  late final TextEditingController _durationController;
  late int _categoryId;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final template = widget.template;
    _categoryId = int.tryParse('${template?['category_id'] ?? 1}') ?? 1;
    _titleController = TextEditingController(
      text: template?['title']?.toString() ?? '',
    );
    _slugController = TextEditingController(
      text: template?['slug']?.toString() ?? '',
    );
    _descriptionController = TextEditingController(
      text: template?['description']?.toString() ?? '',
    );
    _difficultyController = TextEditingController(
      text: template?['difficulty']?.toString() ?? 'Mudah',
    );
    _durationController = TextEditingController(
      text: '${template?['duration_minutes'] ?? 10}',
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _slugController.dispose();
    _descriptionController.dispose();
    _difficultyController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  Map<String, dynamic> _payload() {
    return {
      'category_id': _categoryId,
      'title': _titleController.text.trim(),
      'slug': _slugController.text.trim(),
      'description': _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      'difficulty': _difficultyController.text.trim().isEmpty
          ? null
          : _difficultyController.text.trim(),
      'duration_minutes': int.tryParse(_durationController.text.trim()),
    };
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.template == null ? 'Tambah Template' : 'Edit Template',
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<int>(
                initialValue: _categoryId,
                decoration: const InputDecoration(labelText: 'Kategori'),
                items: const [
                  DropdownMenuItem(value: 1, child: Text('Teknologi')),
                  DropdownMenuItem(value: 2, child: Text('Bahasa')),
                  DropdownMenuItem(value: 3, child: Text('Matematika')),
                  DropdownMenuItem(value: 4, child: Text('Umum')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _categoryId = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Judul'),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Wajib diisi'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _slugController,
                decoration: const InputDecoration(labelText: 'Slug'),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Wajib diisi'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Deskripsi'),
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _difficultyController,
                decoration: const InputDecoration(labelText: 'Difficulty'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _durationController,
                decoration: const InputDecoration(labelText: 'Durasi menit'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return null;
                  }

                  return int.tryParse(value.trim()) == null
                      ? 'Harus berupa angka'
                      : null;
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
                        content: Text('Gagal menyimpan quiz'),
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
