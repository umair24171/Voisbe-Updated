// import 'dart:convert';
// import 'dart:developer';
// import 'package:flutter/widgets.dart';
// import 'package:http/http.dart' as http;
// import 'package:provider/provider.dart';
// import 'package:social_notes/spotify/methods/model/provider/tracks_provider.dart';
// import 'package:social_notes/spotify/methods/model/track_model.dart';
// import 'package:youtube_explode_dart/youtube_explode_dart.dart';

// class SpotifyClass {
//   void getToken(BuildContext context) async {
//     var clientId = '80846bfe55954603b3e3febe6e29a5a0';
//     var clientSecret = '3258982fb9474592be55a800c2053f1b';

//     var bytes = utf8.encode('$clientId:$clientSecret');
//     var base64Str = base64.encode(bytes);

//     var url = 'https://accounts.spotify.com/api/token';
//     var headers = {'Authorization': 'Basic $base64Str'};
//     var body = {'grant_type': 'client_credentials'};

//     var response =
//         await http.post(Uri.parse(url), headers: headers, body: body);

//     if (response.statusCode == 200) {
//       var data = jsonDecode(response.body);
//       var token = data['access_token'];
//       log('Token: $token');
//       // http.Response response1 = await http.get(
//       //     Uri.parse('https://api.spotify.com/v1/me/playlists'),
//       //     headers: {'Authorization': 'Bearer $token'});
//       // var playlists = jsonDecode(response1.body);
//       // log(playlists.toString());
//       // log(token);
//       // getAndDisplayTracks(token);
//       // displayAllTracks(token);
//       chatGptPlay(token, context);
//     }
//   }

//   Future<void> fetchAllTracks(String accessToken, BuildContext context) async {
//     try {
//       final response = await http.get(
//         Uri.parse(
//             'https://api.spotify.com/v1/albums/4aawyAB9vmqN3uQ7FjRGTy/tracks'),
//         headers: {
//           'Authorization': 'Bearer $accessToken',
//         },
//       );

//       log('Response: ${response.body}');
//       if (response.statusCode == 200) {
//         final Map<String, dynamic> data = jsonDecode(response.body);
//         final List<dynamic> items = data['items'];
//         final List<Track> tracks =
//             items.map((item) => Track.fromJson(item)).toList();
//         log('Tracks:');
//         for (var track in tracks) {
//           // print('ID: ${track.id}');
//           // print('Name: ${track.name}');
//           // print('Artists: ${track.artists.join(', ')}');
//           // print('Duration: ${track.durationMs}ms');
//           // print('External URL: ${track.externalUrl}');
//           var yt = YoutubeExplode();
//           var video = await yt.search.search('${track.name} ${track.artists}');
//           final videoId = video.first.id.value;
//           yt.videos.streamsClient.getManifest(videoId).then((manifest) {
//             var streamInfo = manifest.audioOnly.first;
//             Track track1 = Track(
//                 id: track.id,
//                 name: track.name,
//                 artists: track.artists,
//                 durationMs: track.durationMs,
//                 externalUrl: track.externalUrl,
//                 trackUrl: streamInfo.url.toString());
//             // Provider.of<TracksProvider>(context, listen: false)
//             //     .addTracks(track1);
//           });

//           //   print('Video URL: ${video.first.url}');
//           //   print('');
//         }
//       }
//     } catch (e) {
//       print('Error: $e');
//     }
//   }

//   Future<void> chatGptPlay(String accessToken, BuildContext context) async {
//     try {
//       final response = await http.get(
//         Uri.parse(
//             'https://api.spotify.com/v1/playlists/37i9dQZF1DXcBWIGoYBM5M/tracks'),
//         headers: {
//           'Authorization': 'Bearer $accessToken',
//         },
//       );

//       if (response.statusCode == 200) {
//         final Map<String, dynamic> data = jsonDecode(response.body);
//         final List<dynamic> items = data['items'];
//         final List<TrackSongs> tracks =
//             items.map((item) => TrackSongs.fromJson(item)).toList();

//         // Save the tracks to your preferred storage (e.g., Provider)
//         for (var track in tracks) {
//           var yt = YoutubeExplode();
//           var video = await yt.search.search('${track.name} ${track.artists}');
//           final videoId = video.first.id.value;
//           yt.videos.streamsClient.getManifest(videoId).then((manifest) {
//             var streamInfo = manifest.audioOnly.first;
//             TrackSongs track1 = TrackSongs(
//                 name: track.name,
//                 url: streamInfo.url.toString(),
//                 artists: track.artists);
//             Provider.of<TracksProvider>(context, listen: false)
//                 .addTracks(track1);
//           });
//         }
//       }
//     } catch (e) {
//       print('Error: $e');
//     }
//   }

//   Future<void> getPlaylists(String accessToken, BuildContext context) async {
//     try {
//       final response = await http.get(
//         Uri.parse(
//             'https://api.spotify.com/v1/playlists/37i9dQZF1DXcBWIGoYBM5M/tracks'),
//         headers: {
//           'Authorization': 'Bearer $accessToken',
//         },
//       );

//       log('Response: ${response.body}');
//       if (response.statusCode == 200) {
//         final Map<String, dynamic> data = jsonDecode(response.body);
//         final List<dynamic> items = data['items'];
//         final List<Track> tracks =
//             items.map((item) => Track.fromJson(item)).toList();
//         log('Tracks:');
//         for (var track in tracks) {
//           // print('ID: ${track.id}');
//           // print('Name: ${track.name}');
//           // print('Artists: ${track.artists.join(', ')}');
//           // print('Duration: ${track.durationMs}ms');
//           // print('External URL: ${track.externalUrl}');
//           var yt = YoutubeExplode();
//           var video = await yt.search.search('${track.name} ${track.artists}');
//           final videoId = video.first.id.value;
//           yt.videos.streamsClient.getManifest(videoId).then((manifest) {
//             var streamInfo = manifest.audioOnly.first;
//             Track track1 = Track(
//                 id: track.id,
//                 name: track.name,
//                 artists: track.artists,
//                 durationMs: track.durationMs,
//                 externalUrl: track.externalUrl,
//                 trackUrl: streamInfo.url.toString());
//             // Provider.of<TracksProvider>(context, listen: false)
//             //     .addTracks(track1);
//           });

//           //   print('Video URL: ${video.first.url}');
//           //   print('');
//         }
//       }
//     } catch (e) {
//       print('Error: $e');
//     }
//   }

//   // Future<void> getRefreshToken() async {
//   //   // Refresh token that has been previously stored
//   //   var clientId = '80846bfe55954603b3e3febe6e29a5a0';
//   //   var clientSecret = '3258982fb9474592be55a800c2053f1b';
//   //   String?
//   //       refreshToken; // Get the refresh token from storage (e.g., SharedPreferences)

//   //   String url = "https://accounts.spotify.com/api/token";

//   //   Map<String, String> body = {
//   //     'grant_type': 'refresh_token',
//   //     'refresh_token': refreshToken!,
//   //     'client_id': clientId // Your Spotify client ID
//   //   };
//   //   var bytes = utf8.encode('$clientId:$clientSecret');
//   //   var base64Str = base64.encode(bytes);
//   //   var headers = {'Authorization': 'Basic $base64Str'};

//   //   var response =
//   //       await http.post(Uri.parse(url), headers: headers, body: body);

//   //   if (response.statusCode == 200) {
//   //     Map<String, dynamic> responseData = jsonDecode(response.body);
//   //     String accessToken = responseData['access_token'];
//   //     String newRefreshToken = responseData['refresh_token'];
//   //     log('Access token: $accessToken');
//   //     log('newRefreshToken: $newRefreshToken');

//   //     // Store the new tokens in storage (e.g., SharedPreferences)
//   //     // localStorage.setItem('access_token', accessToken);
//   //     // localStorage.setItem('refresh_token', newRefreshToken);
//   //   } else {
//   //     throw Exception('Failed to refresh token');
//   //   }
//   // }

//   // void getAndDisplayTracks(String token) async {
//   //   try {
//   //     // const accessToken = 'YOUR_ACCESS_TOKEN';
//   //     final tracks = await fetchTracks(token);
//   //     print(tracks);
//   //   } catch (e) {
//   //     print('Error: $e');
//   //   }
//   // }

//   // Future<List<String>> fetchTracks(String accessToken) async {
//   //   final response = await http.get(
//   //     Uri.parse('https://api.spotify.com/v1/tracks/3n3Ppam7vgaVa1iaRUc9Lp'),
//   //     headers: {
//   //       'Authorization': 'Bearer $accessToken',
//   //     },
//   //   );

//   //   if (response.statusCode == 200) {
//   //     final track = jsonDecode(response.body);
//   //     log('The tracks ${track}');
//   //     final name = track['name'];
//   //     final artist = track['artists'][0]['name'];
//   //     final album = track['album']['name'];

//   //     final previewUrl = track['preview_url'];
//   //     return ['$name by $artist from $previewUrl in $album'];
//   //   } else {
//   //     throw Exception('Failed to load track');
//   //   }
//   // }

//   Future<List<String>> fetchPlaylistTracks(
//       String accessToken, String playlistId) async {
//     final response = await http.get(
//       Uri.parse('https://api.spotify.com/v1/playlists/$playlistId/tracks'),
//       headers: {
//         'Authorization': 'Bearer $accessToken',
//       },
//     );

//     if (response.statusCode == 200) {
//       final Map<String, dynamic> data = jsonDecode(response.body);
//       final List<dynamic> items = data['items'];

//       List<String> trackNames = [];
//       for (var item in items) {
//         final Map<String, dynamic> track = item['track'];
//         final String trackName = track['name'];
//         trackNames.add(trackName);
//       }

//       return trackNames;
//     } else {
//       throw Exception('Failed to load playlist tracks');
//     }
//   }

//   // void displayAllTracks(String accessToken) async {
//   //   try {
//   //     final allTracks = await fetchAllTracks(accessToken);
//   //     print('All tracks:');
//   //     for (var trackName in allTracks) {
//   //       print(trackName);
//   //     }
//   //   } catch (e) {
//   //     print('Error: $e');
//   //   }
//   // }
// }

// class TrackSongs {
//   final String name;
//   final String url;
//   final List<String> artists;

//   TrackSongs({
//     required this.name,
//     required this.url,
//     required this.artists,
//   });

//   factory TrackSongs.fromJson(Map<String, dynamic> json) {
//     final track = json['track'];
//     return TrackSongs(
//       name: track['name'],
//       url: track['external_urls']['spotify'],
//       artists: (track['artists'] as List<dynamic>)
//           .map((artist) => artist['name'].toString())
//           .toList(),
//     );
//   }
// }
