import 'package:flutter/material.dart';
import 'package:tomduck/database/session_model.dart';

import '../database/task_model.dart';

// Provider状态管理使用
class ProxyStore with ChangeNotifier {
  int state = 0;
  String ip = "127.0.0.1";
  int port = 9527;
  int taskId = -1;

  int packageCount = 0;
  num uploadFlow = 0;
  num downloadFlow = 0;

  int time = 0;

  List suffixList = [{'count': 1, 'suffix': '暂无数据'}];

  void updateState(int state) {
    this.state = state;
    time = 0;
    packageCount = 0;
    uploadFlow = 0;
    downloadFlow = 0;
    notifyListeners();
  }

  void update() {
    time += 1;
    TaskModel().update({ "id": taskId }, {});
    SessionModel().rawQuery("select count(id) as packageCount, sum(upload_flow) uploadFlow, sum(download_flow) downloadFlow from session where task_id = $taskId").then((val) {
      var result = val[0];
      packageCount = result['packageCount'];
      uploadFlow = ((result['uploadFlow'] ?? 0.0) / 1024.0);
      downloadFlow = ((result['downloadFlow'] ?? 0.0) / 1024.0);
      notifyListeners();
    });
    SessionModel().rawQuery('select count(id) as count, suffix from session where task_id = $taskId group by suffix').then((val) {
      if (val.length > 0) {
        suffixList.clear();
        for (var item in val) {
          suffixList.add({'count': item['count'], 'suffix': item['suffix'] == '' ? '未知' : item['suffix'].toUpperCase()});
        }
        notifyListeners();
      }
    });
  }
}