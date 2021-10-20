import 'package:http/http.dart' as http;

class YoutubeClient extends http.BaseClient {
  final http.Client _client;
  YoutubeClient(this._client);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers['user-agent'] =
        'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/94.0.4606.81 Safari/537.36';
    request.headers['Accept-Language'] = 'en-US,en;q=0.5';
    return _client.send(request);
  }

  @override
  void close() {
    super.close();
    _client.close();
  }
}
