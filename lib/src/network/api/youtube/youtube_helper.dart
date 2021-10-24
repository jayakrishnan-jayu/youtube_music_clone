import 'dart:convert';
import '../../utils/enums.dart';

class YoutubeHelper {
  static bool isValidYtcfg(Map input) {
    for (String key in [
      'INNERTUBE_CLIENT_NAME',
      'INNERTUBE_CLIENT_VERSION',
      'INNERTUBE_API_KEY',
      'INNERTUBE_CONTEXT_CLIENT_NAME',
      'GL',
      'HL',
      'PAGE_CL',
      'PAGE_BUILD_LABEL'
    ]) {
      if (!input.containsKey(key)) return false;
    }
    return true;
  }

  static Map<String, String> generateHeaders(Map ytcfg) => {
        'x-origin': 'https://music.youtube.com/',
        // 'X-Goog-Visitor-Id': ytcfg['VISITOR_DATA'],
        'X-YouTube-Client-Name':
            ytcfg['INNERTUBE_CONTEXT_CLIENT_NAME'].toString(),
        'X-YouTube-Client-Version': ytcfg['INNERTUBE_CLIENT_VERSION'],
        // 'X-YouTube-Device': ytcfg['DEVICE'],
        'X-YouTube-Page-CL': ytcfg['PAGE_CL'].toString(),
        'X-YouTube-Page-Label': ytcfg['PAGE_BUILD_LABEL'],
        'X-YouTube-Utc-Offset': '330',
        'X-YouTube-Time-Zone': 'Asia/Calcutta',
      };

  static String generateContext(Map ytcfg) => jsonEncode({
        'context': {
          'capabilities': {},
          'client': {
            'clientName': ytcfg['INNERTUBE_CLIENT_NAME'],
            'clientVersion': ytcfg['INNERTUBE_CLIENT_VERSION'],
            'experimentIds': [],
            'experimentsToken': '',
            'gl': ytcfg['GL'],
            'hl': ytcfg['HL'],
            'locationInfo': {
              'locationPermissionAuthorizationStatus':
                  'LOCATION_PERMISSION_AUTHORIZATION_STATUS_UNSUPPORTED',
            },
            'musicAppInfo': {
              'musicActivityMasterSwitch':
                  'MUSIC_ACTIVITY_MASTER_SWITCH_INDETERMINATE',
              'musicLocationMasterSwitch':
                  'MUSIC_LOCATION_MASTER_SWITCH_INDETERMINATE',
              'pwaInstallabilityStatus': 'PWA_INSTALLABILITY_STATUS_UNKNOWN',
            },
            'utcOffsetMinutes': '330',
          },
          'request': {
            'internalExperimentFlags': [
              {
                'key': 'force_music_enable_outertube_tastebuilder_browse',
                'value': 'true',
              },
              {
                'key': 'force_music_enable_outertube_playlist_detail_browse',
                'value': 'true',
              },
              {
                'key': 'force_music_enable_outertube_search_suggestions',
                'value': 'true',
              },
            ],
            'sessionIndex': {},
          },
          'user': {
            'enableSafetyMode': false,
          },
        }
      });

  static String _getContinuation(Map response, {String defaultKey = ''}) {
    return response['contents']['tabbedSearchResultsRenderer']['tabs'][0]
                    ['tabRenderer']['content']['sectionListRenderer']
                ['contents'][0]['musicShelfRenderer']
            .containsKey('continuations')
        ? response['contents']['tabbedSearchResultsRenderer']['tabs'][0]
                    ['tabRenderer']['content']['sectionListRenderer']
                ['contents'][0]['musicShelfRenderer']['continuations'][0]
            ['nextContinuationData']['continuation']
        : defaultKey;
  }

  static List<dynamic> _getContent(Map response) => response['contents']
          ['tabbedSearchResultsRenderer']['tabs'][0]['tabRenderer']['content']
      ['sectionListRenderer']['contents'][0]['musicShelfRenderer']['contents'];

  static String _getName(Map element) =>
      element['musicResponsiveListItemRenderer']['flexColumns'][0]
              ['musicResponsiveListItemFlexColumnRenderer']['text']['runs'][0]
          ['text'];

  static List<dynamic> _getThumbnail(Map element) =>
      element['musicResponsiveListItemRenderer']['thumbnail']
          ['musicThumbnailRenderer']['thumbnail']['thumbnails'];

  static String _getBrowseId(Map element) =>
      element['musicResponsiveListItemRenderer']['navigationEndpoint']
          ['browseEndpoint']['browseId'];

  static List<dynamic> _getSection(Map element) =>
      element['musicResponsiveListItemRenderer']['flexColumns'][1]
          ['musicResponsiveListItemFlexColumnRenderer']['text']['runs'];

  static Map _getPlaylistEndpoint(Map element) =>
      element['musicResponsiveListItemRenderer']['menu']['menuRenderer']
          ['items'][0]['menuNavigationItemRenderer']['navigationEndpoint'];

  static String _getVideoId(Map element) =>
      element['musicResponsiveListItemRenderer']['menu']['menuRenderer']
              ['items'][0]['menuNavigationItemRenderer']['navigationEndpoint']
          ['watchEndpoint']['videoId'];

  static Map<String, dynamic> parseMusic(Map response) => {
        'continuation': _getContinuation(response),
        'content': _getContent(response).map((element) => {
              'title': _getName(element),
              'videoId': _getVideoId(element),
              'playlistId': _getPlaylistEndpoint(element)['watchEndpoint']
                  ['playlistId'],
              'duration': _getSection(element).last['text'],
              'artist': _getSection(element).runtimeType == [].runtimeType
                  ? _getSection(element)
                      .where((section) =>
                          section.containsKey('navigationEndpoint'))
                      .map((section) => {
                            'name': section['text'],
                            'browseId': section['navigationEndpoint']
                                ['browseEndpoint']['browseId'],
                          })
                      .toList(growable: false)
                  : [],
              'thumbnail': _getThumbnail(element)
            })
      };
  static Map<String, dynamic> parseAlbum(Map response) => {
        'continuation': _getContinuation(response),
        'content': _getContent(response).map((element) => {
              'type': _getSection(element).first['text'],
              'name': _getName(element),
              'browseId': _getBrowseId(element),
              'playlistId':
                  _getPlaylistEndpoint(element)['watchPlaylistEndpoint']
                      ['playlistId'],
              'year': _getSection(element).first['last'],
              'artist': _getSection(element)
                  .where((section) => section.containsKey('navigationEndpoint'))
                  .map((section) => {
                        'name': section['text'],
                        'browseId': section['navigationEndpoint']
                            ['browseEndpoint']['browseId'],
                      })
                  .toList(growable: false),
              'thumbnail': _getThumbnail(element)
            })
      };

  static Map<String, dynamic> parseArtist(Map response) => {
        'continuation': _getContinuation(response),
        'content': _getContent(response).map((element) => {
              'type': _getSection(element).first['text'],
              'name': _getName(element),
              'browseId': _getBrowseId(element),
              'thumbnail': _getThumbnail(element)
            })
      };

  static Map<String, dynamic> parsePlaylist(Map response) => {
        'continuation': _getContinuation(response),
        'content': _getContent(response).map((element) => {
              'title': _getName(element),
              'author': _getSection(element).first['text'],
              'trackCount': _getSection(element).last['text'],
              'browseId': _getBrowseId(element),
              'thumbnails': _getThumbnail(element)
            })
      };

  static String getParams(SearchType type) {
    switch (type) {
      case SearchType.song:
        return 'EgWKAQIIAWoMEAMQBBAJEA4QChAF';
      case SearchType.album:
        return 'EgWKAQIYAWoMEAMQBBAJEA4QChAF';
      case SearchType.artist:
        return 'EgWKAQIgAWoMEAMQBBAJEA4QChAF';
      case SearchType.playlist:
        return 'EgeKAQQoAEABagwQDhAKEAMQBBAFEAk%3D';
    }
  }
}
