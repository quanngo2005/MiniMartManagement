import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:mini_mart_management_mobile_app/config/api_config.dart';
import 'package:mini_mart_management_mobile_app/main.dart';
import 'package:mini_mart_management_mobile_app/services/http_client_factory.dart';
import 'package:signalr_netcore/signalr_client.dart';
import 'package:signalr_netcore/ihub_protocol.dart';

class SignalrService {
  SignalrService._internal();
  static final SignalrService instance = SignalrService._internal();

  HubConnection? _connection;
  bool _isConnecting = false;

  final List<VoidCallback> _listeners = [];

  void addListener(VoidCallback listener) {
    _listeners.add(listener);
  }

  void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }

  void _notifyListeners() {
    for (final listener in List.from(_listeners)) {
      try {
        listener();
      } catch (e) {
        if (kDebugMode) {
          print("Error calling SignalR listener: $e");
        }
      }
    }
  }

  Future<void> connect() async {
    if (_connection != null || _isConnecting) return;
    _isConnecting = true;

    try {
      final cookieHeader = getClientCookieHeader();
      final url = ApiConfig.uri('/hubs/notifications').toString();

      MessageHeaders? headers;
      if (cookieHeader != null) {
        headers = MessageHeaders()..setHeaderValue('Cookie', cookieHeader);
      }

      _connection = HubConnectionBuilder()
          .withUrl(url, options: HttpConnectionOptions(headers: headers))
          .withAutomaticReconnect()
          .build();

      _connection!.onclose(({error}) {
        if (kDebugMode) {
          print("SignalR connection closed. Error: $error");
        }
      });

      _connection!.on("ReceiveNotification", (arguments) {
        if (arguments != null && arguments.isNotEmpty) {
          try {
            final data = arguments[0] as Map<dynamic, dynamic>;
            _showNotificationSnackBar(data.cast<String, dynamic>());
          } catch (e) {
            if (kDebugMode) {
              print("Error processing SignalR message payload: $e");
            }
          }
        }
      });

      await _connection!.start();
      if (kDebugMode) {
        print("SignalR connected successfully.");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error connecting to SignalR: $e");
      }
      _connection = null;
    } finally {
      _isConnecting = false;
    }
  }

  Future<void> disconnect() async {
    if (_connection == null) return;
    try {
      await _connection!.stop();
    } catch (e) {
      if (kDebugMode) {
        print("Error disconnecting from SignalR: $e");
      }
    } finally {
      _connection = null;
    }
  }

  void _showNotificationSnackBar(Map<String, dynamic> payload) {
    _notifyListeners();
    final title = payload['title'] ?? 'Thông báo';
    final body = payload['body'] ?? '';
    final metadata = payload['data'] != null
        ? Map<String, dynamic>.from(payload['data'] as Map)
        : null;

    IconData icon = Icons.notifications;
    Color iconColor = Colors.white;
    Color backgroundColor = Colors.blueGrey[800]!;

    if (metadata != null) {
      final type = metadata['type'];
      final status = metadata['status'];

      if (type == 'order_return_request') {
        icon = Icons.assignment_return_outlined;
        iconColor = Colors.amberAccent;
        backgroundColor = const Color(0xFF2C3E50);
      } else if (type == 'order_return_response') {
        if (status == 'approved') {
          icon = Icons.check_circle_outline;
          iconColor = Colors.greenAccent;
          backgroundColor = const Color(0xFF1E4620);
        } else if (status == 'rejected') {
          icon = Icons.cancel_outlined;
          iconColor = Colors.redAccent;
          backgroundColor = const Color(0xFF6B1D1D);
        }
      } else if (type == 'stock_count_request') {
        icon = Icons.inventory_2_outlined;
        iconColor = Colors.orangeAccent;
        backgroundColor = const Color(0xFF3E2723);
      } else if (type == 'stock_count_response') {
        if (status == 'approved') {
          icon = Icons.check_circle_outline;
          iconColor = Colors.greenAccent;
          backgroundColor = const Color(0xFF1E4620);
        } else if (status == 'rejected') {
          icon = Icons.cancel_outlined;
          iconColor = Colors.redAccent;
          backgroundColor = const Color(0xFF6B1D1D);
        }
      }
    }

    scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: iconColor, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    body,
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 6),
        action: SnackBarAction(
          label: 'Đóng',
          textColor: Colors.white,
          onPressed: () {
            scaffoldMessengerKey.currentState?.hideCurrentSnackBar();
          },
        ),
      ),
    );
  }
}
