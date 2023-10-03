import 'package:flutter/services.dart';
import 'dart:async';

class ChannelTools {
  final _methodChannel = const MethodChannel("iflow.epoll.dev/method_channel");

  ChannelTools._internal() {
    _methodChannel.setMethodCallHandler(_callHandler);
  }

  factory ChannelTools() => _instance;

  static final ChannelTools _instance = ChannelTools._internal();

  Future<Map> invokeMethod(String methodName, [Map? params]) async {
    Map res;
    try {
      res = await _methodChannel.invokeMethod(methodName, params);
    } catch (e) {
      res = {'code': 0, 'err': e};
    }
    return res;
  }

  Future<dynamic> _callHandler(MethodCall methodCall) async {
    switch (methodCall.method) {
      case "openCaller":
        print("arrived to open caller");
    }
  }
}
