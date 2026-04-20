import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/playlist.dart';
import '../services/create_playlist_service.dart';
import 'auth_providers.dart';

class CreatePlaylistState {
  final bool isLoading;
  final Playlist? createdPlaylist;
  final String? error;
  final String? successMessage;

  const CreatePlaylistState({
    this.isLoading = false,
    this.createdPlaylist,
    this.error,
    this.successMessage,
  });
}

class CreatePlaylistNotifier extends StateNotifier<CreatePlaylistState> {
  final CreatePlaylistService _service;
  final Ref ref;

  CreatePlaylistNotifier(this._service, this.ref)
    : super(const CreatePlaylistState());

  Future<void> createPlaylist({
    required String name,
    String? description,
  }) async {
    final authState = ref.read(authProvider);
    final token = authState.tokens?.accessToken;

    if (token == null || token.isEmpty) {
      state = const CreatePlaylistState(
        error: 'No access token found. Please log in again.',
      );
      return;
    }

    state = const CreatePlaylistState(isLoading: true);

    try {
      final playlist = await _service.createPlaylist(
        accessToken: token,
        name: name,
        description: description,
      );

      state = CreatePlaylistState(
        createdPlaylist: playlist,
        successMessage: 'Playlist created successfully.',
      );
    } catch (e) {
      state = CreatePlaylistState(error: e.toString());
    }
  }

  void clearState() {
    state = const CreatePlaylistState();
  }
}

final createPlaylistProvider =
    StateNotifierProvider<CreatePlaylistNotifier, CreatePlaylistState>((ref) {
      final service = CreatePlaylistService(dio: Dio());
      return CreatePlaylistNotifier(service, ref);
    });
