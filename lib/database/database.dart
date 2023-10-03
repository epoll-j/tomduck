import 'package:tomduck/database/session_model.dart';
import 'package:tomduck/database/task_model.dart';

class Database {
  static initialize() async {
    var models = [
      TaskModel(),
      SessionModel(),
    ];

    for (int i = 0; i < models.length; i++) {
      var model = models[i];
      if (!model.exists) {
        await Future.delayed(const Duration(milliseconds: 60), () {});
      }
    }
  }
}