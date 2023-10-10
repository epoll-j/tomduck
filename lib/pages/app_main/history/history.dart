import 'package:flutter/material.dart';
import 'package:tomduck/database/session_model.dart';
import 'package:tomduck/database/task_model.dart';

class History extends StatefulWidget {
  @override
  State<History> createState() => _HotState();
}

class _HotState extends State<History> {
  List historyData = [];

  @override
  void initState() {
    super.initState();
    loadHistory();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('抓包记录'),
        automaticallyImplyLeading: false,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          loadHistory();
        },
        child: ListView.separated(
            itemCount: historyData.length,
            itemBuilder: (context, index) => _buildItem(historyData[index]),
            separatorBuilder: (BuildContext context, int index) =>
                const Divider(
                  height: 1,
                  thickness: 0.1,
                  color: Colors.blueGrey,
                )),
      ),
    );
  }

  Widget _buildItem(dynamic history) {
    return ListTile(
      title: Text('开始时间：${history['create_time']}'),
      subtitle: Row(
        children: [
          Text('大小${history['download_flow'].toStringAsFixed(2)}kb'),
          const SizedBox(
            width: 10,
          ),
          Text(
              '持续时间: ${getTime((history['update_time'] - history['create_time']) / 1000)}'),
        ],
      ),
      contentPadding: const EdgeInsets.all(5),
      trailing: Text('${history['count']}个数据包'),
    );
  }

  String getTime(double time) {
    return '${time ~/ 60}分${(time % 60).toInt()}秒';
  }

  void loadHistory() async {
    var result = [];
    var dbList = await TaskModel().rawQuery(
        "select id, create_time, update_time from task order by create_time desc");
    for (var item in dbList) {
      var session = await SessionModel().rawQuery(
          'select count(id) as count, sum(upload_flow) as upload_flow, sum(download_flow) as download_flow from session where task_id = ${item['id']}');
      result.add({
        'id': item['id'],
        'create_time': item['create_time'],
        'update_time': item['update_time'] ?? 0,
        'count': session[0]['count'] ?? 0,
        'upload_flow': (session[0]['upload_flow'] ?? 0.0) / 1024,
        'download_flow': (session[0]['download_flow'] ?? 0.0) / 1024,
      });
    }
    setState(() {
      historyData = result;
    });
  }
}
