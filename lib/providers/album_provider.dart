import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/album.dart';
import '../services/album_service.dart';
import 'auth_providers.dart';

class AlbumState {
  final List<Album> likedAlbums;
  final bool isLoadingLiked;
  final bool isWorking; // for non-list mutations (create, update, delete, …)
  final String? error;

  const AlbumState({
    this.likedAlbums = const [],
    this.isLoadingLiked = false,
    this.isWorking = false,
    this.error,
  });

  AlbumState copyWith({
    List<Album>? likedAlbums,
    bool? isLoadingLiked,
    bool? isWorking,
    String? error,
    bool clearError = false,
  }) {
    return AlbumState(
      likedAlbums: likedAlbums ?? this.likedAlbums,
      isLoadingLiked: isLoadingLiked ?? this.isLoadingLiked,
      isWorking: isWorking ?? this.isWorking,
      error: clearError ? null : error ?? this.error,
    );
  }
}

class AlbumNotifier extends StateNotifier<AlbumState> {
  final AlbumService _service;
  final Ref ref;

  AlbumNotifier(this._service, this.ref) : super(const AlbumState());

  String? get _token => ref.read(authProvider).tokens?.accessToken;

  final String _noToken = 'No access token found. Please log in again.';

  // ── Read ──────────────────────────────────────────────────────────────────

  Future<void> fetchLikedAlbums() async {
    final token = _token;
    if (token == null || token.isEmpty) {
      state = state.copyWith(error: _noToken);
      return;
    }

    state = state.copyWith(isLoadingLiked: true, clearError: true);
    try {
      final albums = await _service.getLikedAlbums(token);
      state = state.copyWith(likedAlbums: albums, isLoadingLiked: false);
    } catch (e) {
      state = state.copyWith(
        isLoadingLiked: false,
        error: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<Album?> getAlbumDetails(String albumId) async {
    final token = _token;
    if (token == null || token.isEmpty) {
      state = state.copyWith(error: _noToken);
      return null;
    }

    try {
      return await _service.getAlbumById(albumId: albumId, accessToken: token);
    } catch (e) {
      state = state.copyWith(
        error: e.toString().replaceFirst('Exception: ', ''),
      );
      return null;
    }
  }

  // ── Create ────────────────────────────────────────────────────────────────

  Future<Album?> createAlbum({
    required String title,
    String? description,
    String? releaseDate,
    String? genre,
  }) async {
    final token = _token;
    if (token == null || token.isEmpty) {
      state = state.copyWith(error: _noToken);
      return null;
    }

    state = state.copyWith(isWorking: true, clearError: true);
    try {
      final album = await _service.createAlbum(
        accessToken: token,
        title: title,
        description: description,
        releaseDate: releaseDate,
        genre: genre,
      );
      state = state.copyWith(isWorking: false);
      return album;
    } catch (e) {
      state = state.copyWith(
        isWorking: false,
        error: e.toString().replaceFirst('Exception: ', ''),
      );
      return null;
    }
  }

  // ── Update ────────────────────────────────────────────────────────────────

  Future<Album?> updateAlbum({
    required String albumId,
    String? title,
    String? description,
    String? releaseDate,
    String? genre,
  }) async {
    final token = _token;
    if (token == null || token.isEmpty) {
      state = state.copyWith(error: _noToken);
      return null;
    }

    state = state.copyWith(isWorking: true, clearError: true);
    try {
      final updated = await _service.updateAlbum(
        albumId: albumId,
        accessToken: token,
        title: title,
        description: description,
        releaseDate: releaseDate,
        genre: genre,
      );
      // Reflect update in the local liked list if the album is present.
      state = state.copyWith(
        isWorking: false,
        likedAlbums: state.likedAlbums
            .map((a) => a.id == albumId ? updated : a)
            .toList(),
      );
      return updated;
    } catch (e) {
      state = state.copyWith(
        isWorking: false,
        error: e.toString().replaceFirst('Exception: ', ''),
      );
      return null;
    }
  }

  // ── Delete ────────────────────────────────────────────────────────────────

  Future<bool> deleteAlbum(String albumId) async {
    final token = _token;
    if (token == null || token.isEmpty) {
      state = state.copyWith(error: _noToken);
      return false;
    }

    state = state.copyWith(isWorking: true, clearError: true);
    try {
      await _service.deleteAlbum(albumId: albumId, accessToken: token);
      state = state.copyWith(
        isWorking: false,
        likedAlbums: state.likedAlbums.where((a) => a.id != albumId).toList(),
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isWorking: false,
        error: e.toString().replaceFirst('Exception: ', ''),
      );
      return false;
    }
  }

  // ── Cover upload ──────────────────────────────────────────────────────────

  Future<String?> uploadCover({
    required String albumId,
    required String filePath,
  }) async {
    final token = _token;
    if (token == null || token.isEmpty) {
      state = state.copyWith(error: _noToken);
      return null;
    }

    state = state.copyWith(isWorking: true, clearError: true);
    try {
      final url = await _service.uploadAlbumCover(
        albumId: albumId,
        accessToken: token,
        filePath: filePath,
      );
      state = state.copyWith(isWorking: false);
      return url;
    } catch (e) {
      state = state.copyWith(
        isWorking: false,
        error: e.toString().replaceFirst('Exception: ', ''),
      );
      return null;
    }
  }

  // ── Like / Unlike ─────────────────────────────────────────────────────────

  Future<bool> likeAlbum(String albumId) async {
    final token = _token;
    if (token == null || token.isEmpty) {
      state = state.copyWith(error: _noToken);
      return false;
    }

    try {
      await _service.likeAlbum(albumId: albumId, accessToken: token);
      await fetchLikedAlbums(); // refresh list so the new album appears
      return true;
    } catch (e) {
      state = state.copyWith(
        error: e.toString().replaceFirst('Exception: ', ''),
      );
      return false;
    }
  }

  Future<bool> unlikeAlbum(String albumId) async {
    final token = _token;
    if (token == null || token.isEmpty) {
      state = state.copyWith(error: _noToken);
      return false;
    }

    try {
      await _service.unlikeAlbum(albumId: albumId, accessToken: token);
      state = state.copyWith(
        likedAlbums: state.likedAlbums.where((a) => a.id != albumId).toList(),
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        error: e.toString().replaceFirst('Exception: ', ''),
      );
      return false;
    }
  }

  // ── Track management ──────────────────────────────────────────────────────

  Future<bool> addTrack({
    required String albumId,
    required String trackId,
  }) async {
    final token = _token;
    if (token == null || token.isEmpty) {
      state = state.copyWith(error: _noToken);
      return false;
    }

    try {
      await _service.addTrackToAlbum(
        albumId: albumId,
        trackId: trackId,
        accessToken: token,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        error: e.toString().replaceFirst('Exception: ', ''),
      );
      return false;
    }
  }

  Future<bool> removeTrack({
    required String albumId,
    required String trackId,
  }) async {
    final token = _token;
    if (token == null || token.isEmpty) {
      state = state.copyWith(error: _noToken);
      return false;
    }

    try {
      await _service.removeTrackFromAlbum(
        albumId: albumId,
        trackId: trackId,
        accessToken: token,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        error: e.toString().replaceFirst('Exception: ', ''),
      );
      return false;
    }
  }

  Future<bool> reorderTracks({
    required String albumId,
    required List<String> trackIds,
  }) async {
    final token = _token;
    if (token == null || token.isEmpty) {
      state = state.copyWith(error: _noToken);
      return false;
    }

    try {
      await _service.reorderAlbumTracks(
        albumId: albumId,
        trackIds: trackIds,
        accessToken: token,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        error: e.toString().replaceFirst('Exception: ', ''),
      );
      return false;
    }
  }
}

final albumProvider = StateNotifierProvider<AlbumNotifier, AlbumState>((ref) {
  return AlbumNotifier(AlbumService(dio: Dio()), ref);
});
