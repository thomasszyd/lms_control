import 'dart:convert';
import 'package:http/http.dart' as http;

class LmsStatus {
  static Future<LmsStatusResponse> getStatus(String ip, String playerId) async {
    final resp = await http.post(
      Uri.parse('http://$ip:9000/jsonrpc.js'),
      body: jsonEncode(LmsStatusRequest(playerId: playerId)),
    );

    return LmsStatusResponse.fromJson(jsonDecode(resp.body));
  }
}

class LmsStatusRequest {
  final String playerId;

  const LmsStatusRequest({
    required this.playerId,
  });

  Map<String, dynamic> toJson() => {
        "id": 1,
        "method": "slim.request",
        "params": [
          playerId,
          [
            "status",
            "-",
            1,
            "tags:cgAABbehldiqtyrSSuoKLNJ",
          ]
        ]
      };
}

class LmsStatusResponse {
  final String mode;
  final String title;
  final String artist;
  final String artworkUrl;
  final String duration;
  // final double time;

  const LmsStatusResponse({
    required this.mode,
    required this.title,
    required this.artist,
    required this.artworkUrl,
    required this.duration,
    // required this.time,
  });

  factory LmsStatusResponse.fromJson(Map<String, dynamic> json) {
    return LmsStatusResponse(
      mode: json['result']['mode'],
      title: json['result']['remoteMeta']['title'],
      artist: json['result']['remoteMeta']['artist'],
      artworkUrl: json['result']['remoteMeta']['artwork_url'],
      duration: json['result']['remoteMeta']['duration'],
      // time: json['result']['time'],
    );
  }
}
