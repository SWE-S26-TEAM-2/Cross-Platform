import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_dimensions.dart';
import '../../constants/app_text_styles.dart';
import '../../providers/playlist_provider.dart';

enum CollectionType { playlist, album, station }

class CollectionTrack {
  final String id;
  final String title;
  final String artist;
  final String? secondaryArtist;
  final String artworkPath;
  final bool isAvailable;

  const CollectionTrack({
    required this.id,
    required this.title,
    required this.artist,
    this.secondaryArtist,
    required this.artworkPath,
    this.isAvailable = true,
  });
}

class CollectionDetailsData {
  final CollectionType type;
  final String title;
  final String artworkPath;
  final String ownerName;
  final String ownerAvatarPath;
  final String yearText;
  final String likesText;
  final List<CollectionTrack> tracks;

  const CollectionDetailsData({
    required this.type,
    required this.title,
    required this.artworkPath,
    required this.ownerName,
    required this.ownerAvatarPath,
    required this.yearText,
    required this.likesText,
    required this.tracks,
  });
}

class CollectionDetailsScreen extends ConsumerStatefulWidget {
  final String? playlistId;
  final CollectionDetailsData data;

  const CollectionDetailsScreen({
    super.key,
    this.playlistId,
    required this.data,
  });

  @override
  ConsumerState<CollectionDetailsScreen> createState() =>
      _CollectionDetailsScreenState();
}

class _CollectionDetailsScreenState
    extends ConsumerState<CollectionDetailsScreen> {
  late String _currentCoverPath;
  late List<CollectionTrack> _tracks;
  bool _isUploadingCover = false;
  String? _removingTrackId;

  @override
  void initState() {
    super.initState();
    _currentCoverPath = widget.data.artworkPath;
    _tracks = List.from(widget.data.tracks);
  }

  String get _typeLabel {
    switch (widget.data.type) {
      case CollectionType.playlist:
        return 'Playlist';
      case CollectionType.album:
        return 'Album';
      case CollectionType.station:
        return 'Station';
    }
  }

  String get _metaText {
    return '${widget.data.yearText} • $_typeLabel';
  }

  Future<void> _pickAndUploadCover() async {
    if (widget.playlistId == null || widget.playlistId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cover editing is only available for playlists.'),
        ),
      );
      return;
    }
    final picker = ImagePicker();

    final image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (image == null) return;

    setState(() {
      _isUploadingCover = true;
    });

    try {
      await ref
          .read(playlistProvider.notifier)
          .uploadCover(playlistId: widget.playlistId!, filePath: image.path);

      await ref.read(playlistProvider.notifier).fetchLikedPlaylists();

      if (!mounted) return;

      setState(() {
        _currentCoverPath = image.path;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cover updated successfully.')),
      );
    } catch (_) {
      if (!mounted) return;

      final error =
          ref.read(playlistProvider).error ?? 'Failed to upload cover.';

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
    } finally {
      if (mounted) {
        setState(() {
          _isUploadingCover = false;
        });
      }
    }
  }

  Future<void> _removeTrack(CollectionTrack track) async {
    if (widget.playlistId == null || widget.playlistId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Track removal is only available for playlists.'),
        ),
      );
      return;
    }
    print('REMOVING PLAYLIST ID: ${widget.playlistId}');
    print('REMOVING TRACK ID: ${track.id}');

    if (track.id.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Track ID is missing.')));
      return;
    }

    setState(() {
      _removingTrackId = track.id;
    });

    try {
      final success = await ref
          .read(playlistProvider.notifier)
          .removeTrack(playlistId: widget.playlistId!, trackId: track.id);

      if (!mounted) return;

      if (!success) {
        final error =
            ref.read(playlistProvider).error ?? 'Failed to remove track.';

        String message;

        if (error.contains('only edit your own playlists')) {
          message = 'You can only edit your own playlists';
        } else {
          message = error;
        }

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));

        return;
      }

      await ref.read(playlistProvider.notifier).fetchLikedPlaylists();

      setState(() {
        _tracks.removeWhere((item) => item.id == track.id);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Track removed from playlist.')),
      );
    } catch (_) {
      if (!mounted) return;

      final error =
          ref.read(playlistProvider).error ?? 'Failed to remove track.';

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
    } finally {
      if (mounted) {
        setState(() {
          _removingTrackId = null;
        });
      }
    }
  }

  void _showTrackOptions(CollectionTrack track) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.borderRadiusMedium),
        ),
      ),
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: AppDimensions.spaceMedium,
            ),
            child: ListTile(
              leading: const Icon(
                Icons.delete_outline,
                color: Colors.redAccent,
              ),
              title: const Text(
                'Remove from playlist',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                _removeTrack(track);
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.data;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(AppDimensions.spaceMedium),
                children: [
                  _TopSection(
                    data: data,
                    metaText: _metaText,
                    coverPath: _currentCoverPath,
                    isUploadingCover: _isUploadingCover,
                    onEditCover: _pickAndUploadCover,
                  ),
                  const SizedBox(height: AppDimensions.spaceLarge),
                  _ActionRow(likesText: data.likesText),
                  const SizedBox(height: AppDimensions.spaceLarge),
                  if (_tracks.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(
                          AppDimensions.borderRadiusMedium,
                        ),
                      ),
                      child: Text(
                        'This playlist has no tracks yet.',
                        style: AppTextStyles.caption.copyWith(
                          color: Colors.white70,
                          fontSize: 15,
                        ),
                      ),
                    )
                  else
                    ...List.generate(
                      _tracks.length,
                      (index) => Padding(
                        padding: EdgeInsets.only(
                          bottom: index == _tracks.length - 1
                              ? 0
                              : AppDimensions.spaceMedium,
                        ),
                        child: _TrackTile(
                          track: _tracks[index],
                          isRemoving: _removingTrackId == _tracks[index].id,
                          onMoreTap: () => _showTrackOptions(_tracks[index]),
                        ),
                      ),
                    ),
                  const SizedBox(height: 130),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopSection extends StatelessWidget {
  final CollectionDetailsData data;
  final String metaText;
  final String coverPath;
  final bool isUploadingCover;
  final VoidCallback onEditCover;

  const _TopSection({
    required this.data,
    required this.metaText,
    required this.coverPath,
    required this.isUploadingCover,
    required this.onEditCover,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: InkWell(
            borderRadius: BorderRadius.circular(100),
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
        ),
        const SizedBox(height: AppDimensions.spaceLarge),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                _CollectionImage(
                  path: coverPath,
                  width: 140,
                  height: 140,
                  borderRadius: AppDimensions.borderRadiusMedium,
                ),
                Positioned.fill(
                  child: Material(
                    color: Colors.black.withOpacity(0.28),
                    borderRadius: BorderRadius.circular(
                      AppDimensions.borderRadiusMedium,
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(
                        AppDimensions.borderRadiusMedium,
                      ),
                      onTap: isUploadingCover ? null : onEditCover,
                      child: Center(
                        child: isUploadingCover
                            ? const SizedBox(
                                width: 26,
                                height: 26,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Column(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Icon(
                                    Icons.add_a_photo_outlined,
                                    color: Colors.white,
                                    size: 26,
                                  ),
                                  SizedBox(height: 6),
                                  Text(
                                    'Edit cover',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: AppDimensions.spaceMedium),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.title,
                    style: AppTextStyles.heading1.copyWith(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    metaText,
                    style: AppTextStyles.caption.copyWith(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spaceMedium),
                  Row(
                    children: [
                      _CollectionAvatar(path: data.ownerAvatarPath),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'By ${data.ownerName}',
                          style: AppTextStyles.trackTitle.copyWith(
                            color: Colors.white70,
                            fontSize: 16,
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
      ],
    );
  }
}

class _ActionRow extends StatelessWidget {
  final String likesText;

  const _ActionRow({required this.likesText});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.favorite_border, color: Colors.white70, size: 30),
        const SizedBox(width: 8),
        Text(
          likesText,
          style: AppTextStyles.trackTitle.copyWith(
            color: Colors.white,
            fontSize: 18,
          ),
        ),
        const SizedBox(width: 16),
        const Icon(Icons.more_horiz, color: Colors.white70, size: 28),
        const Spacer(),
        const Icon(Icons.shuffle, color: Colors.white70, size: 30),
        const SizedBox(width: AppDimensions.spaceMedium),
        Container(
          width: 68,
          height: 68,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.play_arrow_rounded,
            color: Colors.black,
            size: 40,
          ),
        ),
      ],
    );
  }
}

class _TrackTile extends StatelessWidget {
  final CollectionTrack track;
  final bool isRemoving;
  final VoidCallback onMoreTap;

  const _TrackTile({
    required this.track,
    required this.isRemoving,
    required this.onMoreTap,
  });

  String get _artistLine {
    if (track.secondaryArtist == null ||
        track.secondaryArtist!.trim().isEmpty) {
      return track.artist;
    }
    return '${track.artist}, ${track.secondaryArtist}';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _CollectionImage(
          path: track.artworkPath,
          width: 74,
          height: 74,
          borderRadius: AppDimensions.borderRadiusMedium,
        ),
        const SizedBox(width: AppDimensions.spaceMedium),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                track.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.trackTitle.copyWith(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _artistLine,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.caption.copyWith(
                  color: Colors.white70,
                  fontSize: 15,
                ),
              ),
              if (!track.isAvailable) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.location_off,
                      color: Colors.white60,
                      size: 15,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Not available',
                      style: AppTextStyles.caption.copyWith(
                        color: Colors.white60,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: 10),
        if (isRemoving)
          const SizedBox(
            width: 26,
            height: 26,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        else
          IconButton(
            onPressed: onMoreTap,
            icon: const Icon(Icons.more_horiz, color: Colors.white70, size: 26),
          ),
      ],
    );
  }
}

class _CollectionImage extends StatelessWidget {
  final String path;
  final double width;
  final double height;
  final double borderRadius;

  const _CollectionImage({
    required this.path,
    required this.width,
    required this.height,
    required this.borderRadius,
  });

  String _fixMediaUrl(String url) {
    if (url.isEmpty) return '';

    if (url.startsWith('http')) return url;

    if (url.startsWith('/api/uploads')) {
      return 'https://streamline-swp.duckdns.org$url';
    }

    if (url.startsWith('/api/')) {
      return 'https://streamline-swp.duckdns.org$url';
    }

    if (url.startsWith('/')) {
      return 'https://streamline-swp.duckdns.org$url';
    }

    return url;
  }

  @override
  Widget build(BuildContext context) {
    if (path.isNotEmpty && File(path).existsSync()) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Image.file(
          File(path),
          width: width,
          height: height,
          fit: BoxFit.cover,
        ),
      );
    }

    final fixedPath = _fixMediaUrl(path);

    if (fixedPath.isEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Container(
          width: width,
          height: height,
          color: AppColors.surfaceLight,
          child: const Icon(Icons.queue_music, color: Colors.white70, size: 32),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Image.network(
        fixedPath,
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          width: width,
          height: height,
          color: AppColors.surfaceLight,
          child: const Icon(Icons.broken_image, color: Colors.white70),
        ),
      ),
    );
  }
}

class _CollectionAvatar extends StatelessWidget {
  final String path;

  const _CollectionAvatar({required this.path});

  String _fixMediaUrl(String url) {
    if (url.isEmpty) return '';

    if (url.startsWith('http')) return url;

    if (url.startsWith('/')) {
      return 'https://streamline-swp.duckdns.org$url';
    }

    return url;
  }

  @override
  Widget build(BuildContext context) {
    final fixedPath = _fixMediaUrl(path);

    if (fixedPath.isEmpty) {
      return const CircleAvatar(
        radius: 18,
        backgroundColor: AppColors.surfaceLight,
        child: Icon(Icons.person, color: Colors.white70, size: 18),
      );
    }

    return CircleAvatar(radius: 18, backgroundImage: NetworkImage(fixedPath));
  }
}
