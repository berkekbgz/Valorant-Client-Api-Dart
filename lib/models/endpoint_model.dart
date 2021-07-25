import '../client.dart';

class Endpoint {
  String url;
  BaseUrlType baseUrlType;
  MethodType methodType;
  bool useLocalHeaders;
  Endpoint({required this.url, required this.baseUrlType, required this.methodType, this.useLocalHeaders = false});

  static Endpoint empty() => Endpoint(url: "", baseUrlType: BaseUrlType.pd, methodType: MethodType.GET);
}

enum BaseUrlType { pd, glz, shared, local, apse, playerpreferences }

extension BaseUrlTypeExtension on BaseUrlType {
  String uri(Client client) {
    switch (this) {
      case BaseUrlType.pd:
        return "https://pd.${client.shard}.a.pvp.net";
      case BaseUrlType.glz:
        return "https://glz-${client.region}-1.${client.shard}.a.pvp.net";
      case BaseUrlType.shared:
        return "https://shared.${client.shard}.a.pvp.net";
      case BaseUrlType.local:
        return "https://127.0.0.1:${client.lockfile!.port}";
      case BaseUrlType.apse:
        return "https://apse.pp.riotgames.com";
      case BaseUrlType.playerpreferences:
        return "https://playerpreferences.riotgames.com";
    }
  }
}

/*extension BaseUrlTypeExtension on BaseUrlType {
  String get name => toString().split('.').last;
}*/

// ignore: constant_identifier_names
enum MethodType { GET, POST, PUT, DELETE }

extension MethodTypeExtension on MethodType {
  String get name => toString().split('.').last;
}
