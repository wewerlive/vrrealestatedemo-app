import 'package:web_socket_channel/io.dart';
import 'dart:async';

class SocketManager {
  static final SocketManager _instance = SocketManager._internal();
  factory SocketManager() => _instance;

  SocketManager._internal() {
    _initConnection();
  }

  IOWebSocketChannel? _channel;
  final _locationController = StreamController<String>.broadcast();
  final _sceneController = StreamController<String>.broadcast();

  Stream<String> get locationStream => _locationController.stream;
  Stream<String> get sceneStream => _sceneController.stream;

  void _initConnection() {
    if (_channel == null) {
      _channel =
          IOWebSocketChannel.connect('ws://192.168.1.2:8080/server/socket');
      _channel?.stream.listen((message) {
        if (message.startsWith('t')) {
          _locationController.add(message);
        } else if (message.startsWith('s')) {
          _sceneController.add(message);
        }
      }, onDone: () {
        // Attempt to reconnect if the connection is closed
        Future.delayed(const Duration(seconds: 5), _initConnection);
      }, onError: (error) {
        // Attempt to reconnect on error
        Future.delayed(const Duration(seconds: 5), _initConnection);
      });
    }
  }

  void sendMessage(String message) {
    _channel?.sink.add(message);
  }

  void close() {
    _channel?.sink.close();
    _locationController.close();
    _sceneController.close();
    _channel = null;
  }
}
