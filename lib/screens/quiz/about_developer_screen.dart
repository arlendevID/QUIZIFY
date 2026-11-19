import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../routes/route_names.dart';

class AboutDeveloperScreen extends StatelessWidget {
  const AboutDeveloperScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(22, 18, 22, 118),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  _Header(),
                  SizedBox(height: 18),
                  _AboutQuizifyCard(),
                  SizedBox(height: 24),
                  _SectionTitle(title: 'Tim Pengembang'),
                  SizedBox(height: 14),
                  _TeamMemberCard(
                    icon: Icons.manage_accounts_rounded,
                    name: 'Alief Rasyidin',
                    role: 'Project Manager',
                    description:
                        'Mengelola arah pengembangan aplikasi, menyusun perencanaan proyek, serta memastikan setiap fitur berjalan sesuai tujuan dan kebutuhan pengguna.',
                    accentColor: AppColors.primary,
                  ),
                  SizedBox(height: 14),
                  _TeamMemberCard(
                    icon: Icons.code_rounded,
                    name: 'Arlen Dinova',
                    role: 'Lead Developer & Mobile Developer',
                    description:
                        'Mengembangkan sistem utama Quizify mulai dari antarmuka pengguna, alur aplikasi, integrasi backend, serta implementasi berbagai fitur utama agar aplikasi dapat berjalan dengan baik dan memberikan pengalaman pengguna yang nyaman.',
                    accentColor: AppColors.secondary,
                  ),
                  SizedBox(height: 14),
                  _TeamMemberCard(
                    icon: Icons.design_services_rounded,
                    name: 'Intan Nurjannah',
                    role: 'UI/UX Design & User Assurance',
                    description:
                        'Merancang pengalaman pengguna dan tampilan antarmuka agar tetap intuitif, nyaman digunakan, dan konsisten secara visual.',
                    accentColor: AppColors.info,
                  ),
                  SizedBox(height: 14),
                  _TeamMemberCard(
                    icon: Icons.fact_check_rounded,
                    name: 'Najwa',
                    role: 'Quality Assurance',
                    description:
                        'Melakukan pengujian fitur, validasi alur aplikasi, serta membantu memastikan kualitas dan stabilitas sistem.',
                    accentColor: AppColors.success,
                  ),
                  SizedBox(height: 14),
                  _TeamMemberCard(
                    icon: Icons.article_rounded,
                    name: 'Daffa Aqila',
                    role: 'Backend Developer',
                    description:
                        'Mengembangkan dan mengelola sisi backend aplikasi, API, database, serta mendukung integrasi data agar sistem berjalan dengan baik.',
                    accentColor: AppColors.warning,
                  ),
                  SizedBox(height: 24),
                  _ContactDeveloperCard(),
                  SizedBox(height: 18),
                  _FooterCard(),
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

class _Header extends StatelessWidget {
  const _Header();

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
          child: const Icon(Icons.info_rounded, color: Colors.white, size: 28),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            'Tentang Quizify',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.headingLarge.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }
}

class _AboutQuizifyCard extends StatelessWidget {
  const _AboutQuizifyCard();

  @override
  Widget build(BuildContext context) {
    return _InfoCard(
      title: 'Belajar Lebih Seru Bersama Quizify',
      icon: Icons.bolt_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quizify merupakan aplikasi pembelajaran interaktif berbasis kuis yang dirancang untuk menghadirkan pengalaman belajar yang lebih modern, menarik, dan efektif. Dengan berbagai kategori materi, sistem penilaian yang terstruktur, serta pendekatan gamifikasi, Quizify membantu pengguna meningkatkan pemahaman dan menguji kemampuan mereka melalui proses belajar yang lebih dinamis dan menyenangkan.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              height: 1.55,
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: AppTextStyles.headingMedium.copyWith(fontWeight: FontWeight.w900),
    );
  }
}

class _TeamMemberCard extends StatelessWidget {
  final IconData icon;
  final String name;
  final String role;
  final String description;
  final Color accentColor;

  const _TeamMemberCard({
    required this.icon,
    required this.name,
    required this.role,
    required this.description,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: accentColor.withValues(alpha: 0.20)),
            ),
            child: Icon(icon, color: accentColor, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppTextStyles.headingSmall.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  role,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: accentColor,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  description,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _InfoCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: AppColors.primary, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.headingSmall.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _ContactDeveloperCard extends StatelessWidget {
  const _ContactDeveloperCard();

  @override
  Widget build(BuildContext context) {
    return _InfoCard(
      title: 'Kontak Pengembang',
      icon: Icons.contact_support_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Punya pertanyaan, masukan, atau ide untuk pengembangan Quizify? Tim pengembang terbuka terhadap berbagai saran dan umpan balik untuk meningkatkan kualitas aplikasi di masa mendatang.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              height: 1.55,
            ),
          ),
          const SizedBox(height: 16),
          const _ContactItem(
            icon: Icons.email_rounded,
            label: 'Email',
            value: 'quizifydeveloper@gmail.com',
          ),
          const SizedBox(height: 12),
          const _ContactItem(
            icon: Icons.language_rounded,
            label: 'Website',
            value: 'www.quizify-learning.com',
          ),
          const SizedBox(height: 12),
          const _ContactItem(
            icon: Icons.camera_alt_rounded,
            label: 'Instagram',
            value: '@quizify.official',
          ),
        ],
      ),
    );
  }
}

class _ContactItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ContactItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: AppColors.primary, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTextStyles.labelMedium),
              const SizedBox(height: 3),
              Text(
                value,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FooterCard extends StatelessWidget {
  const _FooterCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Text(
            'Quizify v1.0.0',
            style: AppTextStyles.labelLarge.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '© 2026 Quizify Team',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
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
          Expanded(
            child: _BottomNavItem(
              icon: Icons.home_rounded,
              label: 'Beranda',
              onTap: () => _openTab(context, RouteNames.dashboard),
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
          const Expanded(
            child: _BottomNavItem(
              icon: Icons.info_rounded,
              label: 'About',
              isActive: true,
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
