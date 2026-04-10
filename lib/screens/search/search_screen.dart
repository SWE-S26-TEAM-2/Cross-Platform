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

   final List<Track> allTracks = [
    ...MockTracks.likedTracks,
    MockTracks.hotTrack,
    ...MockTracks.recommendedTracks
   ];

  void _filterTracks(String query) {
    setState(() {
      if (query.isEmpty)
      {
        filteredTracks = [];
      }
      else 
      {
        filteredTracks = allTracks
          .where((track) => track.title.toLowerCase().contains(query.toLowerCase()))
          .toList();
      }
    });
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
                onChanged: _filterTracks
              ),
              Expanded(
              child: isSearching
              ? ListView(
                children: filteredTracks.map(
                  (track) => Material(
                    color: AppColors.background,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
                      onTap: () {
                        print('Clicked ${track.title}');
                      },
                    child: Container(
                      decoration: const BoxDecoration(
                        //color: AppColors.background,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.spaceMedium,
                        vertical: AppDimensions.spaceMedium
                        ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(AppDimensions.borderRadiusSmall),
                            child: Image.network(
                              track.artworkUrl,
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: AppDimensions.spaceMedium,),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: AppDimensions.spaceExtraSmall,),
                              Text(
                                track.title,
                                style: AppTextStyles.trackTitle,
                              ),
                              const SizedBox(height: AppDimensions.spaceExtraSmall,),
                              Text(
                                track.artist,
                                style: AppTextStyles.artistName,
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                  ),
                ).toList(),
              )
              : VibesSection()
              )
            ],
          ),
        ),
      );
  }
}