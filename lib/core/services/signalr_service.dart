import 'dart:developer';

import 'package:signalr_netcore/signalr_client.dart';

class SignalRService {
  HubConnection? _hubConnection;
  final String _url = "https://wellora-healthcaremanagment.runasp.net/hubs/app";

  final Map<String, List<void Function(List<Object?>?)>> _pendingListeners = {};

  Future<void> init(String token) async {
    try {
      if (_hubConnection != null &&
              _hubConnection?.state == HubConnectionState.Connected ||
          _hubConnection?.state == HubConnectionState.Connecting ||
          _hubConnection?.state == HubConnectionState.Reconnecting) {
        log("ℹ️ SignalR is already active or connecting.");
        return;
      }

      _hubConnection =
          HubConnectionBuilder()
              .withUrl(
                _url,
                options: HttpConnectionOptions(
                  accessTokenFactory: () async => token,
                ),
              )
              .withAutomaticReconnect()
              .build();

      await _hubConnection!.start();
      log("✅ SignalR Started Successfully");

      _pendingListeners.forEach((eventName, callbacks) {
        for (var callback in callbacks) {
          _hubConnection!.on(eventName, callback);
          log("✅ SignalR: Pending listener for '$eventName' registered.");
        }
      });
      _pendingListeners.clear();

      _hubConnection!.onclose(({error}) {
        log("⚠️ SignalR Connection Closed: $error");
      });

      await _hubConnection!.start();
      log("✅ SignalR Started Successfully");
    } catch (e) {
      log("❌ SignalR Init Error: $e");
    }
  }

  void on(String eventName, void Function(List<Object?>?) callback) {
    if (_hubConnection != null && isConnected) {
      _hubConnection!.on(eventName, callback);
      log("✅ SignalR: Listener for '$eventName' registered directly.");
    } else {
      _pendingListeners.putIfAbsent(eventName, () => []).add(callback);
      log(
        "ℹ️ SignalR: Listener for '$eventName' queued (Connection not ready yet)",
      );
    }
  }

  Future<void> invoke(String methodName, {List<Object>? args}) async {
    if (isConnected) {
      try {
        await _hubConnection?.invoke(methodName, args: args);
        log("🚀 SignalR Invoke: $methodName with args $args");
      } catch (e) {
        log("❌ SignalR Invoke Error ($methodName): $e");
      }
    } else {
      log("⚠️ SignalR not connected. Action $methodName ignored.");
    }
  }

  void off(String eventName) {
    if (_hubConnection != null) {
      _hubConnection!.off(eventName);
      log("🚫 SignalR: Listener for '$eventName' removed.");
    }
    _pendingListeners.remove(eventName);
  }

  bool get isConnected => _hubConnection?.state == HubConnectionState.Connected;
}
