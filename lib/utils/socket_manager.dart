import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SocketManager {
  static final SocketManager _instance = SocketManager._internal();
  factory SocketManager() => _instance;

  WebSocketChannel? _channel;
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
      final wsUrl = Uri.parse('wss://vrerealestatedemo-backend.globeapp.dev/socket/$userId');
      _channel = WebSocketChannel.connect(wsUrl);
      print('Connected to: $userId');

      _channel!.stream.listen((message) {
        _handleIncomingMessage(message);
      }, onError: (error) {
        print('Error: $error');
      }, onDone: () {
        print('Connection closed');
      });
    }
  }

  void _handleIncomingMessage(dynamic message) {
    if (message is String) {
      if (message.startsWith('s')) {
        _locationController.add(message.substring(1));
      } else if (message.startsWith('t')) {
        _sceneController.add(message.substring(1));
      } else {
        try {
          final data = jsonDecode(message);
          if (data['deviceId'] != null && data['status'] != null) {
            _deviceStatusController.add(data);
          }
        } catch (e) {
          // ignore: avoid_print
          print('Error parsing message: $e');
        }
      }
    }
  }

  void sendMessage(String message) {
    _channel?.sink.add(message);
  }

  void close() {
    _channel?.sink.close();
    _deviceStatusController.close();
    _locationController.close();
    _sceneController.close();
  }
}
