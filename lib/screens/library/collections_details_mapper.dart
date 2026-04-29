import '../../models/album.dart';
import '../../models/playlist.dart';
import 'collections_screen.dart';

/// Maps domain models → [CollectionDetailsData] for [CollectionDetailsScreen].
class CollectionDetailsMapper {
  CollectionDetailsMapper._();

  static CollectionDetailsData fromAlbum(Album album) {
    return CollectionDetailsData(
      type: CollectionType.album,
      title: album.title,
      artworkPath: album.artworkUrl,
      ownerName: album.artist,
      ownerAvatarPath: album.artworkUrl, // use artwork as fallback avatar
      yearText: album.releaseYear.toString(),
      likesText: album.likeCount.toString(),
      tracks: [], // populate when track data is available
    );
  }

  static CollectionDetailsData fromPlaylist(Playlist playlist) {
    return CollectionDetailsData(
      type: CollectionType.playlist,
      title: playlist.name,
      artworkPath: playlist.coverUrl,
      ownerName: playlist.owner,
      ownerAvatarPath: playlist.coverUrl,
      yearText: '${playlist.trackCount} tracks', // ← was playlist.duration
      likesText: playlist.owner, // ← was playlist.trackCount
      tracks: [],
    );
  }
}
