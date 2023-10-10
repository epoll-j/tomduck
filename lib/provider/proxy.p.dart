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
  }
}