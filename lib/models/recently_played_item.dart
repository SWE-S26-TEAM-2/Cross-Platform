import 'package:my_project/models/album.dart';
import 'package:my_project/models/playlist.dart';

sealed class RecentlyPlayedItem {}

class RecentlyPlayedPlaylist extends RecentlyPlayedItem {
  final Playlist playlist;
  RecentlyPlayedPlaylist(this.playlist);
}

class RecentlyPlayedAlbum extends RecentlyPlayedItem {
  final Album album;
  RecentlyPlayedAlbum(this.album);
}
