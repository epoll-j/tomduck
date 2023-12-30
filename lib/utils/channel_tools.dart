import 'dart:convert';

import 'package:flutter/services.dart';
import 'dart:async';

import 'package:iflow/database/session_model.dart';

class ChannelTools {
  final _methodChannel = const MethodChannel("iflow.epoll.dev/method_channel");
  final _eventChannel = const EventChannel("iflow.epoll.dev/event_channel");

  ChannelTools._internal() {
    _methodChannel.setMethodCallHandler(_callHandler);
    _eventChannel.receiveBroadcastStream("save_event").listen(_saveEventHandler);
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

  _saveEventHandler(dynamic event) async {
    var eventName = event['event'];
    var data = jsonDecode(event['data']);
    var id = data.remove('id');
    if (eventName == 'save_session') {
      var random = data['random'];
      var ignore = data.remove('ignore');
      if (!ignore) {
        if (id == '' || id == null) {
          var rowId = await SessionModel().insert(data);
          _methodChannel.invokeMethod("setId_$random", rowId);
        } else {
          await SessionModel().update(Map.of({"id": id}), data);
        }
      }
    }
  }
}
