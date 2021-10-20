import 'dart:convert';

import '../../../models/music_model.dart';

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

  static List<MusicMetaModel> parseMusic(Map response) {
    List<MusicMetaModel> songs = [];
    try {
      MusicMetaModel.continuation = response['contents']
                      ['tabbedSearchResultsRenderer']['tabs'][0]['tabRenderer']
                  ['content']['sectionListRenderer']['contents'][0]
              ['musicShelfRenderer']['continuations'][0]['nextContinuationData']
          ['continuation'];

      response['contents']['tabbedSearchResultsRenderer']['tabs'][0]
                  ['tabRenderer']['content']['sectionListRenderer']['contents']
              [0]['musicShelfRenderer']['contents']
          .forEach((element) {
        List<ThumbnailModel> photos = [];
        element['musicResponsiveListItemRenderer']['thumbnail']
                ['musicThumbnailRenderer']['thumbnail']['thumbnails']
            .forEach((t) {
          photos.add(ThumbnailModel(
              url: t['url'], height: t['height'], width: t['width']));
        });

        songs.add(MusicMetaModel(
            title: element['musicResponsiveListItemRenderer']['flexColumns'][0]
                    ['musicResponsiveListItemFlexColumnRenderer']['text']
                ['runs'][0]['text'],
            videoId: element['musicResponsiveListItemRenderer']['menu']
                    ['menuRenderer']['items'][0]['menuNavigationItemRenderer']
                ['navigationEndpoint']['watchEndpoint']['videoId'],
            playlistId: element['musicResponsiveListItemRenderer']['menu']
                    ['menuRenderer']['items'][0]['menuNavigationItemRenderer']
                ['navigationEndpoint']['watchEndpoint']['playlistId'],
            duration: element['musicResponsiveListItemRenderer']['flexColumns'][1]['musicResponsiveListItemFlexColumnRenderer']['text']['runs'][4]['text'],
            artist: ArtistModel(
              name: element['musicResponsiveListItemRenderer']['flexColumns'][1]
                      ['musicResponsiveListItemFlexColumnRenderer']['text']
                  ['runs'][0]['text'],
              browseId: element['musicResponsiveListItemRenderer']
                              ['flexColumns'][1]
                          ['musicResponsiveListItemFlexColumnRenderer']['text']
                      ['runs'][0]['navigationEndpoint']['browseEndpoint']
                  ['browseId'],
            ),
            thumbnail: photos));
      });
      return songs;
    } catch (e) {
      throw Exception(e);
    }
  }
}
