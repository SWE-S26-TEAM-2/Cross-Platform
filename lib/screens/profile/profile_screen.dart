import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../mock_data/mock_tracks.dart';
import '../../providers/auth_providers.dart';
import 'widgets/profile_header_section.dart';
import 'widgets/profile_completion_section.dart';
import '../home/more_like_section.dart';
import 'widgets/profile_track_list_section.dart';
import 'edit_profile_screen.dart';

const Color kBackgroundColor = Color(0xFF0F0F0F);

const List<ProfileCompletionCardData> profileCompletionCards = [
  ProfileCompletionCardData(
    icon: Icons.camera_alt_outlined,
    title: 'Add a profile photo',
    description: 'Choose a photo to represent yourself on SoundCloud',
    buttonText: 'Add photo',
    isCompleted: false,
    showButton: true,
  ),
  ProfileCompletionCardData(
    icon: Icons.chat_bubble_outline,
    title: 'Add a bio',
    description: 'What should people know about you?',
    buttonText: 'Add bio',
    isCompleted: false,
    showButton: true,
  ),
  ProfileCompletionCardData(
    icon: Icons.image_outlined,
    title: 'Add a profile banner',
    description: 'Choose a banner to further personalize your profile',
    buttonText: 'Add banner',
    isCompleted: false,
    showButton: true,
  ),
  ProfileCompletionCardData(
    icon: Icons.email_outlined,
    title: 'Verify email',
    description: 'Go to your inbox and verify your account',
    buttonText: '',
    isCompleted: true,
    showButton: false,
  ),
  ProfileCompletionCardData(
    icon: Icons.person_outline,
    title: 'Add your name',
    description: "Add your name so your friends know it's you",
    buttonText: 'Edit name',
    isCompleted: true,
    showButton: true,
  ),
];

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool isProfileSectionExpanded = true;

  int get completeCount =>
      profileCompletionCards.where((card) => card.isCompleted).length;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    final size = MediaQuery.of(context).size;
    final screenHeight = size.height;

    final double sectionGap = (screenHeight * 0.018).clamp(18.0, 26.0);

    if (user == null) {
      return Scaffold(
        backgroundColor: kBackgroundColor,
        body: const SafeArea(
          child: Center(
            child: Text(
              'No profile data found',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ProfileHeaderSection(
                user: user,
                onBackPressed: () {
                  debugPrint('Back clicked');
                  Navigator.of(context).maybePop();
                },
                onMorePressed: () {
                  debugPrint('More clicked');
                },
                onEditPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const EditProfileScreen(),
                    ),
                  );
                },
                onShufflePressed: () {
                  debugPrint('Shuffle clicked');
                },
                onPlayPressed: () {
                  debugPrint('Play clicked');
                },
              ),
              SizedBox(height: sectionGap),
              ProfileCompletionSection(
                cards: profileCompletionCards,
                completeCount: completeCount,
                isExpanded: isProfileSectionExpanded,
                onToggleExpanded: () {
                  setState(() {
                    isProfileSectionExpanded = !isProfileSectionExpanded;
                  });
                },
                onCardButtonPressed: (card) {
                  debugPrint('${card.title} clicked');
                },
              ),
              SizedBox(height: sectionGap),
              MoreLikeSection(
                sectionTitle: 'Playlists',
                tracks: MockTracks.recommendedTracks,
                onTrackTap: (track) {
                  debugPrint('Playlist clicked: ${track.title}');
                },
              ),
              SizedBox(height: sectionGap),
              ProfileTrackListSection(
                title: 'Reposts',
                showSeeAll: true,
                tracks: MockTracks.recommendedTracks,
                onSeeAllTap: () {
                  debugPrint('See all reposts clicked');
                },
                onTrackTap: (track) {
                  debugPrint('Repost clicked: ${track.title}');
                },
                onMoreTap: (track) {
                  debugPrint('Repost more clicked: ${track.title}');
                },
              ),
              SizedBox(height: sectionGap),
              ProfileTrackListSection(
                title: 'Likes',
                showSeeAll: true,
                tracks: MockTracks.likedTracks,
                onSeeAllTap: () {
                  debugPrint('See all likes clicked');
                },
                onTrackTap: (track) {
                  debugPrint('Like clicked: ${track.title}');
                },
                onMoreTap: (track) {
                  debugPrint('Like more clicked: ${track.title}');
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
