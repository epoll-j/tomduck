import 'package:sqflite_common/sqlite_api.dart';
import 'package:tomduck/database/base_model.dart';

class FalsifyModel extends BaseModel {
  FalsifyModel._internal();

  factory FalsifyModel() => _instance;

  static final FalsifyModel _instance = FalsifyModel._internal();

  @override
  String tableName = "falsify";

  @override
  Future<void> onCreate(Database db, int version) async {
    await db.execute("""
      CREATE TABLE IF NOT EXISTS $tableName (
        id INTEGER PRIMARY KEY autoincrement,
        group_id INTEGER,
        enable INTEGER,
        title TEXT,
        domain TEXT,
        path TEXT,
        action INTEGER,
        redirect TEXT,
        req_body TEXT,
        req_param TEXT,
        resp_body TEXT,

        update_time INTEGER,
        create_time INTEGER
      )
    """);
  }
}