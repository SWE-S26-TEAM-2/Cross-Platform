import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_dimensions.dart';
import '../../constants/app_text_styles.dart';
import '../../models/track.dart';
import '../../models/user.dart';
import '../../mock_data/mock_tracks.dart';
import 'widgets/track_tile.dart';
import 'context_menu_sheet.dart';

enum UploadsSortOption { recentlyAdded, firstAdded, trackName }

class UploadsScreen extends StatefulWidget {
  final VoidCallback? onBack;
  final User? currentUser;
  const UploadsScreen({super.key, this.onBack, this.currentUser});

  @override
  State<UploadsScreen> createState() => _UploadsScreenState();
}

class _UploadsScreenState extends State<UploadsScreen> {
  UploadsSortOption _sortOption = UploadsSortOption.recentlyAdded;
  final TextEditingController _searchController = TextEditingController();
  List<Track> _filteredTracks = [];
  List<Track> _userTracks = [];

  @override
  void initState() {
    super.initState();
    _userTracks = MockTracks.recentlyPlayedTracks
        .where(
          (t) =>
              t.artist.toLowerCase() ==
              (widget.currentUser?.userName ?? '').toLowerCase(),
        )
        .toList();
    _filteredTracks = List.from(_userTracks);
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
      _filteredTracks = _userTracks
          .where(
            (t) =>
                t.title.toLowerCase().contains(query) ||
                t.artist.toLowerCase().contains(query),
          )
          .toList();
    });
  }

  void _applySort(UploadsSortOption option) {
    setState(() {
      _sortOption = option;
      switch (option) {
        case UploadsSortOption.recentlyAdded:
          _filteredTracks = List.from(_userTracks);
          break;
        case UploadsSortOption.firstAdded:
          _filteredTracks = List.from(_userTracks.reversed);
          break;
        case UploadsSortOption.trackName:
          _filteredTracks.sort((a, b) => a.title.compareTo(b.title));
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
                selected: _sortOption == UploadsSortOption.recentlyAdded,
                onTap: () {
                  Navigator.pop(context);
                  _applySort(UploadsSortOption.recentlyAdded);
                },
              ),
              _SortOption(
                label: 'First Added',
                selected: _sortOption == UploadsSortOption.firstAdded,
                onTap: () {
                  Navigator.pop(context);
                  _applySort(UploadsSortOption.firstAdded);
                },
              ),
              _SortOption(
                label: 'Track Name',
                selected: _sortOption == UploadsSortOption.trackName,
                onTap: () {
                  Navigator.pop(context);
                  _applySort(UploadsSortOption.trackName);
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
          // ── Header ──────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Stack(
              children: [
                Positioned(
                  right: -30,
                  top: -10,
                  child: _StackedRectsDecoration(),
                ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8, 12, 16, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                                  decoration: InputDecoration(
                                    hintText:
                                        'Search ${_userTracks.length} tracks',
                                    hintStyle: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 14,
                                    ),
                                    prefixIcon: const Icon(
                                      Icons.search,
                                      color: AppColors.textSecondary,
                                      size: 20,
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(
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

                        const Padding(
                          padding: EdgeInsets.only(
                            left: AppDimensions.spaceSmall,
                          ),
                          child: Text(
                            'Your uploads',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Empty state or track list ────────────────────────────────
          if (_userTracks.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.spaceMedium),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'No uploads yet',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Your uploads will show up here.',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spaceLarge),
                    _UploadButton(),
                  ],
                ),
              ),
            )
          else ...[
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => TrackTile(
                  track: _filteredTracks[index],
                  onTap: () {},
                  onMoreTap: () =>
                      showTrackContextMenu(context, _filteredTracks[index]),
                ),
                childCount: _filteredTracks.length,
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.spaceMedium),
                child: _UploadButton(),
              ),
            ),
          ],

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}

class _UploadButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {}, // hook up later
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Upload a track',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8),
          Icon(
            Icons.cloud_upload_outlined,
            color: AppColors.textPrimary,
            size: 32,
          ),
        ],
      ),
    );
  }
}

class _StackedRectsDecoration extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      height: 220,
      child: Stack(
        children: List.generate(6, (i) {
          final offset = i * 12.0;
          return Positioned(
            right: offset,
            top: offset,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.purple.withOpacity(0.15 + i * 0.04),
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(
                  AppDimensions.borderRadiusSmall,
                ),
              ),
            ),
          );
        }),
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
