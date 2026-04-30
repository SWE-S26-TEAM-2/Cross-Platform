import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_dimensions.dart';
import '../../constants/app_text_styles.dart';
import '../../models/track.dart';
import '../../models/user.dart';
import '../../providers/auth_providers.dart';
import '../../providers/track_provider.dart';
import '../../widgets/upload_track_sheet.dart';
import 'context_menu_sheet.dart';
import 'widgets/track_tile.dart';

enum UploadsSortOption { recentlyAdded, firstAdded, trackName }

class UploadsScreen extends ConsumerStatefulWidget {
  final VoidCallback? onBack;
  final User? currentUser;
  final Future<void> Function(Track track) onTrackTap;

  const UploadsScreen({
    super.key,
    this.onBack,
    this.currentUser,
    required this.onTrackTap,
  });

  @override
  ConsumerState<UploadsScreen> createState() => _UploadsScreenState();
}

class _UploadsScreenState extends ConsumerState<UploadsScreen> {
  UploadsSortOption _sortOption = UploadsSortOption.recentlyAdded;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String get _username {
    return widget.currentUser?.userName ??
        ref.read(authProvider).user?.userName ??
        '';
  }

  List<Track> _filterAndSortTracks(List<Track> tracks) {
    final query = _searchController.text.trim().toLowerCase();

    var result = tracks.where((track) {
      if (query.isEmpty) return true;
      return track.title.toLowerCase().contains(query) ||
          track.formattedArtist.toLowerCase().contains(query);
    }).toList();

    switch (_sortOption) {
      case UploadsSortOption.recentlyAdded:
        result.sort((a, b) {
          final aDate = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          final bDate = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          return bDate.compareTo(aDate);
        });
        break;
      case UploadsSortOption.firstAdded:
        result.sort((a, b) {
          final aDate = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          final bDate = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          return aDate.compareTo(bDate);
        });
        break;
      case UploadsSortOption.trackName:
        result.sort((a, b) => a.title.compareTo(b.title));
        break;
    }

    return result;
  }

  Future<void> _openUploadSheet() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      builder: (_) => const UploadTrackSheet(),
    );

    if (!mounted) return;

    final username = _username;
    if (username.isNotEmpty) {
      ref.invalidate(userTracksProvider(username));
    }
  }

  Future<void> _refreshUploads() async {
    final username = _username;
    if (username.isNotEmpty) {
      ref.invalidate(userTracksProvider(username));
    }
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
                  setState(() => _sortOption = UploadsSortOption.recentlyAdded);
                },
              ),
              _SortOption(
                label: 'First Added',
                selected: _sortOption == UploadsSortOption.firstAdded,
                onTap: () {
                  Navigator.pop(context);
                  setState(() => _sortOption = UploadsSortOption.firstAdded);
                },
              ),
              _SortOption(
                label: 'Track Name',
                selected: _sortOption == UploadsSortOption.trackName,
                onTap: () {
                  Navigator.pop(context);
                  setState(() => _sortOption = UploadsSortOption.trackName);
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
    final username = _username;

    if (username.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Center(
            child: Text(
              'Please log in to see your uploads.',
              style: AppTextStyles.caption.copyWith(color: Colors.white70),
            ),
          ),
        ),
      );
    }

    final uploadsAsync = ref.watch(userTracksProvider(username));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: _refreshUploads,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: _Header(
                onSortTap: _showSortBottomSheet,
                onBack: widget.onBack,
                searchController: _searchController,
              ),
            ),
            uploadsAsync.when(
              loading: () => const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (error, _) => SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppDimensions.spaceMedium),
                    child: Text(
                      error.toString(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ),
                ),
              ),
              data: (tracks) {
                final filteredTracks = _filterAndSortTracks(tracks);

                if (tracks.isEmpty) {
                  return SliverToBoxAdapter(
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
                          _UploadButton(onTap: _openUploadSheet),
                        ],
                      ),
                    ),
                  );
                }

                if (filteredTracks.isEmpty) {
                  return SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(AppDimensions.spaceMedium),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'No matching tracks.',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: AppDimensions.spaceLarge),
                          _UploadButton(onTap: _openUploadSheet),
                        ],
                      ),
                    ),
                  );
                }

                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => TrackTile(
                      track: filteredTracks[index],
                      onTap: () => widget.onTrackTap(filteredTracks[index]),
                      onMoreTap: () =>
                          showTrackContextMenu(context, filteredTracks[index]),
                    ),
                    childCount: filteredTracks.length,
                  ),
                );
              },
            ),
            uploadsAsync.maybeWhen(
              data: (tracks) {
                if (tracks.isEmpty) {
                  return const SliverToBoxAdapter(child: SizedBox.shrink());
                }

                return SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(AppDimensions.spaceMedium),
                    child: _UploadButton(onTap: _openUploadSheet),
                  ),
                );
              },
              orElse: () => const SliverToBoxAdapter(child: SizedBox.shrink()),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final VoidCallback onSortTap;
  final VoidCallback? onBack;
  final TextEditingController searchController;

  const _Header({
    required this.onSortTap,
    required this.onBack,
    required this.searchController,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(right: -30, top: -10, child: _StackedRectsDecoration()),
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
                      onPressed: () => onBack?.call(),
                    ),
                    Expanded(
                      child: Container(
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E1E1E),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: TextField(
                          controller: searchController,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 14,
                          ),
                          decoration: const InputDecoration(
                            hintText: 'Search your tracks',
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
                            contentPadding: EdgeInsets.symmetric(vertical: 10),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: onSortTap,
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
                  padding: EdgeInsets.only(left: AppDimensions.spaceSmall),
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
    );
  }
}

class _UploadButton extends StatelessWidget {
  final VoidCallback onTap;

  const _UploadButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
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
