import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:lms_control/lms_api/status.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => PlayerState(),
      child: MaterialApp(
        home: const PlayerPage(),
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        ),
      ),
    );
  }
}

class PlayerState extends ChangeNotifier {
  var playing = false;
  var title = "";
  var artist = "";
  var ip = "192.168.1.27";
  var playerId = "d4:d8:53:58:41:b0";
  var artworkUrl =
      "http://192.168.1.27:9000/imageproxy/https%3A%2F%2Fstatic.qobuz.com%2Fimages%2Fcovers%2F87%2F61%2F0075679956187_600.jpg/image.jpg";

  PlayerState() {
    Timer.periodic(Duration(seconds: 1), (timer) {
      print("--------------------------");
      var lmsFuture = LmsStatus.getStatus(ip, playerId);
      lmsFuture.then((status) => {setStatus(status)});
    });
  }

  void setStatus(LmsStatusResponse status) {
    if (status.mode == "play") {
      playing = true;
    } else {
      playing = false;
    }
    var path = status.artworkUrl;
    artworkUrl = "http://$ip:9000$path";
    // print(artworkUrl);

    artist = status.artist;
    title = status.title;
    notifyListeners();
  }

  void togglePlay() {
    playing = !playing;
    notifyListeners();
  }
}

class PlayerPage extends StatefulWidget {
  const PlayerPage({super.key});

  @override
  State<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage> {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<PlayerState>();
    return Scaffold(
        body: SafeArea(
            child: Center(
      child: Column(children: [
        const Text("LMS Control"),
        const Spacer(),
        Image.network(appState.artworkUrl),
        const Spacer(),
        Text(appState.title),
        Text(appState.artist),
        const PlayerControls(),
        const Spacer(),
        ElevatedButton(
          onPressed: () {
            var statusFuture =
                LmsStatus.getStatus(appState.ip, appState.playerId);
            statusFuture.then((status) => {appState.setStatus(status)});
          },
          child: const Text("Refresh"),
        ),
        const Spacer(),
      ]),
    )));
  }
}

class PlayerControls extends StatelessWidget {
  const PlayerControls({super.key});

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<PlayerState>();

    const iconSize = 40.0;

    IconData playPauseIcon;
    if (appState.playing) {
      playPauseIcon = Icons.pause;
    } else {
      playPauseIcon = Icons.play_arrow;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Spacer(),
        IconButton(
          iconSize: iconSize,
          onPressed: () {},
          icon: const Icon(Icons.shuffle),
        ),
        const Spacer(),
        IconButton(
          iconSize: iconSize,
          onPressed: () {},
          icon: const Icon(Icons.skip_previous),
        ),
        const Spacer(),
        IconButton(
          iconSize: iconSize,
          onPressed: () {
            LmsApi.lmsPlay();
            var statusFuture =
                LmsStatus.getStatus(appState.ip, appState.playerId);
            statusFuture.then((status) => {appState.setStatus(status)});
          },
          icon: Icon(playPauseIcon),
        ),
        const Spacer(),
        IconButton(
          iconSize: iconSize,
          onPressed: () {
            LmsApi.lmsNext();
            var statusFuture =
                LmsStatus.getStatus(appState.ip, appState.playerId);
            statusFuture.then((status) => {appState.setStatus(status)});
          },
          icon: const Icon(Icons.skip_next),
        ),
        const Spacer(),
        IconButton(
          iconSize: iconSize,
          onPressed: () {},
          icon: const Icon(Icons.loop),
        ),
        const Spacer(),
      ],
    );

    // throw UnimplementedError();
  }
}

class ImageWidget extends StatelessWidget {
  const ImageWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<PlayerState>();
    return Image.network(appState.artworkUrl);
  }
}

class LmsApi {
  static Future<void> lmsPlay() async {
    final response = await http.post(
        Uri.parse('http://192.168.1.27:9000/jsonrpc.js'),
        body: jsonEncode(const LmsPlayRequest(playerId: "d4:d8:53:58:41:b0")));

    if (response.statusCode != 200) {
      throw Exception("Failed to make play request");
    }
  }

  static Future<void> lmsNext() async {
    final response = await http.post(
        Uri.parse('http://192.168.1.27:9000/jsonrpc.js'),
        body: jsonEncode(const LmsNextRequest(playerId: "d4:d8:53:58:41:b0")));

    if (response.statusCode != 200) {
      throw Exception("Failed to make play request");
    }
  }
}

class LmsPlayRequest {
  final String playerId;

  const LmsPlayRequest({
    required this.playerId,
  });

  Map<String, dynamic> toJson() => {
        'id': 1,
        'method': 'slim.request',
        'params': [
          playerId,
          ['pause']
        ]
      };
}

class LmsNextRequest {
  final String playerId;

  const LmsNextRequest({
    required this.playerId,
  });

  Map<String, dynamic> toJson() => {
        'id': 1,
        'method': 'slim.request',
        'params': [
          playerId,
          ['button', 'jump_fwd']
        ]
      };
}

class LmsPlayResponse {
  final int id;
  final String playerId;
  final String method;

  const LmsPlayResponse({
    required this.id,
    required this.playerId,
    required this.method,
  });
}
