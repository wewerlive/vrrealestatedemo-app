import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SocketManager {
  static final SocketManager _instance = SocketManager._internal();
  factory SocketManager() => _instance;

  late IO.Socket _socket;
  final _deviceStatusController =
      StreamController<Map<String, dynamic>>.broadcast();
  final _locationController = StreamController<String>.broadcast();
  final _sceneController = StreamController<String>.broadcast();

  Stream<Map<String, dynamic>> get deviceStatusStream =>
      _deviceStatusController.stream;
  Stream<String> get locationStream => _locationController.stream;
  Stream<String> get sceneStream => _sceneController.stream;

  SocketManager._internal();

  Future<void> initializeSocket() async {
    const storage = FlutterSecureStorage();
    final userId = await storage.read(key: 'user_id');

    if (userId != null) {
      _socket = IO.io(
          'https://secondary-mindy-twinverse-5a55a10e.koyeb.app/',
          <String, dynamic>{
            'transports': ['websocket'],
            'autoConnect': true
          });

      _socket.connect();
      _socket.on('connect', (_) => print('Connected to socket server'));
      _socket.on('sceneChange', (data) => _sceneController.add(data));
      _socket.on('teleChange', (data) => _locationController.add(data));
    }
  }

  void sendHeadsetStatusUpdate(String deviceId) {
    print(deviceId);
    _socket.emit('headsetStatusUpdate', deviceId);
  }

  void sendSceneChangeCommand(String sceneId, String deviceId) {
    print('sceneId: $sceneId, deviceId: $deviceId');
    _socket
        .emit('sceneChangeCommand', {'sceneID': sceneId, 'deviceID': deviceId});
  }

  void sendTeleChangeCommand(String teleId, String deviceId) {
    print('teleId: $teleId, deviceId: $deviceId');
    _socket.emit('teleChangeCommand', {'teleID': teleId, 'deviceID': deviceId});
  }

  void close() {
    _socket.disconnect();
    _deviceStatusController.close();
    _locationController.close();
    _sceneController.close();
  }
}
