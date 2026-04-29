import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/playlist.dart';
import '../services/playlist_service.dart';
import 'auth_providers.dart';

class PlaylistState {
  final List<Playlist> likedPlaylists;
  final List<Playlist> searchResults;
  final bool isLoadingLiked;
  final bool isSearching;
  final bool isCreating;
  final bool isLiking;
  final String? error;
  final String? successMessage;
  final bool isUpdating;

  const PlaylistState({
    this.likedPlaylists = const [],
    this.searchResults = const [],
    this.isLoadingLiked = false,
    this.isSearching = false,
    this.isCreating = false,
    this.isLiking = false,
    this.isUpdating = false,
    this.error,
    this.successMessage,
  });

  PlaylistState copyWith({
    List<Playlist>? likedPlaylists,
    List<Playlist>? searchResults,
    bool? isLoadingLiked,
    bool? isSearching,
    bool? isCreating,
    bool? isLiking,
    String? error,
    String? successMessage,
    bool clearError = false,
    bool clearSuccess = false,
    bool? isUpdating,
  }) {
    return PlaylistState(
      likedPlaylists: likedPlaylists ?? this.likedPlaylists,
      searchResults: searchResults ?? this.searchResults,
      isLoadingLiked: isLoadingLiked ?? this.isLoadingLiked,
      isSearching: isSearching ?? this.isSearching,
      isCreating: isCreating ?? this.isCreating,
      isLiking: isLiking ?? this.isLiking,
      isUpdating: isUpdating ?? this.isUpdating,
      error: clearError ? null : error ?? this.error,
      successMessage: clearSuccess
          ? null
          : successMessage ?? this.successMessage,
    );
  }
}

class PlaylistNotifier extends StateNotifier<PlaylistState> {
  final PlaylistService _service;
  final Ref ref;

  PlaylistNotifier(this._service, this.ref) : super(const PlaylistState());

  String? get _token => ref.read(authProvider).tokens?.accessToken;

  Future<void> fetchLikedPlaylists() async {
    final token = _token;

    if (token == null || token.isEmpty) {
      state = state.copyWith(
        error: 'No access token found. Please log in again.',
        clearSuccess: true,
      );
      return;
    }

    state = state.copyWith(
      isLoadingLiked: true,
      clearError: true,
      clearSuccess: true,
    );

    try {
      final playlists = await _service.getLikedPlaylists(token);

      state = state.copyWith(
        likedPlaylists: playlists,
        isLoadingLiked: false,
        clearError: true,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingLiked: false,
        error: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<Playlist?> getPlaylistDetails(String playlistId) async {
    final token = _token;

    if (token == null || token.isEmpty) {
      state = state.copyWith(
        error: 'No access token found. Please log in again.',
      );
      return null;
    }

    try {
      return await _service.getPlaylistById(
        playlistId: playlistId,
        accessToken: token,
      );
    } catch (e) {
      state = state.copyWith(
        error: e.toString().replaceFirst('Exception: ', ''),
      );
      return null;
    }
  }

  Future<void> searchPlaylists(String keyword) async {
    final token = _token;

    if (keyword.trim().isEmpty) {
      state = state.copyWith(searchResults: [], clearError: true);
      return;
    }

    if (token == null || token.isEmpty) {
      state = state.copyWith(
        error: 'No access token found. Please log in again.',
      );
      return;
    }

    state = state.copyWith(
      isSearching: true,
      clearError: true,
      clearSuccess: true,
    );

    try {
      final results = await _service.searchPlaylists(
        keyword: keyword.trim(),
        accessToken: token,
      );

      state = state.copyWith(
        searchResults: results,
        isSearching: false,
        clearError: true,
      );
    } catch (e) {
      state = state.copyWith(
        isSearching: false,
        error: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<void> likePlaylist(String playlistId) async {
    final token = _token;

    if (token == null || token.isEmpty) {
      state = state.copyWith(
        error: 'No access token found. Please log in again.',
      );
      return;
    }

    state = state.copyWith(
      isLiking: true,
      clearError: true,
      clearSuccess: true,
    );

    try {
      await _service.likePlaylist(playlistId: playlistId, accessToken: token);

      await fetchLikedPlaylists();

      state = state.copyWith(
        isLiking: false,
        successMessage: 'Playlist added to your playlists.',
      );
    } catch (e) {
      state = state.copyWith(
        isLiking: false,
        error: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<void> unlikePlaylist(String playlistId) async {
    final token = _token;

    if (token == null || token.isEmpty) {
      state = state.copyWith(error: 'No access token.');
      return;
    }

    state = state.copyWith(isUpdating: true, clearError: true);

    try {
      await _service.unlikePlaylist(playlistId: playlistId, accessToken: token);

      await fetchLikedPlaylists();

      state = state.copyWith(
        isUpdating: false,
        successMessage: 'Removed from your playlists.',
      );
    } catch (e) {
      state = state.copyWith(isUpdating: false, error: e.toString());
    }
  }

  Future<void> addTrack({
    required String playlistId,
    required String trackId,
  }) async {
    final token = _token;

    if (token == null) return;

    state = state.copyWith(isUpdating: true);

    try {
      await _service.addTrackToPlaylist(
        playlistId: playlistId,
        trackId: trackId,
        accessToken: token,
      );

      state = state.copyWith(
        isUpdating: false,
        successMessage: 'Track added successfully.',
      );
    } catch (e) {
      state = state.copyWith(isUpdating: false, error: e.toString());
    }
  }

  Future<bool> removeTrack({
    required String playlistId,
    required String trackId,
  }) async {
    final token = _token;

    if (token == null || token.isEmpty) {
      state = state.copyWith(error: 'No access token.');
      return false;
    }

    state = state.copyWith(isUpdating: true, clearError: true);

    try {
      await _service.removeTrackFromPlaylist(
        playlistId: playlistId,
        trackId: trackId,
        accessToken: token,
      );

      state = state.copyWith(
        isUpdating: false,
        successMessage: 'Track removed.',
      );

      return true;
    } catch (e) {
      final errorMsg = e.toString().replaceFirst('Exception: ', '');

      state = state.copyWith(isUpdating: false, error: errorMsg);

      if (errorMsg.contains('only edit your own playlists')) {
        return false;
      }

      return false;
    }
  }

  Future<void> uploadCover({
    required String playlistId,
    required String filePath,
  }) async {
    final token = _token;

    if (token == null) return;

    state = state.copyWith(isUpdating: true);

    try {
      await _service.uploadPlaylistCover(
        playlistId: playlistId,
        filePath: filePath,
        accessToken: token,
      );

      await fetchLikedPlaylists();

      state = state.copyWith(
        isUpdating: false,
        successMessage: 'Cover updated.',
      );
    } catch (e) {
      state = state.copyWith(isUpdating: false, error: e.toString());
    }
  }

  Future<Playlist?> createPlaylist({
    required String name,
    String? description,
  }) async {
    final token = _token;

    if (token == null || token.isEmpty) {
      state = state.copyWith(
        error: 'No access token found. Please log in again.',
      );
      return null;
    }

    state = state.copyWith(
      isCreating: true,
      clearError: true,
      clearSuccess: true,
    );

    try {
      final playlist = await _service.createPlaylist(
        accessToken: token,
        name: name,
        description: description,
      );

      await fetchLikedPlaylists();

      state = state.copyWith(
        isCreating: false,
        successMessage: 'Playlist created successfully.',
      );

      return playlist;
    } catch (e) {
      state = state.copyWith(
        isCreating: false,
        error: e.toString().replaceFirst('Exception: ', ''),
      );
      return null;
    }
  }

  void clearMessages() {
    state = state.copyWith(clearError: true, clearSuccess: true);
  }
}

final playlistProvider = StateNotifierProvider<PlaylistNotifier, PlaylistState>(
  (ref) {
    final service = PlaylistService(dio: Dio());
    return PlaylistNotifier(service, ref);
  },
);
