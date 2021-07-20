import 'dart:convert';

import 'package:http/http.dart' as http;
import 'session_manager.dart';

class Auth {
  late final String username;
  late final String password;

  Auth(this.username, this.password);

  Future<Map<String, dynamic>> authenticate() async {
    Map<String, dynamic> data = {
      "client_id": "play-valorant-web-prod",
      "nonce": "1",
      "redirect_uri": "https://playvalorant.com/opt_in",
      "response_type": "token id_token",
    };

    var session = Session();
    var response = await session.post('https://auth.riotgames.com/api/v1/authorization', body: data);

    data = {
      "type": "auth",
      "username": username,
      "password": password,
      "remember": false,
      "language": "en_US",
    };

    response = await session.put('https://auth.riotgames.com/api/v1/authorization', body: data);
    if (response['error'] != null) throw Exception("Authentication Error");
    RegExp regex = RegExp(r'access_token=((?:[a-zA-Z]|\d|\.|-|_)*).*id_token=((?:[a-zA-Z]|\d|\.|-|_)*).*expires_in=(\d*)');
    var accessToken = regex.stringMatch(response['response']['parameters']['uri'])!.split('&')[0].replaceAll('access_token=', '');
    var headers = {
      "Authorization": "Bearer $accessToken",
      "content-type": "application/json",
    };

    response = await session.post('https://entitlements.auth.riotgames.com/api/token/v1', customHeaders: headers, body: {});
    var entitlementsToken = response['entitlements_token'];

    response = await session.post('https://auth.riotgames.com/userinfo', customHeaders: headers, body: {});
    var userId = response['sub'];

    headers['X-Riot-Entitlements-JWT'] = entitlementsToken;
    headers['X-Riot-ClientPlatform'] = "ew0KCSJwbGF0Zm9ybVR5cGUiOiAiUEMiLA0KCSJwbGF0Zm9ybU9TIjogIldpbmRvd3MiLA0KCSJwbGF0Zm9ybU9TVmVyc2lvbiI6ICIxMC4wLjE5MDQyLjEuMjU2LjY0Yml0IiwNCgkicGxhdGZvcm1DaGlwc2V0IjogIlVua25vd24iDQp9";
    headers['X-Riot-ClientVersion'] = await _getCurrentVersion();
    return {"userId": userId, "headers": headers};
  }

  Future<String> _getCurrentVersion() async {
    var response = await http.get(Uri.parse('https://valorant-api.com/v1/version'));
    var data = json.decode(response.body);
    String version = data['data']['riotClientVersion'];
    return version;
  }
}
