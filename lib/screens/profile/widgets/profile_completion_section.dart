import 'dart:math' as math;
import 'package:flutter/material.dart';

const Color kBackgroundColor = Color(0xFF0F0F0F);
const Color kCardBorderColor = Color(0xFF2A2A2A);
const Color kCompletedColor = Color(0xFF4CD38A);

class ProfileCompletionCardData {
  final IconData icon;
  final String title;
  final String description;
  final String buttonText;
  final bool isCompleted;
  final bool showButton;

  const ProfileCompletionCardData({
    required this.icon,
    required this.title,
    required this.description,
    required this.buttonText,
    required this.isCompleted,
    required this.showButton,
  });
}

class ProfileCompletionSection extends StatelessWidget {
  const ProfileCompletionSection({
    super.key,
    required this.cards,
    required this.completeCount,
    required this.isExpanded,
    required this.onToggleExpanded,
    this.onCardButtonPressed,
  });

  final List<ProfileCompletionCardData> cards;
  final int completeCount;
  final bool isExpanded;
  final VoidCallback onToggleExpanded;
  final ValueChanged<ProfileCompletionCardData>? onCardButtonPressed;

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double cardWidth = math.min(screenWidth * 0.54, 210.0);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Complete your profile',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '$completeCount OF ${cards.length} ',
                            style: const TextStyle(
                              color: Colors.orange,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                          TextSpan(
                            text: 'COMPLETE',
                            style: TextStyle(
                              color: Colors.grey[300],
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onToggleExpanded,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: 28,
                  minHeight: 28,
                ),
                splashRadius: 18,
                icon: Icon(
                  isExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ],
          ),
        ),
        if (isExpanded) ...[
          const SizedBox(height: 8),
          SizedBox(
            height: 205,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: cards.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                return ProfileCompletionCard(
                  card: cards[index],
                  width: cardWidth,
                  height: 205,
                  onButtonPressed: onCardButtonPressed,
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}

class ProfileCompletionCard extends StatelessWidget {
  const ProfileCompletionCard({
    super.key,
    required this.card,
    required this.width,
    required this.height,
    this.onButtonPressed,
  });

  final ProfileCompletionCardData card;
  final double width;
  final double height;
  final ValueChanged<ProfileCompletionCardData>? onButtonPressed;

  @override
  Widget build(BuildContext context) {
    final double iconCircleSize = (width * 0.23).clamp(52.0, 64.0);
    final double iconSize = (width * 0.085).clamp(20.0, 24.0);
    final double checkSize = (width * 0.075).clamp(18.0, 22.0);

    return SizedBox(
      width: width,
      height: height,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: kBackgroundColor,
          border: Border.all(color: kCardBorderColor),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: iconCircleSize,
                  height: iconCircleSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Icon(
                    card.icon,
                    size: iconSize,
                    color: Colors.white,
                  ),
                ),
                if (card.isCompleted)
                  Positioned(
                    right: -1,
                    bottom: -1,
                    child: Container(
                      width: checkSize,
                      height: checkSize,
                      decoration: const BoxDecoration(
                        color: kCompletedColor,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.black,
                        size: 11,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              card.title,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                height: 1.1,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              card.description,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 11,
                height: 1.15,
              ),
            ),
            const Spacer(),
            if (card.showButton)
              SizedBox(
                height: 30,
                child: OutlinedButton(
                  onPressed: () => onButtonPressed?.call(card),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 30),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                    backgroundColor: card.isCompleted
                        ? const Color(0xFF2B2B2B)
                        : Colors.transparent,
                    side: card.isCompleted
                        ? BorderSide.none
                        : BorderSide(color: Colors.grey.shade500, width: 1),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 0,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22),
                    ),
                  ),
                  child: Text(
                    card.buttonText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 11,
                      height: 1,
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