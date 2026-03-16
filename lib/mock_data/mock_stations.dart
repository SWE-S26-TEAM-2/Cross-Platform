import '../models/station.dart';

class MockStations {
  static const List<Station> featuredStations = [
    Station(
      id: 's1',
      title: 'Drake Radio',
      artworkUrl: 'https://picsum.photos/seed/station1/150/150',
      basedOn: 'Based on Drake',
      mood: 'Hype',
      likeCount: 94000,
      trackIds: ['1', '7'],
      trackCount: 2,
    ),
    Station(
      id: 's2',
      title: 'Late Night Vibes',
      artworkUrl: 'https://picsum.photos/seed/station2/150/150',
      basedOn: 'Based on The Weeknd',
      mood: 'Chill',
      likeCount: 76000,
      trackIds: ['3'],
      trackCount: 1,
    ),
    Station(
      id: 's3',
      title: 'Trap Nation',
      artworkUrl: 'https://picsum.photos/seed/station3/150/150',
      basedOn: 'Based on Travis Scott',
      mood: 'Hype',
      likeCount: 112000,
      trackIds: ['4', '8'],
      trackCount: 2,
    ),
    Station(
      id: 's4',
      title: 'Focus Mode',
      artworkUrl: 'https://picsum.photos/seed/station4/150/150',
      basedOn: 'Based on your likes',
      mood: 'Focused',
      likeCount: 43000,
      trackIds: ['2', '6'],
      trackCount: 2,
    ),
  ];

  static const List<Station> recentStations = [
    Station(
      id: 's5',
      title: 'Good Mood',
      artworkUrl: 'https://picsum.photos/seed/station5/150/150',
      basedOn: 'Based on Gunna',
      mood: 'Chill',
      likeCount: 38000,
      trackIds: ['6'],
      trackCount: 1,
    ),
    Station(
      id: 's6',
      title: 'Rap Caviar',
      artworkUrl: 'https://picsum.photos/seed/station6/150/150',
      basedOn: 'Based on your likes',
      mood: 'Hype',
      likeCount: 201000,
      trackIds: ['1', '2', '4'],
      trackCount: 3,
    ),
    Station(
      id: 's7',
      title: 'Kendrick Mix',
      artworkUrl: 'https://picsum.photos/seed/station7/150/150',
      basedOn: 'Based on Kendrick Lamar',
      mood: 'Focused',
      likeCount: 88000,
      trackIds: ['2', '5'],
      trackCount: 2,
    ),
    Station(
      id: 's8',
      title: 'Night Drive',
      artworkUrl: 'https://picsum.photos/seed/station8/150/150',
      basedOn: 'Based on Future',
      mood: 'Chill',
      likeCount: 55000,
      trackIds: ['8'],
      trackCount: 1,
    ),
  ];

  static const Station spotlightStation = Station(
    id: 's9',
    title: 'Your Daily Mix',
    artworkUrl: 'https://picsum.photos/seed/station9/150/150',
    basedOn: 'Based on your listening history',
    mood: 'Hype',
    likeCount: 320000,
    trackIds: ['1', '2', '3', '4'],
    trackCount: 4,
  );
}
