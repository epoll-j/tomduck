import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:iflow/database/session_model.dart';
import 'package:iflow/database/task_model.dart';
import 'package:iflow/utils/common_util.dart';

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