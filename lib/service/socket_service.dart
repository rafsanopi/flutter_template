import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:templete/helper/local_db/local_db.dart';
import 'package:templete/service/api_url.dart';
import 'package:templete/utils/app_const/app_const.dart';

class SocketApi {
  factory SocketApi() {
    return _socketApi;
  }

  SocketApi._internal();

  static io.Socket? _socket;

  static io.Socket get socket {
    final currentSocket = _socket;
    if (currentSocket == null) {
      throw StateError('SocketApi.init() must complete before using socket.');
    }

    return currentSocket;
  }

  static bool get isInitialized => _socket != null;

  static Future<void> init() async {
    final userId = await SharePrefsHelper.getString(AppConstants.userID);
    if (userId.isEmpty || userId == 'null') {
      debugPrint('Socket initialization skipped: missing user id.');
      return;
    }

    final socketConnection = io.io(
      ApiUrl.socketUrl(userID: userId),
      io.OptionBuilder().setTransports(['websocket']).build(),
    );

    _socket = socketConnection;

    debugPrint(
      '$userId=============> Socket initialization, connected: '
      '${socketConnection.connected}',
    );

    socketConnection.onConnect((_) {
      debugPrint(
        '==============>>>>>>> Socket Connected '
        '${socketConnection.connected} ===============<<<<<<<',
      );
    });

    socketConnection.on('unauthorized', (dynamic data) {
      debugPrint('Unauthorized');
    });

    socketConnection.onError((dynamic error) {
      debugPrint('Socket error: $error');
    });

    socketConnection.onDisconnect((dynamic data) {
      debugPrint('>>>>>>>>>> Socket instance disconnected <<<<<<<<<<<<$data');
    });
  }

  static void dispose() {
    _socket?.dispose();
    _socket = null;
  }

  static final SocketApi _socketApi = SocketApi._internal();
}
