import 'dart:convert';
import 'package:http/http.dart' as http;
import 'youtube_helper.dart';
import '../../utils/client/youtube_client.dart';
import '../../utils/network_utils.dart';

class YoutubeMusic {
  static const baseUrl = 'https://music.youtube.com/';
  String _context = '';
  String _api = '';
  String _version = '';
  Map<String, String> _headers = {};

  final _client = YoutubeClient(http.Client());

  Future<void> init() async {
    final Map ytcfg = {};
    try {
      await _client
          .get(Uri.parse(baseUrl))
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
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<String> _request(
      {required String endpoint, required Map<String, String> query}) async {
    query['key'] = _api;
    http.Response response = await _client.post(
      Uri.parse(
          '${baseUrl}youtubei/$_version/$endpoint?${NetworkUtils.encodeMap(query)}'),
      headers: _headers,
      body: _context,
    );
    if (response.statusCode != 200) {
      throw Exception('Status Code: ${response.statusCode}');
    }

    return response.body;
  }

  Future<void> search(String q) async {
    Map<String, String> query = {
      'query': q,
      'params': 'Eg-KAQwIARAAGAAgACgAMABqChAEEAMQCRAFEAo%3D',
    };
    Map response = jsonDecode(await _request(endpoint: 'search', query: query));
    YoutubeHelper.parseMusic(response);
  }

  void close() => _client.close();
}
