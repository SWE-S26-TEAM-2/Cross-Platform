import '../models/track.dart';

class MockTracks {
  static const List<Track> likedTracks = [
    Track(
      id: '1',
      title: 'Track 1',
      artist: 'Artist 1',
      artworkUrl: '',
      likeCount: 1200,
      duration: 180,
    ),
    Track(
      id: '2',
      title: 'Track 4',
      artist: 'Artist 4',
      artworkUrl: '',
      likeCount: 4500,
      duration: 210,
    ),
    Track(
      id: '3',
      title: 'Track 2',
      artist: 'Artist 2',
      artworkUrl: '',
      likeCount: 890,
      duration: 195,
    ),
    Track(
      id: '4',
      title: 'Track 3',
      artist: 'Artist 3',
      artworkUrl: '',
      likeCount: 3200,
      duration: 240,
    ),
  ];

  static const Track hotTrack = Track(
    id: '5',
    title: 'Hot Track 1',
    artist: 'Artist 5',
    artworkUrl: '',
    likeCount: 1295,
    duration: 220,
  );

  static const List<Track> recommendedTracks = [
    Track(
      id: '6',
      title: 'Track 1',
      artist: 'Artist 1',
      artworkUrl: '',
      likeCount: 500,
      duration: 180,
    ),
    Track(
      id: '7',
      title: 'Track 2',
      artist: 'Artist 2',
      artworkUrl: '',
      likeCount: 700,
      duration: 200,
    ),
    Track(
      id: '8',
      title: 'Track 3',
      artist: 'Artist 3',
      artworkUrl: '',
      likeCount: 300,
      duration: 160,
    ),
    Track(
      id: '9',
      title: 'Track 4',
      artist: 'Artist 4',
      artworkUrl: '',
      likeCount: 900,
      duration: 190,
    ),
  ];
}
