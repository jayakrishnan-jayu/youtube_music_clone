class ArtistModel {
  final String name;
  final String browseId;
  ArtistModel({required this.name, required this.browseId});
}

class ThumbnailModel {
  final String url;
  final int height;
  final int width;
  ThumbnailModel({required this.url, required this.height, required this.width});
}

class MusicMetaModel {
  final String title;
  final String videoId;
  final String playlistId;
  final ArtistModel artist;
  final List<ThumbnailModel> thumbnail;
  final String duration;
  static String continuation = '';
  MusicMetaModel({required this.title, required this.videoId, required this.playlistId, required this.duration,
      required this.artist, required this.thumbnail});

}
