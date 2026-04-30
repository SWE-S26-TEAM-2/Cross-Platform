import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/subscription_provider.dart';
import '../subscription/stripe_helper.dart';

// ── Payment Bottom Sheet ─────────────────────────────────────────────────────

void showPaymentSheet(BuildContext context, WidgetRef ref, UpgradePlan plan) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _PaymentBottomSheet(plan: plan, ref: ref),
  );
}

class _PaymentBottomSheet extends StatefulWidget {
  const _PaymentBottomSheet({required this.plan, required this.ref});
  final UpgradePlan plan;
  final WidgetRef ref;

  @override
  State<_PaymentBottomSheet> createState() => _PaymentBottomSheetState();
}

class _PaymentBottomSheetState extends State<_PaymentBottomSheet> {
  bool _cardComplete = false;

  @override
  Widget build(BuildContext context) {
    final subState = widget.ref.watch(subscriptionProvider);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF111111),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Subscribe to ${widget.plan.title}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              widget.plan.price,
              style: TextStyle(color: Colors.grey[400], fontSize: 14),
            ),
            const SizedBox(height: 20),
            CardInputWidget(
              onCardChanged: (details) {
                setState(() => _cardComplete = details?.complete ?? false);
              },
            ),
            const SizedBox(height: 8),
            Text(
              'Test card: 4242 4242 4242 4242 · any future date · any CVC',
              style: TextStyle(color: Colors.grey[600], fontSize: 11),
            ),
            const SizedBox(height: 24),
            if (subState.error != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade900.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade700),
                ),
                child: Text(
                  subState.error ?? '',
                  style: TextStyle(color: Colors.red.shade300, fontSize: 13),
                ),
              ),
              const SizedBox(height: 16),
            ],
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: (!_cardComplete || subState.isUpgrading)
                    ? null
                    : () => _handleSubscribe(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF2F2F2),
                  disabledBackgroundColor: Colors.grey[700],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: subState.isUpgrading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.black,
                        ),
                      )
                    : const Text(
                        'Subscribe now',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSubscribe(BuildContext context) async {
    widget.ref.read(subscriptionProvider.notifier).clearError();
    final token = await StripeHelper.createToken(context);
    if (token == null || !mounted) return;

    final success = await widget.ref
        .read(subscriptionProvider.notifier)
        .upgrade(paymentToken: token, isYearly: widget.plan.isYearly);

    if (!mounted) return;
    if (success) {
      Navigator.of(context).pop();
      _showSuccessDialog(context);
    }
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 60,
              height: 60,
              decoration: const BoxDecoration(
                color: Color(0xFF4CD38A),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 34),
            ),
            const SizedBox(height: 16),
            const Text(
              "You're Premium!",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Welcome to ${widget.plan.title}. Enjoy all premium features.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 13,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF5500),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22),
                  ),
                ),
                child: const Text(
                  'Got it',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Upgrade Screen ───────────────────────────────────────────────────────────

class UpgradeScreen extends ConsumerStatefulWidget {
  const UpgradeScreen({super.key});

  @override
  ConsumerState<UpgradeScreen> createState() => _UpgradeScreenState();
}

class _UpgradeScreenState extends ConsumerState<UpgradeScreen> {
  final PageController _pageController = PageController(viewportFraction: 0.9);
  int _currentPage = 0;

  final List<UpgradePlan> _plans = const [
    UpgradePlan(
      title: 'Artist Pro',
      billingType: 'Monthly',
      price: '\$19.99/month',
      topColor: Color(0xFF6E3CC1),
      bottomColor: Color(0xFF9F35B3),
      isPro: true,
      features: [
        'Unlimited track uploads',
        'Get paid directly and more fairly',
        'Discover and connect with your biggest fans',
        'Unlimited distribution to all major streaming and social platforms',
      ],
    ),
    UpgradePlan(
      title: 'Artist Pro',
      billingType: 'Yearly',
      price: '\$149.99/year',
      topColor: Color(0xFFCC5978),
      bottomColor: Color(0xFFBA3A95),
      isPro: true,
      features: [
        'Unlimited track uploads',
        'Get paid directly and more fairly',
        'Discover and connect with your biggest fans',
        'Unlimited distribution to all major streaming and social platforms',
      ],
    ),
    UpgradePlan(
      title: 'Artist',
      billingType: 'Monthly',
      price: '\$9.99/month',
      topColor: Color(0xFFD06B77),
      bottomColor: Color(0xFFCC5C76),
      isPro: false,
      features: [
        '3 hours of uploads',
        '2 distributed and monetized tracks per month',
        'Discover and connect with your biggest fans',
        '3 replaceable tracks without losing stats per month',
      ],
    ),
    UpgradePlan(
      title: 'Artist',
      billingType: 'Yearly',
      price: '\$99.99/year',
      topColor: Color(0xFF980097),
      bottomColor: Color(0xFF97008D),
      isPro: false,
      features: [
        '3 hours of uploads',
        '2 distributed and monetized tracks per month',
        'Discover and connect with your biggest fans',
        '3 replaceable tracks without losing stats per month',
      ],
    ),
  ];

  final List<UpgradeFaq> _faqs = const [
    UpgradeFaq(
      question: "What's the difference between fan and artist plans?",
      answer:
          "Our Fan-oriented plans are designed for those who primarily visit the site to listen to SoundCloud's 250+ million tracks. Artist plans offer unique features designed to help artists create and distribute their music and content.",
    ),
    UpgradeFaq(
      question: 'Can I purchase an annual plan and/or family plan?',
      answer:
          'Unfortunately we do not currently offer an annual or family plan option for purchase in the app.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(subscriptionProvider.notifier).fetchStatus();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onSubscribePressed(UpgradePlan plan) {
    final subState = ref.read(subscriptionProvider);

    if (subState.isPremium) {
      final currentPlanIndex = _plans.lastIndexWhere(
        (p) => subState.isCurrentPlanFor(p.billingType),
      );
      final isThisCurrentPlan = currentPlanIndex == _plans.indexOf(plan);

      if (isThisCurrentPlan) {
        _showManageDialog();
        return;
      }

      _showChangePlanDialog(plan);
      return;
    }

    // Free user → open payment sheet
    showPaymentSheet(context, ref, plan);
  }

  void _showManageDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Manage Subscription',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'To cancel your subscription, go to your App Store or Play Store account settings and manage your active subscriptions from there.',
          style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Got it', style: TextStyle(color: Colors.orange)),
          ),
        ],
      ),
    );
  }

  void _showChangePlanDialog(UpgradePlan newPlan) {
    final subState = ref.read(subscriptionProvider);
    final currentCycle = subState.status?.billingCycle ?? 'current';

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Change Plan',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'You are currently on a $currentCycle plan. To switch to ${newPlan.billingType.toLowerCase()}, please cancel your current subscription first from your App Store or Play Store settings, then subscribe again.',
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 13,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white54),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Got it', style: TextStyle(color: Colors.orange)),
          ),
        ],
      ),
    );
  }

  void _openRestrictionsScreen(UpgradePlan plan) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => RestrictionsScreen(plan: plan)));
  }

  @override
  Widget build(BuildContext context) {
    final subState = ref.watch(subscriptionProvider);
    final currentPlan = _plans[_currentPage];
    final screenWidth = MediaQuery.of(context).size.width;

    final double titleFontSize = screenWidth < 380 ? 27 : 29;
    final double pageViewHeight = screenWidth < 380 ? 355 : 368;
    final double sectionTitleSize = screenWidth < 380 ? 20 : 21;
    final double horizontalPadding = screenWidth < 380 ? 24 : 28;

    return Scaffold(
      backgroundColor: currentPlan.bottomColor,
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [currentPlan.topColor, currentPlan.bottomColor],
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SafeArea(
                bottom: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),

                    // Premium status banner
                    if (subState.isPremium)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4CD38A).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: const Color(0xFF4CD38A),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.star_rounded,
                                color: Color(0xFF4CD38A),
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                "You're on Premium · ${subState.status?.billingCycle ?? ''}",
                                style: const TextStyle(
                                  color: Color(0xFF4CD38A),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        "What's next in music is first on SoundCloud",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: titleFontSize,
                          fontWeight: FontWeight.w700,
                          height: 1.08,
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),
                    SizedBox(
                      height: pageViewHeight,
                      child: AnimatedBuilder(
                        animation: _pageController,
                        builder: (context, child) {
                          // Find the single current plan index — last match wins
                          // (Artist over Artist Pro for same billing cycle)
                          final int currentPlanIndex = subState.isPremium
                              ? _plans.lastIndexWhere(
                                  (p) =>
                                      subState.isCurrentPlanFor(p.billingType),
                                )
                              : -1;

                          return PageView.builder(
                            controller: _pageController,
                            itemCount: _plans.length,
                            onPageChanged: (index) =>
                                setState(() => _currentPage = index),
                            itemBuilder: (context, index) {
                              double pageValue = _currentPage.toDouble();
                              if (_pageController.hasClients) {
                                try {
                                  pageValue =
                                      _pageController.page ??
                                      _currentPage.toDouble();
                                } catch (_) {}
                              }
                              final double distance = (pageValue - index)
                                  .abs()
                                  .clamp(0.0, 1.0);
                              final double scale = 1 - (distance * 0.08);
                              final double verticalPadding = distance * 8;
                              final double opacity = 1 - (distance * 0.16);

                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                curve: Curves.easeOut,
                                padding: EdgeInsets.fromLTRB(
                                  3,
                                  verticalPadding,
                                  3,
                                  verticalPadding,
                                ),
                                child: Transform.scale(
                                  scale: scale,
                                  child: Opacity(
                                    opacity: opacity,
                                    child: UpgradePlanCard(
                                      plan: _plans[index],
                                      isCurrentPlan: currentPlanIndex == index,
                                      isUpgrading: subState.isUpgrading,
                                      onSubscribePressed: () =>
                                          _onSubscribePressed(_plans[index]),
                                      onRestrictionsPressed: () =>
                                          _openRestrictionsScreen(
                                            _plans[index],
                                          ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    _PageIndicator(
                      count: _plans.length,
                      currentIndex: _currentPage,
                    ),
                    const SizedBox(height: 14),
                    const Center(
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 26),
                  ],
                ),
              ),
              Container(
                width: double.infinity,
                color: const Color(0xFF090909),
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  34,
                  horizontalPadding,
                  36,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SoundCloud supports independent artists',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: sectionTitleSize,
                        fontWeight: FontWeight.w700,
                        height: 1.12,
                      ),
                    ),
                    const SizedBox(height: 22),
                    const Text(
                      'From fan-powered royalties to our audience-building artist plans, your subscription helps support the SoundCloud global community.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13.5,
                        height: 1.42,
                      ),
                    ),
                    const SizedBox(height: 28),
                    const Text(
                      '"It\'s such a simple idea. Your monthly fees get split up between\nthe songs"',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        height: 1.4,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      '– RAC, musician and producer',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 28),
                    Center(
                      child: Container(
                        width: screenWidth < 380 ? 230 : 250,
                        height: screenWidth < 380 ? 230 : 250,
                        decoration: const BoxDecoration(shape: BoxShape.circle),
                        child: ClipOval(
                          child: Transform.scale(
                            scale: 1.2,
                            child: Image.asset(
                              'assets/images/RAC.png',
                              fit: BoxFit.cover,
                              alignment: const Alignment(1.2, -0.1),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    Text(
                      'Frequently asked questions',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: screenWidth < 380 ? 20 : 21,
                        fontWeight: FontWeight.w700,
                        height: 1.12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ..._faqs.map((faq) => UpgradeFaqTile(faq: faq)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Plan Card ────────────────────────────────────────────────────────────────

class UpgradePlanCard extends StatelessWidget {
  const UpgradePlanCard({
    super.key,
    required this.plan,
    required this.onSubscribePressed,
    required this.onRestrictionsPressed,
    this.isCurrentPlan = false,
    this.isUpgrading = false,
  });

  final UpgradePlan plan;
  final VoidCallback onSubscribePressed;
  final VoidCallback onRestrictionsPressed;
  final bool isCurrentPlan;
  final bool isUpgrading;

  bool get isYearly => plan.billingType == 'Yearly';

  String get _buttonLabel {
    if (isCurrentPlan) return 'Current plan ✓';
    return 'Subscribe now';
  }

  Color get _buttonColor {
    if (isCurrentPlan) return const Color(0xFF4CD38A);
    return const Color(0xFFF2F2F2);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      decoration: BoxDecoration(
        color: const Color(0xFF050505),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _UpgradeChip(
                text: 'FOR ARTISTS',
                backgroundColor: const Color(0xFF3B82F6),
                textColor: Colors.black,
              ),
              const SizedBox(width: 8),
              _UpgradeChip(
                text: plan.billingType,
                backgroundColor: isYearly
                    ? const Color(0xFFFF640A)
                    : const Color(0xFFA43AC7),
                textColor: Colors.black,
              ),
            ],
          ),
          const SizedBox(height: 9),
          Row(
            children: [
              Text(
                plan.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17.2,
                  fontWeight: FontWeight.w700,
                  height: 1,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                width: 18,
                height: 18,
                decoration: const BoxDecoration(
                  color: Color(0xFFFF640A),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.star_rounded,
                    color: Colors.white,
                    size: 10,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          Text(
            plan.price,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14.2,
              fontWeight: FontWeight.w700,
              height: 1,
            ),
          ),
          const SizedBox(height: 12),
          ...plan.features.map(
            (feature) => Padding(
              padding: const EdgeInsets.only(bottom: 7),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 1),
                    child: Icon(Icons.check, color: Colors.white, size: 15),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      feature,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12.2,
                        height: 1.2,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 4),
          SizedBox(
            width: double.infinity,
            height: 42,
            child: ElevatedButton(
              onPressed: isUpgrading ? null : onSubscribePressed,
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: _buttonColor,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                ),
                padding: EdgeInsets.zero,
              ),
              child: isUpgrading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.black,
                      ),
                    )
                  : Text(
                      _buttonLabel,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 13.8,
                        fontWeight: FontWeight.w700,
                        height: 1,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 14),
          if (!isCurrentPlan)
            const Text(
              'Cancel anytime.',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 11.4,
                height: 1.15,
              ),
            ),
          if (isCurrentPlan)
            GestureDetector(
              onTap: onSubscribePressed,
              child: const Text(
                'Manage subscription',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 11.4,
                  height: 1.15,
                  decoration: TextDecoration.underline,
                  decorationColor: Colors.white54,
                ),
              ),
            ),
          const SizedBox(height: 6),
          TextButton(
            onPressed: onRestrictionsPressed,
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: const Size(0, 0),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              alignment: Alignment.centerLeft,
            ),
            child: const Text(
              'Restrictions apply',
              style: TextStyle(
                color: Color(0xFF6EA3FF),
                fontSize: 12.6,
                height: 1.15,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Restrictions Screen ───────────────────────────────────────────────────────

class RestrictionsScreen extends StatelessWidget {
  const RestrictionsScreen({super.key, required this.plan});
  final UpgradePlan plan;

  static const String _termsUrl =
      'https://pages.soundcloud.com/geo/uk_us_ie/legal/terms-of-use-pro.ios.html?format=ios';
  static const String _privacyUrl =
      'https://pages.soundcloud.com/geo/uk_us_ie/legal/privacy-policy.ios.html?format=ios';

  Future<void> _launchUrl(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Could not open link')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF090909),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Restrictions apply',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Subscription may be managed and cancelled at any time in the App Store Account Settings after purchase. All prices include applicable local sales taxes. SoundCloud ${plan.title} Terms of Use & Privacy Policy',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      plan.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: () => _launchUrl(context, _termsUrl),
                      child: const Text(
                        'Terms of Use',
                        style: TextStyle(
                          color: Color(0xFF4A90E2),
                          fontSize: 15,
                          height: 1.8,
                          decoration: TextDecoration.underline,
                          decorationColor: Color(0xFF4A90E2),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _launchUrl(context, _privacyUrl),
                      child: const Text(
                        'Privacy Policy',
                        style: TextStyle(
                          color: Color(0xFF4A90E2),
                          fontSize: 15,
                          height: 1.8,
                          decoration: TextDecoration.underline,
                          decorationColor: Color(0xFF4A90E2),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Reusable widgets ─────────────────────────────────────────────────────────

class _UpgradeChip extends StatelessWidget {
  const _UpgradeChip({
    required this.text,
    required this.backgroundColor,
    required this.textColor,
  });
  final String text;
  final Color backgroundColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 23,
      padding: const EdgeInsets.symmetric(horizontal: 9),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(2),
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            color: textColor,
            fontSize: 9.1,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.65,
            height: 1,
          ),
        ),
      ),
    );
  }
}

class _PageIndicator extends StatelessWidget {
  const _PageIndicator({required this.count, required this.currentIndex});
  final int count;
  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(
          count,
          (index) => Container(
            margin: const EdgeInsets.symmetric(horizontal: 6),
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: index == currentIndex
                  ? Colors.black
                  : Colors.white.withOpacity(0.3),
            ),
          ),
        ),
      ),
    );
  }
}

class UpgradeFaqTile extends StatefulWidget {
  const UpgradeFaqTile({super.key, required this.faq});
  final UpgradeFaq faq;

  @override
  State<UpgradeFaqTile> createState() => _UpgradeFaqTileState();
}

class _UpgradeFaqTileState extends State<UpgradeFaqTile> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: () => setState(() => isExpanded = !isExpanded),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 18),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    widget.faq.question,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      height: 1.3,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Padding(
                  padding: const EdgeInsets.only(top: 1),
                  child: Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: Colors.white,
                    size: 23,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (isExpanded)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(
              widget.faq.answer,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ),
      ],
    );
  }
}

// ── Data models ──────────────────────────────────────────────────────────────

class UpgradePlan {
  final String title;
  final String billingType; // "Monthly" or "Yearly"
  final String price;
  final Color topColor;
  final Color bottomColor;
  final List<String> features;
  final bool isPro;

  const UpgradePlan({
    required this.title,
    required this.billingType,
    required this.price,
    required this.topColor,
    required this.bottomColor,
    required this.features,
    required this.isPro,
  });

  bool get isYearly => billingType == 'Yearly';
}

class UpgradeFaq {
  final String question;
  final String answer;
  const UpgradeFaq({required this.question, required this.answer});
}
