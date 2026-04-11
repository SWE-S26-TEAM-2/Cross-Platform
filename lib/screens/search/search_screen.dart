import 'dart:async';
import 'package:flutter/material.dart';
import 'package:my_project/constants/app_colors.dart';
import 'package:my_project/constants/app_dimensions.dart';
import 'package:my_project/constants/app_text_styles.dart';
import 'package:my_project/models/track.dart';
import 'package:my_project/screens/search/search_bar.dart';
import 'package:my_project/mock_data/mock_tracks.dart';
import 'package:my_project/screens/search/vibes_section.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();

  List<Track> filteredTracks = [];
  Timer? _debounce;

  final List<Track> allTracks = [
    ...MockTracks.likedTracks,
    MockTracks.hotTrack,
    ...MockTracks.recommendedTracks,
  ];

  void _onSearchChanged(String query) {
    // cancel previous timer
    if (_debounce?.isActive ?? false) {
      _debounce!.cancel();
    }

    // start new timer (0.5s)
    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        if (query.isEmpty) {
          filteredTracks = [];
        } else {
          filteredTracks = allTracks
              .where(
                (track) =>
                    track.title.toLowerCase().contains(query.toLowerCase()),
              )
              .toList();
        }
      });
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isSearching = _controller.text.isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: const Text('Search')),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SearchBar1(
              controller: _controller,
              onChanged: _onSearchChanged, // 👈 use debounce here
            ),
            const SizedBox(height: 10),
            Expanded(
              child: isSearching
                  ? ListView.builder(
                      itemCount: filteredTracks.length,
                      itemBuilder: (context, index) {
                        final track = filteredTracks[index];

                        return Material(
                          color: AppColors.background,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(
                              AppDimensions.borderRadiusMedium,
                            ),
                            onTap: () {},
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppDimensions.spaceMedium,
                                vertical: AppDimensions.spaceMedium,
                              ),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(
                                      AppDimensions.borderRadiusSmall,
                                    ),
                                    child: Image.network(
                                      track.artworkUrl,
                                      width: 50,
                                      height: 50,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: AppDimensions.spaceMedium,
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        track.title,
                                        style: AppTextStyles.trackTitle,
                                      ),
                                      const SizedBox(
                                        height: AppDimensions.spaceExtraSmall,
                                      ),
                                      Text(
                                        track.artist,
                                        style: AppTextStyles.artistName,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    )
                  : const SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 20),
                        child: VibesSection(),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
