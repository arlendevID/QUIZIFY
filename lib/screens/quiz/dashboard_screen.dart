import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../routes/route_names.dart';
import '../../services/api/quiz_api.dart';
import '../../services/repository/category_repository.dart';
import '../../widgets/dashboard/category_card.dart';
import '../../widgets/dashboard/quiz_recommendation_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Future<List<dynamic>> _categoriesFuture;
  late Future<_DashboardSummary> _dashboardSummaryFuture;

  @override
  void initState() {
    super.initState();
    _categoriesFuture = CategoryRepository().getCategories();
    _dashboardSummaryFuture = _loadDashboardSummary();
  }

  Future<_DashboardSummary> _loadDashboardSummary() async {
    final data = await QuizApi.getUserDashboard();
    return _DashboardSummary.fromJson(data);
  }

  void _refreshDashboardSummary() {
    if (!mounted) {
      return;
    }

    setState(() {
      _dashboardSummaryFuture = _loadDashboardSummary();
    });
  }

  List<Map<String, dynamic>> _sampleQuestions(String quizTitle) {
    return [
      {
        'question': 'Apa fokus utama dari $quizTitle?',
        'options': ['Konsep dasar', 'Olahraga', 'Musik', 'Kuliner'],
        'correctIndex': 0,
      },
      {
        'question': 'Apa manfaat mengikuti kuis ini?',
        'options': [
          'Mengasah pemahaman',
          'Menghapus data',
          'Mengganti akun',
          'Membuka pengaturan',
        ],
        'correctIndex': 0,
      },
      {
        'question': 'Bagaimana cara mendapatkan skor terbaik?',
        'options': [
          'Menjawab dengan teliti',
          'Melewati semua soal',
          'Menutup aplikasi',
          'Mengabaikan instruksi',
        ],
        'correctIndex': 0,
      },
      {
        'question': 'Apa yang ditampilkan setelah kuis selesai?',
        'options': ['Hasil kuis', 'Halaman login', 'Pengaturan', 'Splash'],
        'correctIndex': 0,
      },
    ];
  }

  IconData _iconFromSlug(String slug) {
    switch (slug) {
      case 'teknologi':
        return Icons.computer_rounded;
      case 'bahasa':
        return Icons.translate_rounded;
      case 'matematika':
        return Icons.calculate_rounded;
      case 'umum':
        return Icons.public_rounded;
      default:
        return Icons.quiz_rounded;
    }
  }

  Color _colorFromHex(String? hex, String slug) {
    if (hex != null && hex.isNotEmpty) {
      final cleanHex = hex.replaceAll('#', '');
      return Color(int.parse('FF$cleanHex', radix: 16));
    }

    switch (slug) {
      case 'teknologi':
        return AppColors.primary;
      case 'bahasa':
        return AppColors.tertiary;
      case 'matematika':
        return const Color(0xFF22C55E);
      case 'umum':
        return AppColors.secondary;
      default:
        return AppColors.primary;
    }
  }

  String _heroTitle(String slug, String name) {
    switch (slug) {
      case 'teknologi':
        return 'Eksplorasi Teknologi';
      case 'bahasa':
        return 'Eksplorasi Bahasa';
      case 'matematika':
        return 'Tantangan Matematika';
      case 'umum':
        return 'Pengetahuan Umum';
      default:
        return name;
    }
  }

  String _heroDescription(String slug) {
    switch (slug) {
      case 'teknologi':
        return 'Jelajahi dunia teknologi dari AI hingga Hardware. Uji pengetahuanmu dan jadilah master di era digital.';
      case 'bahasa':
        return 'Latih kosakata, tata bahasa, dan kemampuan memahami bahasa lewat tantangan singkat.';
      case 'matematika':
        return 'Asah kemampuan berhitung, logika, dan pemecahan masalah dalam kuis matematika.';
      case 'umum':
        return 'Uji wawasan luasmu dari topik sehari-hari, budaya, dunia, dan fakta menarik lainnya.';
      default:
        return 'Pilih quiz dan mulai tantangan belajarmu.';
    }
  }

  int _fallbackQuizCount(String slug) {
    switch (slug) {
      case 'teknologi':
        return 32;
      case 'bahasa':
        return 18;
      case 'matematika':
        return 27;
      case 'umum':
        return 21;
      default:
        return 0;
    }
  }

  void _goToQuizList(
    BuildContext context, {
    required String categoryTitle,
    required String heroTitle,
    required String heroDescription,
    required IconData heroIcon,
    required Color heroColor,
  }) {
    Navigator.pushNamed(
      context,
      RouteNames.quizList,
      arguments: {
        'categoryTitle': categoryTitle,
        'heroTitle': heroTitle,
        'heroDescription': heroDescription,
        'heroIcon': heroIcon,
        'heroColor': heroColor,
      },
    ).then((_) => _refreshDashboardSummary());
  }

  void _openRecommendedQuiz(
    BuildContext context, {
    required String quizTitle,
    required String categoryTitle,
    required String heroTitle,
    required String heroDescription,
    required IconData heroIcon,
    required Color heroColor,
  }) {
    final questions = _sampleQuestions(quizTitle);

    Navigator.pushNamed(
      context,
      RouteNames.quiz,
      arguments: {
        'quizTitle': quizTitle,
        'categoryTitle': categoryTitle,
        'source': 'recommendation',
        'totalQuestions': questions.length,
        'questions': questions,
        'quizListArguments': {
          'categoryTitle': categoryTitle,
          'heroTitle': heroTitle,
          'heroDescription': heroDescription,
          'heroIcon': heroIcon,
          'heroColor': heroColor,
        },
      },
    );
  }

  Widget _buildCategoryGrid() {
    return FutureBuilder<List<dynamic>>(
      future: _categoriesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Text(
              'Gagal memuat kategori dari backend.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textMuted,
              ),
            ),
          );
        }

        final categories = snapshot.data ?? [];

        if (categories.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Text(
              'Belum ada kategori tersedia.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textMuted,
              ),
            ),
          );
        }

        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: 1.08,
          children: categories.map((category) {
            final name = category['name']?.toString() ?? 'Kategori';
            final slug = category['slug']?.toString() ?? '';
            final color = _colorFromHex(category['color']?.toString(), slug);
            final icon = _iconFromSlug(slug);

            return CategoryCard(
              title: name,
              quizCount: _fallbackQuizCount(slug),
              icon: icon,
              color: color,
              darkText: slug == 'bahasa',
              onTap: () => _goToQuizList(
                context,
                categoryTitle: name,
                heroTitle: _heroTitle(slug, name),
                heroDescription: _heroDescription(slug),
                heroIcon: icon,
                heroColor: color,
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildDashboardSummary() {
    return FutureBuilder<_DashboardSummary>(
      future: _dashboardSummaryFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _DashboardSummarySection(isLoading: true);
        }

        if (snapshot.hasError || snapshot.data == null) {
          return const _DashboardSummarySection(
            summary: _DashboardSummary.empty(),
          );
        }

        return _DashboardSummarySection(summary: snapshot.data!);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(22, 18, 22, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDashboardSummary(),
                  const SizedBox(height: 28),
                  _SectionHeader(
                    title: 'Rekomendasi Untukmu',
                    actionText: '',
                    onTap: () => _goToQuizList(
                      context,
                      categoryTitle: 'Teknologi',
                      heroTitle: 'Eksplorasi Teknologi',
                      heroDescription:
                          'Jelajahi dunia teknologi dari AI hingga Hardware. Uji pengetahuanmu dan jadilah master di era digital.',
                      heroIcon: Icons.computer_rounded,
                      heroColor: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 178,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        QuizRecommendationCard(
                          title: 'Garis Depan Siber',
                          badge: 'PALING POPULER',
                          questionCount: 24,
                          icon: Icons.security_rounded,
                          gradient: AppColors.bluePurpleGradient,
                          onTap: () => _openRecommendedQuiz(
                            context,
                            quizTitle: 'Garis Depan Siber',
                            categoryTitle: 'Keamanan Siber',
                            heroTitle: 'Garis Depan Siber',
                            heroDescription:
                                'Pelajari cara melindungi data dan sistem dari ancaman digital melalui tantangan keamanan siber.',
                            heroIcon: Icons.security_rounded,
                            heroColor: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 14),
                        QuizRecommendationCard(
                          title: 'Kalkulus Lanjutan',
                          badge: 'TANTANGAN HARIAN',
                          questionCount: 18,
                          icon: Icons.functions_rounded,
                          gradient: AppColors.goldGradient,
                          darkText: true,
                          onTap: () => _openRecommendedQuiz(
                            context,
                            quizTitle: 'Kalkulus Lanjutan',
                            categoryTitle: 'Matematika',
                            heroTitle: 'Kalkulus Lanjutan',
                            heroDescription:
                                'Asah logika dan pemahaman rumus melalui kuis matematika yang menantang.',
                            heroIcon: Icons.functions_rounded,
                            heroColor: AppColors.tertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  _SectionHeader(
                    title: 'Kategori Kuis',
                    actionText: '',
                    onTap: () {},
                  ),
                  const SizedBox(height: 16),
                  _buildCategoryGrid(),
                ],
              ),
            ),
            const Positioned(
              left: 22,
              right: 22,
              bottom: 18,
              child: _BottomNav(),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardSummary {
  final int totalXp;
  final int level;
  final int totalQuizCompleted;
  final int rank;

  const _DashboardSummary({
    required this.totalXp,
    required this.level,
    required this.totalQuizCompleted,
    required this.rank,
  });

  const _DashboardSummary.empty()
    : totalXp = 0,
      level = 1,
      totalQuizCompleted = 0,
      rank = 0;

  factory _DashboardSummary.fromJson(Map<String, dynamic> json) {
    final totalQuizCompleted = _parseInt(json['total_quiz_completed']);

    return _DashboardSummary(
      totalXp: _parseInt(json['total_xp']),
      level: _parseInt(json['level'], fallback: 1),
      totalQuizCompleted: totalQuizCompleted,
      rank: totalQuizCompleted == 0 ? 0 : _parseInt(json['rank']),
    );
  }

  static int _parseInt(dynamic value, {int fallback = 0}) {
    if (value is int) {
      return value;
    }

    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }
}

class _DashboardSummarySection extends StatelessWidget {
  final _DashboardSummary? summary;
  final bool isLoading;

  const _DashboardSummarySection({this.summary, this.isLoading = false});

  @override
  Widget build(BuildContext context) {
    final data = summary ?? const _DashboardSummary.empty();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Header(level: isLoading ? null : data.level),
        const SizedBox(height: 24),
        _XpProgressCard(summary: data, isLoading: isLoading),
        const SizedBox(height: 18),
        _StatsRow(summary: data, isLoading: isLoading),
      ],
    );
  }
}

String _formatDashboardNumber(int value) {
  final text = value.toString();
  final buffer = StringBuffer();

  for (var index = 0; index < text.length; index++) {
    if (index > 0 && (text.length - index) % 3 == 0) {
      buffer.write(',');
    }

    buffer.write(text[index]);
  }

  return buffer.toString();
}

class _Header extends StatelessWidget {
  final int? level;

  const _Header({required this.level});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            gradient: AppColors.bluePurpleGradient,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.18),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(Icons.bolt_rounded, color: Colors.white, size: 30),
        ),
        const SizedBox(width: 12),
        Text(
          'Quizify',
          style: AppTextStyles.headingLarge.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(999),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.10),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: level == null
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.4,
                    color: AppColors.primary,
                  ),
                )
              : Text(
                  'Lvl $level',
                  style: AppTextStyles.labelLarge.copyWith(
                    color: AppColors.primary,
                  ),
                ),
        ),
      ],
    );
  }
}

class _XpProgressCard extends StatelessWidget {
  final _DashboardSummary summary;
  final bool isLoading;

  const _XpProgressCard({required this.summary, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    final currentLevelXp = summary.totalXp % 100;
    final nextLevelXp = 100 - currentLevelXp;
    final progress = currentLevelXp / 100;

    return Container(
      height: 210,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.bluePurpleGradient,
        borderRadius: BorderRadius.circular(36),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.25),
            blurRadius: 34,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -18,
            bottom: -18,
            child: Icon(
              Icons.emoji_events_rounded,
              size: 132,
              color: Colors.white.withValues(alpha: 0.12),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'YB Saat Ini',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Colors.white.withValues(alpha: 0.78),
                ),
              ),
              const SizedBox(height: 8),
              if (isLoading)
                const SizedBox(
                  width: 30,
                  height: 30,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color: Colors.white,
                  ),
                )
              else
                Text(
                  '${_formatDashboardNumber(summary.totalXp)} XP',
                  style: AppTextStyles.displayLarge.copyWith(
                    color: Colors.white,
                    fontSize: 38,
                  ),
                ),
              const Spacer(),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: isLoading ? null : progress,
                  minHeight: 12,
                  backgroundColor: Colors.white.withValues(alpha: 0.22),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.tertiary,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                isLoading
                    ? 'Memuat progress level...'
                    : '$nextLevelXp XP menuju Level ${summary.level + 1}',
                style: AppTextStyles.bodySmall.copyWith(
                  color: Colors.white.withValues(alpha: 0.82),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  final _DashboardSummary summary;
  final bool isLoading;

  const _StatsRow({required this.summary, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            value: isLoading ? '-' : '${summary.totalQuizCompleted}',
            label: 'Quiz Selesai',
            icon: Icons.quiz_rounded,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: _StatCard(
            value: isLoading
                ? '#-'
                : summary.rank == 0
                ? '-'
                : '#${summary.rank}',
            label: 'Peringkat Global',
            icon: Icons.leaderboard_rounded,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;

  const _StatCard({
    required this.value,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.08),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: AppTextStyles.headingSmall),
                const SizedBox(height: 3),
                Text(label, style: AppTextStyles.caption),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String actionText;
  final VoidCallback onTap;

  const _SectionHeader({
    required this.title,
    required this.actionText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(title, style: AppTextStyles.headingMedium),
        const Spacer(),
        if (actionText.isNotEmpty)
          TextButton(onPressed: onTap, child: Text(actionText)),
      ],
    );
  }
}

class _BottomNav extends StatelessWidget {
  const _BottomNav();

  void _openTab(BuildContext context, String routeName) {
    Navigator.pushReplacementNamed(context, routeName);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.14),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Row(
        children: [
          const Expanded(
            child: _BottomNavItem(
              icon: Icons.home_rounded,
              label: 'Beranda',
              isActive: true,
            ),
          ),
          Expanded(
            child: _BottomNavItem(
              icon: Icons.emoji_events_rounded,
              label: 'Peringkat',
              onTap: () => _openTab(context, RouteNames.leaderboard),
            ),
          ),
          Expanded(
            child: _BottomNavItem(
              icon: Icons.person_rounded,
              label: 'User',
              onTap: () => _openTab(context, RouteNames.user),
            ),
          ),
          Expanded(
            child: _BottomNavItem(
              icon: Icons.info_rounded,
              label: 'About',
              onTap: () => _openTab(context, RouteNames.aboutDeveloper),
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback? onTap;

  const _BottomNavItem({
    required this.icon,
    required this.label,
    this.isActive = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 52,
        decoration: BoxDecoration(
          gradient: isActive ? AppColors.bluePurpleGradient : null,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isActive ? Colors.white : AppColors.textMuted,
              size: 21,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.caption.copyWith(
                color: isActive ? Colors.white : AppColors.textMuted,
                fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
