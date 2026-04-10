import 'package:flutter/material.dart';

class UpgradeScreen extends StatefulWidget {
  const UpgradeScreen({super.key});

  @override
  State<UpgradeScreen> createState() => _UpgradeScreenState();
}

class _UpgradeScreenState extends State<UpgradeScreen> {
  final PageController _pageController = PageController(viewportFraction: 0.9);
  int _currentPage = 0;

  final List<UpgradePlan> _plans = const [
    UpgradePlan(
      title: 'Artist Pro',
      billingType: 'Monthly',
      price: 'EGP 164.99/month',
      topColor: Color(0xFF6E3CC1),
      bottomColor: Color(0xFF9F35B3),
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
      price: 'EGP 1,149.99/year',
      topColor: Color(0xFFCC5978),
      bottomColor: Color(0xFFBA3A95),
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
      price: 'EGP 65.00/month',
      topColor: Color(0xFFD06B77),
      bottomColor: Color(0xFFCC5C76),
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
      price: 'EGP 479.99/year',
      topColor: Color(0xFF980097),
      bottomColor: Color(0xFF97008D),
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
      question: "What’s the difference between fan and artist plans?",
      answer:
          "Our Fan-oriented plans are designed for those who primarily visit the site to listen to SoundCloud's 250+ million tracks. Artist plans offer unique features designed to help artists create and distribute their music and content.",
    ),
    UpgradeFaq(
      question: 'Can I purchase an annual plan and/or family plan?',
      answer:
          'Unfortunately we do not currently offer an annual or family plan option for purchase in the app.',
    ),
  ];

  void _onSubscribePressed(UpgradePlan plan) {
    // TODO: Connect this to backend/payment flow later
    debugPrint('Subscribe tapped: ${plan.title} - ${plan.billingType}');
  }

  void _openRestrictionsScreen(UpgradePlan plan) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => RestrictionsScreen(plan: plan)));
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                          return PageView.builder(
                            controller: _pageController,
                            itemCount: _plans.length,
                            onPageChanged: (index) {
                              setState(() {
                                _currentPage = index;
                              });
                            },
                            itemBuilder: (context, index) {
                              double pageValue = _currentPage.toDouble();

                              if (_pageController.hasClients) {
                                try {
                                  pageValue =
                                      _pageController.page ??
                                      _currentPage.toDouble();
                                } catch (_) {
                                  pageValue = _currentPage.toDouble();
                                }
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
                      "\"It's such a simple idea. Your monthly fees get split up between\nthe songs\"",
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

class UpgradePlanCard extends StatelessWidget {
  const UpgradePlanCard({
    super.key,
    required this.plan,
    required this.onSubscribePressed,
    required this.onRestrictionsPressed,
  });

  final UpgradePlan plan;
  final VoidCallback onSubscribePressed;
  final VoidCallback onRestrictionsPressed;

  bool get isYearly => plan.billingType == 'Yearly';

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
            crossAxisAlignment: CrossAxisAlignment.center,
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
              onPressed: onSubscribePressed,
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: const Color(0xFFF2F2F2),
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                ),
                padding: EdgeInsets.zero,
              ),
              child: const Text(
                'Subscribe now',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 13.8,
                  fontWeight: FontWeight.w700,
                  height: 1,
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Cancel anytime.',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 11.4,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 6),
          TextButton(
            onPressed: onRestrictionsPressed,
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF6EA3FF),
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
          onTap: () {
            setState(() {
              isExpanded = !isExpanded;
            });
          },
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

class RestrictionsScreen extends StatelessWidget {
  const RestrictionsScreen({super.key, required this.plan});

  final UpgradePlan plan;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF090909),
      appBar: AppBar(
        backgroundColor: const Color(0xFF090909),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Restrictions',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          '${plan.title} ${plan.billingType} restrictions screen.\n\n'
          'Replace this placeholder with the real restrictions content later.',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            height: 1.5,
          ),
        ),
      ),
    );
  }
}

class UpgradePlan {
  final String title;
  final String billingType;
  final String price;
  final Color topColor;
  final Color bottomColor;
  final List<String> features;

  const UpgradePlan({
    required this.title,
    required this.billingType,
    required this.price,
    required this.topColor,
    required this.bottomColor,
    required this.features,
  });
}

class UpgradeFaq {
  final String question;
  final String answer;

  const UpgradeFaq({required this.question, required this.answer});
}
