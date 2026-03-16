import '../models/album.dart';

class MockAlbums {
  static const List<Album> featuredAlbums = [
    Album(
      id: 'a1',
      title: 'Certified Lover Boy',
      artist: 'Drake',
      artworkUrl: 'https://picsum.photos/seed/album1/150/150',
      trackCount: 21,
      releaseYear: 2021,
      likeCount: 320000,
      trackIds: ['1', '2'],
    ),
    Album(
      id: 'a2',
      title: 'Mr. Morale & The Big Steppers',
      artist: 'Kendrick Lamar',
      artworkUrl: 'https://picsum.photos/seed/album2/150/150',
      trackCount: 18,
      releaseYear: 2022,
      likeCount: 415000,
      trackIds: ['2'],
    ),
    Album(
      id: 'a3',
      title: 'After Hours',
      artist: 'The Weeknd',
      artworkUrl: 'https://picsum.photos/seed/album3/150/150',
      trackCount: 14,
      releaseYear: 2020,
      likeCount: 530000,
      trackIds: ['3'],
    ),
    Album(
      id: 'a4',
      title: 'Astroworld',
      artist: 'Travis Scott',
      artworkUrl: 'https://picsum.photos/seed/album4/150/150',
      trackCount: 17,
      releaseYear: 2018,
      likeCount: 480000,
      trackIds: ['4'],
    ),
  ];

  static const List<Album> recentAlbums = [
    Album(
      id: 'a5',
      title: 'GNX',
      artist: 'Kendrick Lamar',
      artworkUrl: 'https://picsum.photos/seed/album5/150/150',
      trackCount: 12,
      releaseYear: 2024,
      likeCount: 210000,
      trackIds: ['5'],
    ),
    Album(
      id: 'a6',
      title: 'Her Loss',
      artist: 'Drake & 21 Savage',
      artworkUrl: 'https://picsum.photos/seed/album6/150/150',
      trackCount: 16,
      releaseYear: 2022,
      likeCount: 290000,
      trackIds: ['7'],
    ),
    Album(
      id: 'a7',
      title: 'A Gift & A Curse',
      artist: 'Gunna',
      artworkUrl: 'https://picsum.photos/seed/album7/150/150',
      trackCount: 15,
      releaseYear: 2023,
      likeCount: 145000,
      trackIds: ['6'],
    ),
    Album(
      id: 'a8',
      title: 'Pluto x Baby Pluto',
      artist: 'Future & Lil Uzi Vert',
      artworkUrl: 'https://picsum.photos/seed/album8/150/150',
      trackCount: 18,
      releaseYear: 2020,
      likeCount: 178000,
      trackIds: [],
    ),
  ];

  static const Album spotlightAlbum = Album(
    id: 'a9',
    title: 'DAMN.',
    artist: 'Kendrick Lamar',
    artworkUrl: 'https://picsum.photos/seed/album9/150/150',
    trackCount: 14,
    releaseYear: 2017,
    likeCount: 892000,
    trackIds: ['2'],
  );
}
