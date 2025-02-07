abstract class BaseInviroment {
  String get address;
  int? get port;
  bool get ssl;

  String get portString => port != null ? ':$port' : '';

  String get wsAddress {
    if (ssl) {
      return 'wss://$address$portString/ws';
    } else {
      return 'ws://$address$portString/ws';
    }
  }

  String get restAddress {
    if (ssl) {
      return 'https://$address$portString';
    } else {
      return 'http://$address$portString';
    }
  }
}

class LocalInviroment extends BaseInviroment {
  @override
  String get address => '127.0.0.1';

  @override
  int? get port => 8080;

  @override
  bool get ssl => false;
}

class ServerInviroment extends BaseInviroment {
  @override
  String get address => 'bonfire-multiplayer.onrender.com';

  @override
  int? get port => null;

  @override
  bool get ssl => true;
}
