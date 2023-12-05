import 'dart:convert';

import 'package:bruno/bruno.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

class CommonUtil {
  static final _dateFormat = DateFormat("yyyy-MM-dd HH:mm:ss");
  static String documentPath = "";

  static String formatTime(time) {
    return _dateFormat.format(DateTime.fromMillisecondsSinceEpoch(time));
  }

  static Widget noData({String? title}) {
    return BrnAbnormalStateWidget(
      img: Image.asset('asset/images/no_data.png'),
      title: title ?? '暂无数据',
    );
  }

  static String prettyPrintJson(String json) {
    try {
      JsonEncoder encoder = const JsonEncoder.withIndent('  ');
      return encoder.convert(jsonDecode(json));
    } catch (e) {
      return json;
    }
  }

  static bool isEmpty(dynamic data) {
    if (data == null) {
      return true;
    }

    if (data is String) {
      if (data == '') {
        return true;
      }
    }

    if (data is List) {
      List list = data;
      return list.isEmpty;
    }

    return false;
  }
}
