import 'package:shared_preferences/shared_preferences.dart';
import 'package:tomduck/database/session_model.dart';
import 'package:tomduck/database/task_model.dart';
import 'package:tomduck/utils/common_util.dart';

import 'falsify_model.dart';

class Database {

  static SharedPreferences? sharedPreferences;

  static initialize() async {
    var models = [
      TaskModel(),
      SessionModel(),
      FalsifyModel(),
    ];
    CommonUtil.documentPath = (await getApplicationDocumentsDirectory()).path;
    for (int i = 0; i < models.length; i++) {
      var model = models[i];
      if (!model.exists) {
        await Future.delayed(const Duration(milliseconds: 60), () {});
      }
    }

    sharedPreferences = await SharedPreferences.getInstance();
  }
}