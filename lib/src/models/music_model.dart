import '../network/api/youtube/youtube_music.dart';

abstract class SearchResult<E> {
  final String? continuation;
  final List<E> content;
  SearchResult(this.continuation, this.content);
}

class Thumbnail {
  final int width;
  final int height;
  final String url;
  Thumbnail({required this.width, required this.height, required this.url});

  @override
  String toString() => '($width, $height, $url)';
}

class Artist {
  final String name;
  final String browseId;
  final List<Thumbnail>? thumbnails;
  Artist({required this.name, required this.browseId, this.thumbnails});

  @override
  String toString() => '($name, $browseId)';
}

class Music {
  final String title;
  final String videoId;
  final String? playlistId;
  final String? duration;
  final List<Artist>? artists;
  final List<Thumbnail>? thumbnails;

  Music({
    required this.title,
    required this.videoId,
    this.playlistId,
    this.duration,
    this.artists,
    this.thumbnails,
  });

  List<AudioDetail>? _audioDetail;

  Future<List<AudioDetail>?> fetchAudioDetails() async {
    _audioDetail ??= await YoutubeMusic.instance.getMusicUrl(videoId);
    return _audioDetail;
  }

  @override
  String toString() => '$title, $_audioDetail';
}

class Album {
  final String name;
  final String browseId;
  final String? playlistId;
  final String? year;
  final List<Artist>? artists;
  final List<Thumbnail>? thumbnails;

  Album({
    required this.name,
    required this.browseId,
    this.playlistId,
    this.year,
    this.artists,
    this.thumbnails,
  });

  @override
  String toString() => name;
}

class Playlist {
  final String title;
  final String author;
  final String? trackCount;
  final String browseId;
  final List<Thumbnail> thumbnails;

  Playlist({
    required this.title,
    required this.author,
    this.trackCount,
    required this.browseId,
    required this.thumbnails,
  });

  @override
  String toString() => title;
}

class AudioDetail {
  final int itag;
  final int bitrate;
  final String mimeType;
  final String url;

  AudioDetail({
    required this.itag,
    required this.bitrate,
    required this.mimeType,
    required this.url,
  });

  @override
  String toString() => '($itag, $bitrate, $mimeType)';
}

class MusicSearchResult extends SearchResult<Music> {
  MusicSearchResult({String? continuation, required List<Music> content})
      : super(continuation, content);
}

class AlbumSearchResult extends SearchResult<Album> {
  AlbumSearchResult({String? continuation, required List<Album> content})
      : super(continuation, content);
}

class ArtistSearchResult extends SearchResult<Artist> {
  ArtistSearchResult({String? continuation, required List<Artist> content})
      : super(continuation, content);
}

class PlaylistSearchResult extends SearchResult<Playlist> {
  PlaylistSearchResult({String? continuation, required List<Playlist> content})
      : super(continuation, content);
}
