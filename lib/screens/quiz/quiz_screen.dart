import 'dart:async';

import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../routes/route_names.dart';
import '../../services/api/quiz_api.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/quiz/answer_option_tile.dart';
import '../../widgets/quiz/question_card.dart';
import '../../widgets/quiz/quiz_timer.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  static const int secondsPerQuestion = 40;

  int currentIndex = 0;
  String quizTitle = 'Quiz';
  String categoryTitle = 'Umum';
  bool hasLoadedArguments = false;
  bool isLoadingQuestions = false;
  bool isSubmitting = false;
  int remainingSeconds = secondsPerQuestion;
  Timer? questionTimer;
  String source = '';
  int? quizTemplateId;
  String? questionLoadError;
  Map<String, dynamic> quizListArguments = const <String, dynamic>{};
  final Map<int, int> selectedAnswers = {};
  final Set<int> evaluatedQuestions = {};

  List<_QuestionData> questions = const [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (hasLoadedArguments) {
      return;
    }

    final routeArguments = ModalRoute.of(context)?.settings.arguments;

    if (routeArguments is Map<String, dynamic>) {
      quizTitle = routeArguments['quizTitle'] as String? ?? quizTitle;
      categoryTitle =
          routeArguments['categoryTitle'] as String? ?? categoryTitle;
      source = routeArguments['source'] as String? ?? source;
      final rawQuizListArguments = routeArguments['quizListArguments'];
      if (rawQuizListArguments is Map<String, dynamic>) {
        quizListArguments = rawQuizListArguments;
      }
      quizTemplateId = _parseTemplateId(routeArguments['quizTemplateId']);
    }

    hasLoadedArguments = true;

    if (quizTemplateId == null) {
      questionLoadError = 'Quiz template tidak ditemukan.';
      return;
    }

    isLoadingQuestions = true;
    _loadQuestions(quizTemplateId!);
  }

  int? _parseTemplateId(dynamic rawId) {
    if (rawId is int) {
      return rawId;
    }

    return int.tryParse(rawId?.toString() ?? '');
  }

  Future<void> _loadQuestions(int templateId) async {
    try {
      final response = await QuizApi.getQuestionsByTemplate(templateId);
      final loadedQuestions = _parseQuestions(response);

      if (!mounted) {
        return;
      }

      setState(() {
        questions = loadedQuestions;
        isLoadingQuestions = false;
        questionLoadError = loadedQuestions.isEmpty
            ? 'Quiz ini belum memiliki data pertanyaan yang valid.'
            : null;
      });

      if (loadedQuestions.isNotEmpty) {
        _resetQuestionTimer();
      }
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        isLoadingQuestions = false;
        questionLoadError = 'Gagal memuat pertanyaan dari backend.';
      });
    }
  }

  List<_QuestionData> _parseQuestions(dynamic rawQuestions) {
    if (rawQuestions is! List) {
      return const [];
    }

    return rawQuestions
        .whereType<Map>()
        .map(_parseQuestion)
        .whereType<_QuestionData>()
        .toList();
  }

  _QuestionData? _parseQuestion(Map item) {
    final question = item['question']?.toString().trim();
    final parsedOptions = [
      item['option_a']?.toString().trim(),
      item['option_b']?.toString().trim(),
      item['option_c']?.toString().trim(),
      item['option_d']?.toString().trim(),
    ].whereType<String>().toList();
    final correctIndex = _correctIndexFromAnswer(item['correct_answer']);

    if (question == null ||
        question.isEmpty ||
        parsedOptions.length != 4 ||
        parsedOptions.any((option) => option.isEmpty) ||
        correctIndex == null) {
      return null;
    }

    return _QuestionData(
      question: question,
      options: parsedOptions,
      correctIndex: correctIndex,
    );
  }

  int? _correctIndexFromAnswer(dynamic rawAnswer) {
    switch (rawAnswer?.toString().trim().toUpperCase()) {
      case 'A':
        return 0;
      case 'B':
        return 1;
      case 'C':
        return 2;
      case 'D':
        return 3;
      default:
        return null;
    }
  }

  int get selectedIndex => selectedAnswers[currentIndex] ?? -1;

  int get correctAnsweredCount {
    int count = 0;

    selectedAnswers.forEach((questionIndex, answerIndex) {
      if (evaluatedQuestions.contains(questionIndex) &&
          questionIndex < questions.length &&
          questions[questionIndex].correctIndex == answerIndex) {
        count++;
      }
    });

    return count;
  }

  void _selectAnswer(int index) {
    setState(() {
      selectedAnswers[currentIndex] = index;
    });
  }

  void _goNext() {
    if (questions.isEmpty) {
      return;
    }

    _completeCurrentQuestion();
  }

  void _completeCurrentQuestion() {
    questionTimer?.cancel();
    evaluatedQuestions.add(currentIndex);

    final isLastQuestion = currentIndex == questions.length - 1;

    if (isLastQuestion) {
      _submitQuiz();
      return;
    }

    setState(() {
      currentIndex++;
      remainingSeconds = secondsPerQuestion;
    });

    _resetQuestionTimer();
  }

  void _handleTimeExpired() {
    if (!mounted || isSubmitting || questions.isEmpty) {
      return;
    }

    selectedAnswers.remove(currentIndex);
    _completeCurrentQuestion();
  }

  void _resetQuestionTimer() {
    questionTimer?.cancel();

    questionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (isSubmitting || questions.isEmpty) {
        timer.cancel();
        return;
      }

      if (remainingSeconds <= 1) {
        timer.cancel();
        _handleTimeExpired();
        return;
      }

      setState(() {
        remainingSeconds--;
      });
    });
  }

  void _submitQuiz() {
    if (isSubmitting || !mounted) {
      return;
    }

    isSubmitting = true;
    questionTimer?.cancel();

    Navigator.pushReplacementNamed(
      context,
      RouteNames.result,
      arguments: _buildResultArguments(),
    );
  }

  Map<String, dynamic> _buildResultArguments() {
    final totalQuestions = questions.length;
    final correctAnswers = correctAnsweredCount;
    final wrongAnswers = totalQuestions - correctAnswers;
    final scorePercentage = totalQuestions == 0
        ? 0
        : ((correctAnswers / totalQuestions) * 100).round();

    return {
      'quizTitle': quizTitle,
      'source': source,
      'totalQuestions': totalQuestions,
      'correctAnswers': correctAnswers,
      'wrongAnswers': wrongAnswers,
      'scorePercentage': scorePercentage,
      'quizTemplateId': quizTemplateId,
      'selectedAnswers': Map<int, int>.from(selectedAnswers),
      'quizListArguments': quizListArguments,
      'questions': questions
          .map(
            (question) => {
              'question': question.question,
              'options': question.options,
              'correctIndex': question.correctIndex,
            },
          )
          .toList(),
    };
  }

  @override
  Widget build(BuildContext context) {
    if (isLoadingQuestions) {
      return _LoadingQuizState(
        quizTitle: quizTitle,
        categoryTitle: categoryTitle,
      );
    }

    if (questions.isEmpty) {
      return _EmptyQuizState(
        quizTitle: quizTitle,
        categoryTitle: categoryTitle,
        message:
            questionLoadError ??
            'Quiz ini belum memiliki data pertanyaan yang valid.',
      );
    }

    final question = questions[currentIndex];
    final progress = (currentIndex + 1) / questions.length;
    final isLastQuestion = currentIndex == questions.length - 1;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 18, 22, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _QuizHeader(
                quizTitle: quizTitle,
                categoryTitle: categoryTitle,
                currentQuestion: currentIndex + 1,
                totalQuestions: questions.length,
                progress: progress,
              ),

              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  QuizTimer(
                    seconds: remainingSeconds,
                    progress: remainingSeconds / secondsPerQuestion,
                    size: 82,
                  ),
                ],
              ),

              const SizedBox(height: 18),

              QuestionCard(questionText: question.question),

              const SizedBox(height: 26),

              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: question.options.length,
                separatorBuilder: (_, _) => const SizedBox(height: 14),
                itemBuilder: (context, index) {
                  return AnswerOptionTile(
                    label: String.fromCharCode(65 + index),
                    answerText: question.options[index],
                    isSelected: selectedIndex == index,
                    showCheckIcon: selectedIndex == index,
                    onTap: () => _selectAnswer(index),
                  );
                },
              ),

              const SizedBox(height: 32),

              Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: Container(
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.08),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          '$correctAnsweredCount Benar',
                          style: AppTextStyles.labelLarge.copyWith(
                            color: AppColors.success,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    flex: 7,
                    child: CustomButton(
                      text: isLastQuestion
                          ? 'Submit Quiz'
                          : 'Pertanyaan Berikutnya',
                      onPressed: selectedIndex == -1 ? null : _goNext,
                      type: QuizifyButtonType.primary,
                      height: 56,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    questionTimer?.cancel();
    super.dispose();
  }
}

class _QuizHeader extends StatelessWidget {
  final String quizTitle;
  final String categoryTitle;
  final int currentQuestion;
  final int totalQuestions;
  final double progress;

  const _QuizHeader({
    required this.quizTitle,
    required this.categoryTitle,
    required this.currentQuestion,
    required this.totalQuestions,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          quizTitle,
          style: AppTextStyles.headingLarge.copyWith(
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          categoryTitle,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'PERTANYAAN $currentQuestion DARI $totalQuestions',
          style: AppTextStyles.labelMedium.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w900,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 12,
            backgroundColor: AppColors.surfaceSoft,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
      ],
    );
  }
}

class _EmptyQuizState extends StatelessWidget {
  final String quizTitle;
  final String categoryTitle;
  final String message;

  const _EmptyQuizState({
    required this.quizTitle,
    required this.categoryTitle,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 18, 22, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                quizTitle,
                style: AppTextStyles.headingLarge.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                categoryTitle,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const Spacer(),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      blurRadius: 24,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      width: 74,
                      height: 74,
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.10),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.error_outline_rounded,
                        color: AppColors.error,
                        size: 38,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Pertanyaan belum tersedia',
                      style: AppTextStyles.headingSmall.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyMedium,
                    ),
                    const SizedBox(height: 22),
                    CustomButton(
                      text: 'Kembali',
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      type: QuizifyButtonType.outlined,
                    ),
                  ],
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoadingQuizState extends StatelessWidget {
  final String quizTitle;
  final String categoryTitle;

  const _LoadingQuizState({
    required this.quizTitle,
    required this.categoryTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 18, 22, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                quizTitle,
                style: AppTextStyles.headingLarge.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                categoryTitle,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const Spacer(),
              const Center(child: CircularProgressIndicator()),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuestionData {
  final String question;
  final List<String> options;
  final int correctIndex;

  const _QuestionData({
    required this.question,
    required this.options,
    required this.correctIndex,
  });
}
