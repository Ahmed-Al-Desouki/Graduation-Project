// core/services/signalr_service.dart
import 'dart:developer';

import 'package:signalr_netcore/signalr_client.dart';

class SignalRService {
  HubConnection? _hubConnection;
  final String _url = "https://wellora-healthcaremanagment.runasp.net/hubs/app";

  // 🚀 قائمة لتخزين الـ Listeners اللي بيتم تسجيلهم قبل ما الاتصال يجهز
  final Map<String, List<void Function(List<Object?>?)>> _pendingListeners = {};

  Future<void> init(String token) async {
    try {
      // 1. لو الاتصال موجود وشغال، مابنعملش حاجة
      if (_hubConnection != null &&
              _hubConnection?.state == HubConnectionState.Connected ||
          _hubConnection?.state == HubConnectionState.Connecting ||
          _hubConnection?.state == HubConnectionState.Reconnecting) {
        log("ℹ️ SignalR is already active or connecting.");
        return;
      }

      // 2. بناء الاتصال
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

      // 3. أول ما الـ Connection يجهز، سجل كل الـ Listeners اللي كانت مستنية في الـ Queue
      _pendingListeners.forEach((eventName, callbacks) {
        for (var callback in callbacks) {
          _hubConnection!.on(eventName, callback);
          log("✅ SignalR: Pending listener for '$eventName' registered.");
        }
      });
      _pendingListeners.clear(); // فضي القائمة بعد التسجيل

      _hubConnection!.onclose(({error}) {
        log("⚠️ SignalR Connection Closed: $error");
      });

      // 4. تشغيل الاتصال
      await _hubConnection!.start();
      log("✅ SignalR Started Successfully");
    } catch (e) {
      log("❌ SignalR Init Error: $e");
    }
  }

  // ✅ ميثود الـ On (مع ميزة الـ Queueing عشان التنبيهات)
  // void on(String eventName, void Function(List<Object?>?) callback) {
  //   if (_hubConnection != null) {
  //     _hubConnection!.on(eventName, callback);
  //   } else {
  //     // لو الـ Hub لسه مجهزاش، شيل الـ listener عندك عشان تسجله أول ما يفتح
  //     _pendingListeners.putIfAbsent(eventName, () => []).add(callback);
  //     log("ℹ️ SignalR: Listener for '$eventName' queued (Hub not ready yet)");
  //   }
  // }
  void on(String eventName, void Function(List<Object?>?) callback) {
    // 🚀 التعديل: سجل مباشرة فقط لو هو Connected فعلاً
    if (_hubConnection != null && isConnected) {
      _hubConnection!.on(eventName, callback);
      log("✅ SignalR: Listener for '$eventName' registered directly.");
    } else {
      // لو لسه بيعمل Start أو null، حطه في الطابور
      _pendingListeners.putIfAbsent(eventName, () => []).add(callback);
      log(
        "ℹ️ SignalR: Listener for '$eventName' queued (Connection not ready yet)",
      );
    }
  }

  // ✅ ميثود الـ Invoke (اللي كانت ناقصة وسببت الأيرور في الـ Chat)
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

  // ميثود للتأكد إن الاتصال جاهز
  bool get isConnected => _hubConnection?.state == HubConnectionState.Connected;
}
