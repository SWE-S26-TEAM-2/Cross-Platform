import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/playlist.dart';
import '../services/playlist_service.dart';

const String testPlaylistId = '5d97a53d-d8d3-4a21-9489-decae4ae7bdd';

class PlaylistState {
  final Playlist? playlist;
  final bool isLoading;
  final String? error;

  const PlaylistState({
    this.playlist,
    this.isLoading = false,
    this.error,
  });
}

class PlaylistNotifier extends StateNotifier<PlaylistState> {
  final PlaylistService _playlistService;

  PlaylistNotifier(this._playlistService) : super(const PlaylistState());

  Future<void> fetchTestPlaylist() async {
    state = const PlaylistState(isLoading: true);

    try {
      final playlist = await _playlistService.getPlaylistById(testPlaylistId);
      state = PlaylistState(playlist: playlist);
    } catch (e) {
      state = PlaylistState(error: e.toString());
    }
  }
}

final playlistProvider =
    StateNotifierProvider<PlaylistNotifier, PlaylistState>((ref) {
      final service = PlaylistService(dio: Dio());
      return PlaylistNotifier(service);
    });