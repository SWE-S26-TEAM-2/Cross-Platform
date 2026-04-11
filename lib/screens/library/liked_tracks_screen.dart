import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_dimensions.dart';
import '../../constants/app_text_styles.dart';
import '../../models/track.dart';
import '../../mock_data/mock_tracks.dart';
import '../profile/widgets/profile_track_list_section.dart';

enum LikedTracksSortOption { recentlyAdded, firstAdded, trackName, artist }

class LikedTracksScreen extends StatefulWidget {
   final VoidCallback? onBack;
  const LikedTracksScreen({super.key, this.onBack});

  @override
  State<LikedTracksScreen> createState() => _LikedTracksScreenState();
}

class _LikedTracksScreenState extends State<LikedTracksScreen> {
  LikedTracksSortOption _sortOption = LikedTracksSortOption.recentlyAdded;
  final TextEditingController _searchController = TextEditingController();
  List<Track> _filteredTracks = [];
  List<Track> _allTracks = [];

  @override
  void initState() {
    super.initState();
    _allTracks = List.from(
      MockTracks.recentlyPlayedTracks,
    ); // will swap for liked tracks when ready
    _filteredTracks = List.from(_allTracks);
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredTracks = _allTracks
          .where(
            (t) =>
                t.title.toLowerCase().contains(query) ||
                t.artist.toLowerCase().contains(query),
          )
          .toList();
    });
  }

  void _applySort(LikedTracksSortOption option) {
    setState(() {
      _sortOption = option;
      switch (option) {
        case LikedTracksSortOption.recentlyAdded:
          _filteredTracks = List.from(_allTracks);
          break;
        case LikedTracksSortOption.firstAdded:
          _filteredTracks = List.from(_allTracks.reversed);
          break;
        case LikedTracksSortOption.trackName:
          _filteredTracks.sort((a, b) => a.title.compareTo(b.title));
          break;
        case LikedTracksSortOption.artist:
          _filteredTracks.sort((a, b) => a.artist.compareTo(b.artist));
          break;
      }
    });
  }

  void _showSortBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.borderRadiusMedium),
        ),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.symmetric(
            vertical: AppDimensions.spaceLarge,
            horizontal: AppDimensions.spaceMedium,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Sort by', style: AppTextStyles.heading2),
              const SizedBox(height: AppDimensions.spaceMedium),
              _SortOption(
                label: 'Recently Added',
                selected: _sortOption == LikedTracksSortOption.recentlyAdded,
                onTap: () {
                  Navigator.pop(context);
                  _applySort(LikedTracksSortOption.recentlyAdded);
                },
              ),
              _SortOption(
                label: 'First Added',
                selected: _sortOption == LikedTracksSortOption.firstAdded,
                onTap: () {
                  Navigator.pop(context);
                  _applySort(LikedTracksSortOption.firstAdded);
                },
              ),
              _SortOption(
                label: 'Track Name',
                selected: _sortOption == LikedTracksSortOption.trackName,
                onTap: () {
                  Navigator.pop(context);
                  _applySort(LikedTracksSortOption.trackName);
                },
              ),
              _SortOption(
                label: 'Artist',
                selected: _sortOption == LikedTracksSortOption.artist,
                onTap: () {
                  Navigator.pop(context);
                  _applySort(LikedTracksSortOption.artist);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // ── Header with heart background ──
          SliverToBoxAdapter(
            child: Stack(
              children: [
                // Big heart background
                Positioned(
                  right: -30,
                  top: -10,
                  child: Icon(
                    Icons.favorite,
                    size: 220,
                    color: AppColors.primary.withOpacity(0.25),
                  ),
                ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8, 12, 16, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Search bar row
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.chevron_left,
                                color: Colors.white,
                                size: 28,
                              ),
                              onPressed: () => widget.onBack?.call(),
                            ),
                            Expanded(
                              child: Container(
                                height: 40,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1E1E1E),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: TextField(
                                  controller: _searchController,
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 14,
                                  ),
                                  decoration: const InputDecoration(
                                    hintText: 'Search your likes',
                                    hintStyle: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 14,
                                    ),
                                    prefixIcon: Icon(
                                      Icons.search,
                                      color: AppColors.textSecondary,
                                      size: 20,
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(
                                      vertical: 10,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            GestureDetector(
                              onTap: _showSortBottomSheet,
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(
                                    AppDimensions.borderRadiusPill,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.sort,
                                  color: AppColors.primary,
                                  size: 22,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // "Your likes" title
                        const Padding(
                          padding: EdgeInsets.only(
                            left: AppDimensions.spaceSmall,
                          ),
                          child: Text(
                            'Your likes',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Shuffle + Play row
                        Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.shuffle,
                                  color: AppColors.textPrimary,
                                  size: 24,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _filteredTracks.shuffle();
                                  });
                                },
                              ),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: () {}, // hook up to player later
                                child: Container(
                                  width: 52,
                                  height: 52,
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.play_arrow,
                                    color: Colors.black,
                                    size: 30,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Track list ──
          SliverToBoxAdapter(
            child: ProfileTrackListSection(
              title: '',
              tracks: _filteredTracks,
              onTrackTap: (_) {}, // hook up to player later
              onMoreTap: (_) {}, // hook up context menu later
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}

class _SortOption extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _SortOption({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        label,
        style: TextStyle(
          color: selected ? AppColors.primary : AppColors.textPrimary,
          fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          fontSize: 15,
        ),
      ),
      trailing: selected
          ? const Icon(Icons.check, color: AppColors.primary, size: 20)
          : null,
      onTap: onTap,
    );
  }
}
