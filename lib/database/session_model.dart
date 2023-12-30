import 'package:sqflite_common/sqlite_api.dart';
import 'package:iflow/database/base_model.dart';

class SessionModel extends BaseModel {
  SessionModel._internal();

  factory SessionModel() => _instance;

  static final SessionModel _instance = SessionModel._internal();

  @override
  String tableName = "session";

  @override
  Future<void> onCreate(Database db, int version) async {
    await db.execute("""
      CREATE TABLE IF NOT EXISTS $tableName (
        id INTEGER PRIMARY KEY autoincrement,
        task_id INTEGER,
        remote_address TEXT,
        local_address TEXT,
        host TEXT,
        schemes TEXT,
        request_line TEXT,
        methods TEXT,
        uri TEXT,
        suffix TEXT,
        request_content_type TEXT,
        request_content_encoding TEXT,
        request_header TEXT,
        request_http_version TEXT,
        request_body TEXT,
        target TEXT,
        
        http_code INTEGER,
        
        response_content_type TEXT,
        response_content_encoding TEXT,
        response_header TEXT,
        response_http_version TEXT,
        response_body TEXT,
        response_msg TEXT,
        
        start_time INTEGER,
        connect_time INTEGER,
        connected_time INTEGER,
        handshake_time INTEGER,
        request_end_time INTEGER,
        response_start_time INTEGER,
        response_end_time INTEGER,
        end_time INTEGER,
        
        upload_flow INTEGER,
        download_flow INTEGER,
        
        note TEXT,
        state INTEGER,
        random INTEGER,

        update_time INTEGER,
        create_time INTEGER
      )
    """);
  }
}
