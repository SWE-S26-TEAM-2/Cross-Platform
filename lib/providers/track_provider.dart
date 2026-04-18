import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_project/models/track.dart';
import 'package:my_project/models/play_back.dart';
import 'package:my_project/services/tracks_service.dart';
import 'auth_providers.dart';

// ─── Service Provider ─────────────────────────────────────────────────────────

final tracksServiceProvider = Provider<TracksService>((ref) {
  final token = ref.watch(authProvider).tokens?.accessToken ?? '';
  final dio = Dio();

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        options.headers['Authorization'] = 'Bearer $token';
        handler.next(options);
      },
    ),
  );

  return TracksService(dio: dio);
});

// ─── GET /tracks/{track_id} ───────────────────────────────────────────────────

class TrackNotifier extends FamilyAsyncNotifier<Track, String> {
  @override
  Future<Track> build(String arg) async {
    try {
      return await ref.read(tracksServiceProvider).getTrack(trackId: arg);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('You are not logged in.');
      }
      if (e.response?.statusCode == 404) {
        throw Exception('Track not found.');
      }
      throw Exception('Could not load track. Please try again.');
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(tracksServiceProvider).getTrack(trackId: arg),
    );
  }
}

final trackProvider = AsyncNotifierProviderFamily<TrackNotifier, Track, String>(
  TrackNotifier.new,
);

// ─── POST /tracks/ ────────────────────────────────────────────────────────────

class CreateTrackNotifier extends AsyncNotifier<Track?> {
  @override
  Future<Track?> build() async => null;

  Future<Track> createTrack({
    required String title,
    required String description,
    required String filePath,
    String? genre,
    String? tags,
    String? releaseDate,
    String visibility = 'public',
  }) async {
    state = const AsyncLoading();
    try {
      final track = await ref
          .read(tracksServiceProvider)
          .createTrack(
            title: title,
            description: description,
            filePath: filePath,
            genre: genre,
            tags: tags,
            releaseDate: releaseDate,
            visibility: visibility,
          );
      state = AsyncData(track);
      return track;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('You are not logged in.');
      }
      if (e.response?.statusCode == 422) {
        throw Exception('Invalid track data. Please check your inputs.');
      }
      throw Exception('Could not upload track. Please try again.');
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}

final createTrackProvider = AsyncNotifierProvider<CreateTrackNotifier, Track?>(
  CreateTrackNotifier.new,
);

// ─── PUT /tracks/{track_id} ───────────────────────────────────────────────────

class UpdateTrackNotifier extends FamilyAsyncNotifier<Track?, String> {
  @override
  Future<Track?> build(String arg) async => null;

  Future<Track> updateTrack({
    String? title,
    String? description,
    String? genre,
    List<String>? tags,
    String? releaseDate,
    String? fileUrl,
    String? visibility,
  }) async {
    state = const AsyncLoading();
    try {
      final track = await ref
          .read(tracksServiceProvider)
          .updateTrack(
            trackId: arg,
            title: title,
            description: description,
            genre: genre,
            tags: tags,
            releaseDate: releaseDate,
            fileUrl: fileUrl,
            visibility: visibility,
          );
      state = AsyncData(track);
      // invalidate the single track cache so it reflects updates everywhere
      ref.invalidate(trackProvider(arg));
      return track;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('You are not logged in.');
      }
      if (e.response?.statusCode == 403) {
        throw Exception('You are not allowed to edit this track.');
      }
      if (e.response?.statusCode == 404) {
        throw Exception('Track not found.');
      }
      throw Exception('Could not update track. Please try again.');
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}

final updateTrackProvider =
    AsyncNotifierProviderFamily<UpdateTrackNotifier, Track?, String>(
      UpdateTrackNotifier.new,
    );

// ─── DELETE /tracks/{track_id} ────────────────────────────────────────────────

class DeleteTrackNotifier extends FamilyAsyncNotifier<void, String> {
  @override
  Future<void> build(String arg) async {}

  Future<void> deleteTrack() async {
    try {
      await ref.read(tracksServiceProvider).deleteTrack(trackId: arg);
      ref.invalidate(trackProvider(arg));
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('You are not logged in.');
      }
      if (e.response?.statusCode == 403) {
        throw Exception('You are not allowed to delete this track.');
      }
      if (e.response?.statusCode == 404) {
        throw Exception('Track not found.');
      }
      throw Exception('Could not delete track. Please try again.');
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}

final deleteTrackProvider =
    AsyncNotifierProviderFamily<DeleteTrackNotifier, void, String>(
      DeleteTrackNotifier.new,
    );

// ─── GET /tracks/{track_id}/waveform ─────────────────────────────────────────

class TrackWaveformNotifier extends FamilyAsyncNotifier<List<double>, String> {
  @override
  Future<List<double>> build(String arg) async {
    try {
      return await ref
          .read(tracksServiceProvider)
          .getTrackWaveform(trackId: arg);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return []; // waveform not generated yet
      }
      throw Exception('Could not load waveform. Please try again.');
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}

final trackWaveformProvider =
    AsyncNotifierProviderFamily<TrackWaveformNotifier, List<double>, String>(
      TrackWaveformNotifier.new,
    );

// ─── GET /tracks/{track_id}/stream ───────────────────────────────────────────

class TrackStreamUrlNotifier extends FamilyAsyncNotifier<String, String> {
  @override
  Future<String> build(String arg) async {
    try {
      return await ref
          .read(tracksServiceProvider)
          .getTrackStreamUrl(trackId: arg);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('You are not logged in.');
      }
      if (e.response?.statusCode == 404) {
        throw Exception('Track not found.');
      }
      throw Exception('Could not get stream URL. Please try again.');
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}

final trackStreamUrlProvider =
    AsyncNotifierProviderFamily<TrackStreamUrlNotifier, String, String>(
      TrackStreamUrlNotifier.new,
    );

// ─── POST /tracks/{track_id}/plays ───────────────────────────────────────────

class RecordPlayNotifier extends FamilyAsyncNotifier<void, String> {
  @override
  Future<void> build(String arg) async {}

  Future<void> recordPlay({int? durationListenedSeconds}) async {
    try {
      await ref
          .read(tracksServiceProvider)
          .recordPlay(
            trackId: arg,
            durationListenedSeconds: durationListenedSeconds,
          );
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('You are not logged in.');
      }
      if (e.response?.statusCode == 404) {
        throw Exception('Track not found.');
      }
      throw Exception('Could not record play. Please try again.');
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}

final recordPlayProvider =
    AsyncNotifierProviderFamily<RecordPlayNotifier, void, String>(
      RecordPlayNotifier.new,
    );

// ─── GET /tracks/{track_id}/playback ─────────────────────────────────────────

class TrackPlaybackNotifier extends FamilyAsyncNotifier<Playback, String> {
  @override
  Future<Playback> build(String arg) async {
    try {
      return await ref
          .read(tracksServiceProvider)
          .getTrackPlayback(trackId: arg);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('You are not logged in.');
      }
      if (e.response?.statusCode == 404) {
        throw Exception('Track not found.');
      }
      throw Exception('Could not load playback info. Please try again.');
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}

final trackPlaybackProvider =
    AsyncNotifierProviderFamily<TrackPlaybackNotifier, Playback, String>(
      TrackPlaybackNotifier.new,
    );
