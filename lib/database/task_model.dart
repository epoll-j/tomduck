import 'package:sqflite_common/sqlite_api.dart';
import 'package:tomduck/database/base_model.dart';

class TaskModel extends BaseModel {
  TaskModel._internal();

  factory TaskModel() => _instance;

  static final TaskModel _instance = TaskModel._internal();

  @override
  String tableName = "task";

  @override
  Future<void> onCreate(Database db, int version) async {
    await db.execute("""
      CREATE TABLE IF NOT EXISTS $tableName (
        id INTEGER PRIMARY KEY autoincrement,
        
        rule_id INTEGER,
                
        intercept_count INTEGER,
        
        start_time INTEGER,
        stop_time INTEGER,
        
        update_time INTEGER,
        create_time INTEGER
      )
    """);
  }
}
