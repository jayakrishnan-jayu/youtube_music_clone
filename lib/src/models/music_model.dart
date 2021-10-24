class ArtistModel {
  final String name;
  final String browseId;
  ArtistModel({required this.name, required this.browseId});
}

class ThumbnailModel {
  final String url;
  final int height;
  final int width;
  ThumbnailModel(
      {required this.url, required this.height, required this.width});
}

class MusicSearchResult {
  final String title;
  final String videoId;
  final String playlistId;
  final List<ArtistModel> artist;
  final List<ThumbnailModel> thumbnail;
  final String duration;
  static String continuation = '';
  MusicSearchResult(
      {required this.title,
      required this.videoId,
      required this.playlistId,
      required this.duration,
      required this.artist,
      required this.thumbnail});
}

class AlbumSearchResult {
  final String type;
  final String name;
  final String browseId;
  final String playlistId;
  final List<ArtistModel> artist;
  final List<ThumbnailModel> thumbnail;
  final String year;
  static String continuation = '';
  AlbumSearchResult({
    required this.type,
    required this.name,
    required this.browseId,
    required this.playlistId,
    required this.artist,
    required this.thumbnail,
    required this.year,
  });
}

class ArtistSearchResult extends ArtistModel {
  final String type;
  final List<ThumbnailModel> thumbnail;
  static String continuation = '';
  ArtistSearchResult(
      {required this.type,
      required String name,
      required String browseId,
      required this.thumbnail})
      : super(name: name, browseId: browseId);
}

class PlaylistSearchResult {
  final String browseId;
  final String title;
  final String author;
  final String tackCount;
  final List<ThumbnailModel> thumbnail;
  static String continuation = '';
  PlaylistSearchResult({
    required this.browseId,
    required this.title,
    required this.author,
    required this.tackCount,
    required this.thumbnail,
  });
}