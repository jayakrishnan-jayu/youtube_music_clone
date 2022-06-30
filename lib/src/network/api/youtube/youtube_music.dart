import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../models/music_model.dart';
import 'youtube_helper.dart';
import '../../utils/client/youtube_client.dart';
import '../../utils/network_utils.dart';
import '../../utils/enums.dart';

class YoutubeMusic {
  static const _baseUrl = 'https://music.youtube.com/';
  static String _context = '';
  static String _api = '';
  static String _version = '';
  static Map<String, String> _headers = {};

  static final _client = YoutubeClient(http.Client());

  YoutubeMusic._();

  static YoutubeMusic? _instance;

  // NOT SAFE
  static YoutubeMusic get instance => _instance!;

  static Future<YoutubeMusic> init() async {
    final Map ytcfg = {};
    try {
      await _client
          .get(Uri.parse(_baseUrl))
          .then((response) => response.body.split('ytcfg.set(').map((e) {
                try {
                  return jsonDecode(e.split(');')[0]);
                } catch (_) {}
              }).forEach((config) {
                if (config != null) ytcfg.addAll(config);
              }));
      if (!YoutubeHelper.isValidYtcfg(ytcfg)) {
        throw Exception('Invalid Youtube Config');
      }
      _context = YoutubeHelper.generateContext(ytcfg);
      _headers = YoutubeHelper.generateHeaders(ytcfg);
      _api = ytcfg['INNERTUBE_API_KEY'];
      // _api = 'AIzaSyAO_FJ2SlqU8Q4STEHLGCilw_Y9_11qcW8';
      _version = ytcfg['INNERTUBE_API_VERSION'];
      _instance ??= YoutubeMusic._();
      return _instance!;
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<String> _requestMusicUrl(
      {required String endpoint, required Map<String, String> query}) async {
    query['key'] = 'AIzaSyAO_FJ2SlqU8Q4STEHLGCilw_Y9_11qcW8';
    http.Response response = await _client.post(
        Uri.parse(
            '${_baseUrl}youtubei/$_version/$endpoint?${NetworkUtils.encodeMap(query)}'),
        body: jsonEncode({
          'context': {
            'client': {'clientName': 'ANDROID', 'clientVersion': '16.20'}
          }
        }));
    if (response.statusCode != 200) {
      throw Exception('Status Code: ${response.statusCode}');
    }

    return response.body;
  }

  Future<String> _request(
      {required String endpoint, required Map<String, String> query}) async {
    query['key'] = _api;

    http.Response response = await _client.post(
      Uri.parse(
          '${_baseUrl}youtubei/$_version/$endpoint?${NetworkUtils.encodeMap(query)}'),
      headers: _headers,
      body: _context,
    );
    if (response.statusCode != 200) {
      throw Exception('Status Code: ${response.statusCode}');
    }

    return response.body;
  }

  Future<SearchResult> search(String q, SearchType type) async {
    Map<String, String> query = {
      'query': q,
      'params': YoutubeHelper.getParams(type),
    };
    Map response = jsonDecode(await _request(endpoint: 'search', query: query));

    switch (type) {
      case SearchType.song:
        return YoutubeHelper.parseMusic(response);
      case SearchType.album:
        return YoutubeHelper.parseAlbum(response);
      case SearchType.artist:
        return YoutubeHelper.parseArtist(response);
      case SearchType.playlist:
        return YoutubeHelper.parsePlaylist(response);
    }
  }

  Future<List<AudioDetail>> getMusicUrl(String videoId) async {
    Map<String, String> query = {'videoId': videoId};
    Map response =
        jsonDecode(await _requestMusicUrl(endpoint: 'player', query: query));
    return YoutubeHelper.parseAudioDetails(response);
  }

  void close() => _client.close();
}
