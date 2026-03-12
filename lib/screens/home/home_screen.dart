import 'package:flutter/material.dart';
import '../../constants/app_dimensions.dart';
import '../../mock_data/mock_tracks.dart';
import '../../widgets/your_likes_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.cloud_upload_outlined),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppDimensions.spaceSmall),
            YourLikesCard(tracks: MockTracks.likedTracks),
          ],
        ),
      ),
    );
  }
}
