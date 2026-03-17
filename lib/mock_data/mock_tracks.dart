import '../models/track.dart';

class MockTracks {
  static const List<Track> likedTracks = [
    Track(
      id: '1',
      title: 'God\'s Plan',
      artist: 'Drake',
      artworkUrl: 'https://picsum.photos/seed/track1/150/150',
      likeCount: 142000,
      duration: 198,
      audioPath:
          'assets/audio/tadashikeiji-gods-got-my-love-life-handled-319926.mp3',
    ),
    Track(
      id: '2',
      title: 'HUMBLE.',
      artist: 'Kendrick Lamar',
      artworkUrl: 'https://picsum.photos/seed/track2/150/150',
      likeCount: 98700,
      duration: 177,
      audioPath:
          'assets/audio/tadashikeiji-gods-got-my-love-life-handled-319926.mp3',
    ),
    Track(
      id: '3',
      title: 'Blinding Lights',
      artist: 'The Weeknd',
      artworkUrl: 'https://picsum.photos/seed/track3/150/150',
      likeCount: 210500,
      duration: 200,
      audioPath:
          'assets/audio/tadashikeiji-gods-got-my-love-life-handled-319926.mp3',
    ),
    Track(
      id: '4',
      title: 'SICKO MODE',
      artist: 'Travis Scott',
      artworkUrl: 'https://picsum.photos/seed/track4/150/150',
      likeCount: 187300,
      duration: 312,
      audioPath:
          'assets/audio/tadashikeiji-gods-got-my-love-life-handled-319926.mp3',
    ),
  ];

  static const Track hotTrack = Track(
    id: '5',
    title: 'luther',
    artist: 'Kendrick Lamar ft. SZA',
    artworkUrl: 'https://picsum.photos/seed/track5/150/150',
    likeCount: 82000,
    duration: 228,
    audioPath:
        'assets/audio/tadashikeiji-gods-got-my-love-life-handled-319926.mp3',
  );

  static const List<Track> recommendedTracks = [
    Track(
      id: '6',
      title: 'fukumean',
      artist: 'Gunna',
      artworkUrl: 'https://picsum.photos/seed/track6/150/150',
      likeCount: 54000,
      duration: 149,
      audioPath:
          'assets/audio/tadashikeiji-gods-got-my-love-life-handled-319926.mp3',
    ),
    Track(
      id: '7',
      title: 'Rich Flex',
      artist: 'Drake & 21 Savage',
      artworkUrl: 'https://picsum.photos/seed/track7/150/150',
      likeCount: 76800,
      duration: 231,
      audioPath:
          'assets/audio/tadashikeiji-gods-got-my-love-life-handled-319926.mp3',
    ),
    Track(
      id: '8',
      title: 'Mask Off',
      artist: 'Future',
      artworkUrl: 'https://picsum.photos/seed/track8/150/150',
      likeCount: 43200,
      duration: 183,
      audioPath:
          'assets/audio/tadashikeiji-gods-got-my-love-life-handled-319926.mp3',
    ),
    Track(
      id: '9',
      title: 'ROCKSTAR',
      artist: 'DaBaby ft. Roddy Ricch',
      artworkUrl: 'https://picsum.photos/seed/track9/150/150',
      likeCount: 91500,
      duration: 178,
      audioPath:
          'assets/audio/tadashikeiji-gods-got-my-love-life-handled-319926.mp3',
    ),
  ];
}
