import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../routes/route_names.dart';
import '../../services/api/auth_api.dart';
import '../../services/auth_session.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    try {
      await AuthApi.logout();
    } catch (_) {
      // Session lokal tetap dibersihkan walaupun request logout gagal.
    } finally {
      AuthSession.clear();

      if (context.mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          RouteNames.login,
          (route) => false,
        );
      }
    }
  }

  void _openPlaceholder(
    BuildContext context, {
    required String title,
    required IconData icon,
  }) {
    Navigator.pushNamed(
      context,
      RouteNames.adminPlaceholder,
      arguments: {'title': title, 'icon': icon},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Dashboard Admin'),
        backgroundColor: AppColors.background,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 8, 22, 28),
          child: ListView(
            children: [
              Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      gradient: AppColors.bluePurpleGradient,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Icon(
                      Icons.admin_panel_settings_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Dashboard Admin',
                      style: AppTextStyles.headingLarge.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _AdminMenuTile(
                title: 'Kelola Quiz & Soal',
                subtitle: 'Atur quiz template dan soal dari satu tempat.',
                icon: Icons.quiz_rounded,
                onTap: () =>
                    Navigator.pushNamed(context, RouteNames.adminQuizTemplates),
              ),
              const SizedBox(height: 14),
              _AdminMenuTile(
                title: 'Manajemen User',
                subtitle: 'Kelola data dan role pengguna.',
                icon: Icons.people_alt_rounded,
                onTap: () => _openPlaceholder(
                  context,
                  title: 'Manajemen User',
                  icon: Icons.people_alt_rounded,
                ),
              ),
              const SizedBox(height: 14),
              _AdminMenuTile(
                title: 'Statistik',
                subtitle: 'Placeholder statistik quiz dan aktivitas pengguna.',
                icon: Icons.bar_chart_rounded,
                onTap: () => _openPlaceholder(
                  context,
                  title: 'Statistik',
                  icon: Icons.bar_chart_rounded,
                ),
              ),
              const SizedBox(height: 14),
              _AdminMenuTile(
                title: 'Kategori',
                subtitle: 'Kelola kategori quiz.',
                icon: Icons.folder_rounded,
                onTap: () => _openPlaceholder(
                  context,
                  title: 'Kategori',
                  icon: Icons.folder_rounded,
                ),
              ),
              const SizedBox(height: 14),
              _AdminMenuTile(
                title: 'Pengumuman',
                subtitle: 'Kelola informasi untuk pengguna.',
                icon: Icons.campaign_rounded,
                onTap: () => _openPlaceholder(
                  context,
                  title: 'Pengumuman',
                  icon: Icons.campaign_rounded,
                ),
              ),
              const SizedBox(height: 14),
              _AdminMenuTile(
                title: 'Kelola Rekomendasi',
                subtitle: 'Struktur awal untuk quiz featured=true.',
                icon: Icons.star_rounded,
                onTap: () => _openPlaceholder(
                  context,
                  title: 'Kelola Rekomendasi',
                  icon: Icons.star_rounded,
                ),
              ),
              const SizedBox(height: 14),
              _AdminMenuTile(
                title: 'Logout',
                subtitle: 'Keluar dari akun admin.',
                icon: Icons.logout_rounded,
                onTap: () => _logout(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AdminMenuTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback? onTap;

  const _AdminMenuTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.surfaceSoft,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(icon, color: AppColors.primary),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.labelLarge.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(subtitle, style: AppTextStyles.bodySmall),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: onTap == null ? AppColors.textMuted : AppColors.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
