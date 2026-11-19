import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../routes/route_names.dart';
import '../../services/api/quiz_api.dart';
import '../../services/auth_session.dart';
import '../../widgets/leaderboard/leaderboard_tile.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  late Future<List<_LeaderboardEntry>> _leaderboardFuture;

  @override
  void initState() {
    super.initState();
    _leaderboardFuture = _loadLeaderboard();
  }

  Future<List<_LeaderboardEntry>> _loadLeaderboard() async {
    final data = await QuizApi.getLeaderboard();
    return data
        .whereType<Map>()
        .map((item) => _LeaderboardEntry.fromJson(item))
        .toList();
  }

  void _goBackToDashboard(BuildContext context) {
    var dashboardFound = false;

    Navigator.popUntil(context, (route) {
      if (route.settings.name == RouteNames.dashboard) {
        dashboardFound = true;
        return true;
      }

      return route.isFirst;
    });

    if (!dashboardFound) {
      Navigator.pushReplacementNamed(context, RouteNames.dashboard);
    }
  }

  int? _currentUserId() {
    final rawId = AuthSession.user?['id'];
    if (rawId is int) {
      return rawId;
    }

    return int.tryParse(rawId?.toString() ?? '');
  }

  Widget _buildContent(AsyncSnapshot<List<_LeaderboardEntry>> snapshot) {
    final entries = snapshot.data ?? const <_LeaderboardEntry>[];
    final currentUserId = _currentUserId();
    _LeaderboardEntry? currentUserEntry;

    for (final entry in entries) {
      if (entry.userId == currentUserId) {
        currentUserEntry = entry;
        break;
      }
    }

    if (snapshot.connectionState == ConnectionState.waiting) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          _Header(),
          SizedBox(height: 24),
          _TabSwitch(),
          SizedBox(height: 48),
          Center(child: CircularProgressIndicator()),
        ],
      );
    }

    if (snapshot.hasError) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Header(level: currentUserEntry?.level),
          const SizedBox(height: 24),
          const _TabSwitch(),
          const SizedBox(height: 48),
          Center(
            child: Text(
              'Gagal memuat leaderboard',
              style: AppTextStyles.bodyMedium,
            ),
          ),
        ],
      );
    }

    if (entries.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Header(level: currentUserEntry?.level),
          const SizedBox(height: 24),
          const _TabSwitch(),
          const SizedBox(height: 48),
          Center(
            child: Text(
              'Belum ada data leaderboard',
              style: AppTextStyles.bodyMedium,
            ),
          ),
        ],
      );
    }

    final topThree = entries.take(3).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Header(level: currentUserEntry?.level),
        const SizedBox(height: 24),
        const _TabSwitch(),
        const SizedBox(height: 24),
        _TopThreeRanking(entries: topThree),
        const SizedBox(height: 24),
        Text(
          'Ranking Mingguan',
          style: AppTextStyles.headingMedium.copyWith(
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 16),
        ...entries.indexed.expand((indexedEntry) {
          final index = indexedEntry.$1;
          final entry = indexedEntry.$2;

          return [
            if (index > 0) const SizedBox(height: 14),
            LeaderboardTile(
              rank: entry.rank,
              name: entry.name,
              levelText: 'Lvl ${entry.level}',
              xp: '${_formatLeaderboardNumber(entry.totalXp)} XP',
              isCurrentUser: entry.userId == currentUserId,
            ),
          ];
        }),
      ],
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
              padding: const EdgeInsets.fromLTRB(22, 18, 22, 118),
              child: FutureBuilder<List<_LeaderboardEntry>>(
                future: _leaderboardFuture,
                builder: (context, snapshot) => _buildContent(snapshot),
              ),
            ),
            Positioned(
              left: 22,
              right: 22,
              bottom: 18,
              child: _BottomNav(onHomeTap: () => _goBackToDashboard(context)),
            ),
          ],
        ),
      ),
    );
  }
}

class _LeaderboardEntry {
  final int userId;
  final String name;
  final int totalXp;
  final int level;
  final int rank;

  const _LeaderboardEntry({
    required this.userId,
    required this.name,
    required this.totalXp,
    required this.level,
    required this.rank,
  });

  factory _LeaderboardEntry.fromJson(Map<dynamic, dynamic> json) {
    return _LeaderboardEntry(
      userId: _parseInt(json['user_id']),
      name: json['name']?.toString().trim().isNotEmpty == true
          ? json['name'].toString().trim()
          : 'User',
      totalXp: _parseInt(json['total_xp']),
      level: _parseInt(json['level'], fallback: 1),
      rank: _parseInt(json['rank']),
    );
  }

  static int _parseInt(dynamic value, {int fallback = 0}) {
    if (value is int) {
      return value;
    }

    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }
}

String _formatLeaderboardNumber(int value) {
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

  const _Header({this.level});

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
            fontWeight: FontWeight.w900,
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
          child: Text(
            level == null ? 'Lvl -' : 'Lvl $level',
            style: AppTextStyles.labelLarge.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }
}

class _TabSwitch extends StatelessWidget {
  const _TabSwitch();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(26),
      ),
      child: Row(
        children: const [
          Expanded(child: _TabItem(title: 'Weekly', isActive: true)),
          Expanded(child: _TabItem(title: 'All-time')),
        ],
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  final String title;
  final bool isActive;

  const _TabItem({required this.title, this.isActive = false});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      height: 48,
      decoration: BoxDecoration(
        gradient: isActive ? AppColors.bluePurpleGradient : null,
        borderRadius: BorderRadius.circular(20),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.18),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ]
            : null,
      ),
      child: Center(
        child: Text(
          title,
          style: AppTextStyles.labelLarge.copyWith(
            color: isActive ? Colors.white : AppColors.textSecondary,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _TopThreeRanking extends StatelessWidget {
  final List<_LeaderboardEntry> entries;

  const _TopThreeRanking({required this.entries});

  @override
  Widget build(BuildContext context) {
    final displayOrder = <int>[2, 1, 3];
    final cards = <Widget>[];

    for (final rank in displayOrder) {
      _LeaderboardEntry? entry;

      for (final candidate in entries) {
        if (candidate.rank == rank) {
          entry = candidate;
          break;
        }
      }

      if (entry == null) {
        continue;
      }

      if (cards.isNotEmpty) {
        cards.add(const SizedBox(width: 12));
      }

      cards.add(
        Expanded(
          child: _TopRankCard(
            rank: entry.rank,
            name: entry.name,
            xp: '${_formatLeaderboardNumber(entry.totalXp)} XP',
            height: entry.rank == 1
                ? 238
                : entry.rank == 2
                ? 198
                : 184,
            avatarSize: entry.rank == 1
                ? 86
                : entry.rank == 2
                ? 70
                : 66,
            podiumHeight: entry.rank == 1
                ? 88
                : entry.rank == 2
                ? 64
                : 54,
            isChampion: entry.rank == 1,
          ),
        ),
      );
    }

    return SizedBox(
      height: entries.length < 3 ? 242 : 270,
      child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: cards),
    );
  }
}

class _TopRankCard extends StatelessWidget {
  final int rank;
  final String name;
  final String xp;
  final double height;
  final double avatarSize;
  final double podiumHeight;
  final bool isChampion;

  const _TopRankCard({
    required this.rank,
    required this.name,
    required this.xp,
    required this.height,
    required this.avatarSize,
    required this.podiumHeight,
    this.isChampion = false,
  });

  @override
  Widget build(BuildContext context) {
    final rankColor = rank == 1
        ? AppColors.tertiary
        : rank == 2
        ? AppColors.neutral
        : AppColors.secondary;

    return SizedBox(
      height: height,
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.topCenter,
            children: [
              Container(
                width: avatarSize,
                height: avatarSize,
                decoration: BoxDecoration(
                  gradient: isChampion
                      ? AppColors.goldGradient
                      : AppColors.bluePurpleGradient,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: rankColor.withValues(alpha: 0.25),
                      blurRadius: 22,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.person_rounded,
                  color: Colors.white,
                  size: avatarSize * 0.52,
                ),
              ),
              if (isChampion)
                Positioned(
                  top: -22,
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: const BoxDecoration(
                      color: AppColors.tertiary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.workspace_premium_rounded,
                      color: AppColors.textPrimary,
                      size: 22,
                    ),
                  ),
                ),
              Positioned(
                bottom: -8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '#$rank',
                    style: AppTextStyles.caption.copyWith(
                      color: rankColor,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            name,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.labelLarge.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            xp,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const Spacer(),
          Container(
            height: podiumHeight,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: isChampion
                  ? AppColors.bluePurpleGradient
                  : LinearGradient(
                      colors: [
                        AppColors.surface,
                        AppColors.surfaceSoft.withValues(alpha: 0.9),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(26),
              ),
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
                '$rank',
                style: AppTextStyles.headingLarge.copyWith(
                  color: isChampion ? Colors.white : AppColors.textMuted,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  final VoidCallback onHomeTap;

  const _BottomNav({required this.onHomeTap});

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
          Expanded(
            child: _BottomNavItem(
              icon: Icons.home_rounded,
              label: 'Beranda',
              onTap: onHomeTap,
            ),
          ),
          const Expanded(
            child: _BottomNavItem(
              icon: Icons.emoji_events_rounded,
              label: 'Peringkat',
              isActive: true,
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
