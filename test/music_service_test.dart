import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:my_project/services/music_service.dart';

void main() {
  late MusicService service;

  setUp(() {
    service = MusicService();
  });

  test('searchTracks returns a list', () async {
    final result = await service.searchTracks('test');

    expect(result, isA<List>());
  });

  test('searchTracks does not crash on empty result', () async {
    final result = await service.searchTracks('asldkjasldkjasldkj');

    expect(result, isA<List>());
  });
}
