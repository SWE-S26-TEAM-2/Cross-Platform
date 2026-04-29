import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_dimensions.dart';
import '../../constants/app_text_styles.dart';

class InsightsScreen extends StatefulWidget {
  final VoidCallback? onBack;
  const InsightsScreen({super.key, this.onBack});

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: Colors.white, size: 28),
          onPressed: () => widget.onBack?.call(),
        ),
        title: const Text('Your insights', style: AppTextStyles.heading2),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.textPrimary,
          indicatorWeight: 2,
          labelColor: AppColors.textPrimary,
          unselectedLabelColor: AppColors.textMuted,
          labelStyle: AppTextStyles.trackTitle,
          unselectedLabelStyle: AppTextStyles.artistName,
          tabs: [
            const Tab(text: 'SoundCloud'),
            const Tab(text: 'All Platforms'),
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Fans'),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(
                        AppDimensions.borderRadiusPill,
                      ),
                    ),
                    child: const Text(
                      'NEW',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_SoundCloudTab(), _AllPlatformsTab(), _FansTab()],
      ),
    );
  }
}

// ── SoundCloud tab ──────────────────────────────────────────────────────────
class _SoundCloudTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.spaceMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppDimensions.spaceMedium),

          // Illustration placeholder
          Container(
            width: double.infinity,
            height: 220,
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(
                AppDimensions.borderRadiusSmall,
              ),
            ),
            child: Center(
              child: Icon(
                Icons.equalizer_rounded,
                size: 80,
                color: AppColors.primary.withOpacity(0.6),
              ),
            ),
          ),

          const SizedBox(height: AppDimensions.spaceLarge),

          const Text(
            "Get unmatched insights into your listeners that you won't find anywhere else.",
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.w800,
              height: 1.3,
            ),
          ),

          const SizedBox(height: AppDimensions.spaceMedium),

          const Text(
            'SoundCloud is the only platform that lets you easily identify and connect with your top fans based on their listening and engagement habits.',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 15,
              height: 1.5,
            ),
          ),

          const SizedBox(height: AppDimensions.spaceMedium),

          const Text(
            'To get started, all it takes is an upload.',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 15,
              height: 1.5,
            ),
          ),

          const SizedBox(height: AppDimensions.spaceLarge),

          _PromoButton(label: 'Upload', onTap: () {}),

          const SizedBox(height: 100),
        ],
      ),
    );
  }
}

// ── All Platforms tab ───────────────────────────────────────────────────────
class _AllPlatformsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.spaceMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppDimensions.spaceMedium),

          // Illustration placeholder
          Container(
            width: double.infinity,
            height: 260,
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(
                AppDimensions.borderRadiusSmall,
              ),
            ),
            child: Center(
              child: Icon(
                Icons.multitrack_audio_rounded,
                size: 80,
                color: Colors.purple.withOpacity(0.6),
              ),
            ),
          ),

          const SizedBox(height: AppDimensions.spaceLarge),

          const Text(
            'Unlock key performance and audience insights across multiple platforms for your music',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.w800,
              height: 1.3,
            ),
          ),

          const SizedBox(height: AppDimensions.spaceMedium),

          const Text(
            'Access audience and performance insights for your distributed tracks from Spotify, Apple Music, and SoundCloud all from one dashboard.',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 15,
              height: 1.5,
            ),
          ),

          const SizedBox(height: AppDimensions.spaceMedium),

          const Text(
            'Upgrade your account, upload and distribute your track to get started.',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 15,
              height: 1.5,
            ),
          ),

          const SizedBox(height: AppDimensions.spaceLarge),

          _PromoButton(label: 'Upgrade to Artist Pro', onTap: () {}),

          const SizedBox(height: 100),
        ],
      ),
    );
  }
}

// ── Fans tab ────────────────────────────────────────────────────────────────
class _FansTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.spaceMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppDimensions.spaceMedium),

          // Illustration placeholder
          Container(
            width: double.infinity,
            height: 260,
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(
                AppDimensions.borderRadiusSmall,
              ),
            ),
            child: Center(
              child: Icon(
                Icons.people_alt_rounded,
                size: 80,
                color: Colors.redAccent.withOpacity(0.6),
              ),
            ),
          ),

          const SizedBox(height: AppDimensions.spaceLarge),

          const Text(
            'Connect with your biggest fans',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.w800,
              height: 1.3,
            ),
          ),

          const SizedBox(height: AppDimensions.spaceMedium),

          const Text(
            "See which fans are your most engaged and connect directly with them to create fans for life. Other platforms call them followers - we know they are way more than that. Your fans are your day ones, your biggest supporters, your best promoters.",
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 15,
              height: 1.5,
            ),
          ),

          const SizedBox(height: AppDimensions.spaceMedium),

          const Text(
            'Get to know your fans - start today.',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 15,
              height: 1.5,
            ),
          ),

          const SizedBox(height: AppDimensions.spaceMedium),

          const Text(
            'Available to Artist Pro subscribers.',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.bold,
              height: 1.5,
            ),
          ),

          const SizedBox(height: AppDimensions.spaceLarge),

          _PromoButton(label: 'Upgrade to Artist Pro', onTap: () {}),

          const SizedBox(height: 100),
        ],
      ),
    );
  }
}

// ── Shared outlined CTA button ──────────────────────────────────────────────
class _PromoButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _PromoButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.textPrimary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              AppDimensions.borderRadiusSmall,
            ),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
