import 'package:flutter/material.dart';
import '../../mock_data/mock_users.dart';

const Color kBackgroundColor = Color(0xFF0F0F0F);

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isProfileSectionExpanded = true;

  @override
  Widget build(BuildContext context) {
    final user = mockUsers.last;

    final cards = [
      const ProfileCompletionCardData(
        icon: Icons.camera_alt_outlined,
        title: 'Add a profile photo',
        description: 'Choose a photo to represent yourself on SoundCloud',
        buttonText: 'Add photo',
        isCompleted: false,
        showButton: true,
      ),
      const ProfileCompletionCardData(
        icon: Icons.chat_bubble_outline,
        title: 'Add a bio',
        description: 'What should people know about you?',
        buttonText: 'Add bio',
        isCompleted: false,
        showButton: true,
      ),
      const ProfileCompletionCardData(
        icon: Icons.image_outlined,
        title: 'Add a profile banner',
        description: 'Choose a banner to further personalize your profile',
        buttonText: 'Add banner',
        isCompleted: false,
        showButton: true,
      ),
      const ProfileCompletionCardData(
        icon: Icons.email_outlined,
        title: 'Verify email',
        description: 'Go to your inbox and verify your account',
        buttonText: '',
        isCompleted: true,
        showButton: false,
      ),
      const ProfileCompletionCardData(
        icon: Icons.person_outline,
        title: 'Add your name',
        description: "Add your name so your friends know it's you",
        buttonText: 'Edit name',
        isCompleted: true,
        showButton: true,
      ),
    ];

    final completeCount = cards.where((card) => card.isCompleted).length;

    return Scaffold(
      backgroundColor: kBackgroundColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            debugPrint('Back pressed');
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_horiz, color: Colors.white),
            onPressed: () {
              debugPrint('More pressed');
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            color: kBackgroundColor,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// HEADER
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      height: 140,
                      width: double.infinity,
                      color: Colors.grey[700],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 90),
                          const CircleAvatar(
                            radius: 55,
                            backgroundColor: Colors.grey,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            user.userName ?? '',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user.location ?? '',
                            style: TextStyle(
                              color: Colors.grey[300],
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            '${user.followers ?? 0} Followers • ${user.following ?? 0} Following',
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 28),

                          /// ACTIONS
                          Row(
                            children: [
                              IconButton(
                                onPressed: () {
                                  debugPrint('Edit clicked');
                                },
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.white,
                                ),
                              ),
                              const Spacer(),
                              IconButton(
                                onPressed: () {
                                  debugPrint('Shuffle clicked');
                                },
                                icon: Icon(
                                  Icons.shuffle,
                                  color: Colors.grey[400],
                                ),
                              ),
                              const SizedBox(width: 16),
                              GestureDetector(
                                onTap: () {
                                  debugPrint('Play clicked');
                                },
                                child: Container(
                                  width: 64,
                                  height: 64,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[400],
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.play_arrow,
                                    color: Colors.black,
                                    size: 34,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 52),

                /// COMPLETE PROFILE
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Complete your profile',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: '$completeCount OF ${cards.length} ',
                                  style: const TextStyle(
                                    color: Colors.orange,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                TextSpan(
                                  text: 'COMPLETE',
                                  style: TextStyle(
                                    color: Colors.grey[300],
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            isProfileSectionExpanded =
                                !isProfileSectionExpanded;
                          });
                        },
                        icon: Icon(
                          isProfileSectionExpanded
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),

                /// CARDS
                if (isProfileSectionExpanded) ...[
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 290,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: cards.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 16),
                      itemBuilder: (context, index) {
                        return ProfileCompletionCard(card: cards[index]);
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

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

class ProfileCompletionCard extends StatelessWidget {
  final ProfileCompletionCardData card;

  const ProfileCompletionCard({super.key, required this.card});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: kBackgroundColor,
        border: Border.all(color: const Color(0xFF2A2A2A)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 84,
                height: 84,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Icon(card.icon, size: 32, color: Colors.white),
              ),
              if (card.isCompleted)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: const BoxDecoration(
                      color: Color(0xFF4CD38A),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.black,
                      size: 18,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            card.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            card.description,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[400]),
          ),
          const Spacer(),

          /// BUTTON FIXED ✅
          if (card.showButton)
            GestureDetector(
              onTap: () {
                debugPrint('${card.title} clicked');
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 26,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: card.isCompleted
                      ? const Color(0xFF2B2B2B)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(30),
                  border: card.isCompleted
                      ? null
                      : Border.all(color: Colors.grey),
                ),
                child: Text(
                  card.buttonText,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
