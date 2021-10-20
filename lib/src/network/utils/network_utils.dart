class NetworkUtils {
  static String encodeMap(Map q) {
    return q.keys
        .map((key) =>
            '${Uri.encodeComponent(key)}=${Uri.encodeComponent(q[key])}')
        .join('&');
  }
}