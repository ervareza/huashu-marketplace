import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'api_service.dart';

class GlobalSocketService extends ChangeNotifier {
  static final GlobalSocketService _instance = GlobalSocketService._internal();
  factory GlobalSocketService() => _instance;
  GlobalSocketService._internal();

  io.Socket? _socket;
  final ApiService _api = ApiService();
  
  bool _hasUnreadNotifications = false;
  bool _hasUnreadChats = false;

  bool get hasUnreadNotifications => _hasUnreadNotifications;
  bool get hasUnreadChats => _hasUnreadChats;

  io.Socket? get socket => _socket;

  Future<void> initSocket() async {
    final token = await _api.secureStorage.read(key: 'access_token');
    if (token == null) return;

    if (_socket != null && _socket!.connected) return;

    try {
      _socket = io.io(_api.dio.options.baseUrl, <String, dynamic>{
        'transports': ['websocket'],
        'autoConnect': false,
        'extraHeaders': {'Authorization': 'Bearer $token'}
      });

      _socket?.connect();

      _socket?.onConnect((_) {
        debugPrint('Global Socket connected');
      });

      _socket?.on('notification', (data) {
        debugPrint('New global notification: $data');
        _hasUnreadNotifications = true;
        notifyListeners();
      });

      _socket?.on('new_message', (data) {
        debugPrint('New global message: $data');
        _hasUnreadChats = true;
        notifyListeners();
      });

      _socket?.on('order_update', (data) {
        debugPrint('Order update: $data');
        _hasUnreadNotifications = true;
        notifyListeners();
      });

      _socket?.onDisconnect((_) {
        debugPrint('Global Socket disconnected');
      });
    } catch (e) {
      debugPrint('Error initializing global socket: $e');
    }
  }

  void markNotificationsAsRead() {
    _hasUnreadNotifications = false;
    notifyListeners();
  }

  void markChatsAsRead() {
    _hasUnreadChats = false;
    notifyListeners();
  }

  void disposeSocket() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
  }
}
