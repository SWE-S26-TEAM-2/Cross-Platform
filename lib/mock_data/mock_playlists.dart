import '../models/playlist.dart';

class MockPlaylists {
  static List<Playlist> get playlists => [
    Playlist(
      id: 'p1',
      userId: 'THRILLHO',
      name: 'Somatic  -  Deep Bass  -  Brain Massage',
      description: '',
      coverUrl: '',
      isPublic: true,
      trackCount: 23,
      tracks: [],
    ),
    Playlist(
      id: 'p2',
      userId: 'Hana_Ahmed',
      name: 'kennedy walsh jams',
      description: '',
      coverUrl: '',
      isPublic: true,
      trackCount: 112,
      tracks: [],
    ),
    Playlist(
      id: 'p3',
      userId: 'New!',
      name: 'Buzzing Indie',
      description: '',
      coverUrl: '',
      isPublic: true,
      trackCount: 25,
      tracks: [],
    ),
    Playlist(
      id: 'p4',
      userId: 'SoundCloud',
      name: 'Your Mix 1',
      description: '',
      coverUrl: '',
      isPublic: false,
      trackCount: 0,
      tracks: [],
    ),
  ];
}
