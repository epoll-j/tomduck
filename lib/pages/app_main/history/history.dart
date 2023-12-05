import 'package:bruno/bruno.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swipe_action_cell/core/cell.dart';
import 'package:intl/intl.dart';
import 'package:tomduck/database/session_model.dart';
import 'package:tomduck/database/task_model.dart';

import '../../../components/layouts/basic_scaffold.dart';
import '../../../config/app_config.dart';

class History extends StatefulWidget {
  @override
  State<History> createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  List historyData = [];
  final dateFormat = DateFormat("yyyy-MM-dd HH:mm:ss");

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
    return BasicScaffold(
      title: '抓包记录',
      child: RefreshIndicator(
        onRefresh: () async {
          loadHistory();
        },
        child: ListView.separated(
          padding: const EdgeInsets.only(top: 20),
          itemCount: historyData.length,
          itemBuilder: (context, index) => _buildItem(historyData[index]),
          separatorBuilder: (BuildContext context, int index) {
            return const SizedBox(
              height: 10,
            );
          },
        ),
      ),
    );
  }

  Widget _buildItem(dynamic history) {
    return SwipeActionCell(
      key: Key('${history['id']}'),
      backgroundColor: AppConfig.backgroundColor,
      child: GestureDetector(
        onTap: () {
          Navigator.pushNamed(context, "/historyItem", arguments: history);
        },
        child: FractionallySizedBox(
          widthFactor: 0.95,
          child: BrnShadowCard(
              padding: const EdgeInsets.all(10),
              child: Column(children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      dateFormat.format(DateTime.fromMillisecondsSinceEpoch(
                          history['create_time'])),
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text(
                        "持续时间：${_getTime((history['update_time'] - history['create_time']) / 1000)}"),
                  ],
                ),
                SizedBox.fromSize(
                  size: const Size.fromHeight(10),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "${history['count']}次请求",
                      style: const TextStyle(color: Colors.grey),
                    ),
                    Row(
                      children: [
                        const Icon(
                          Icons.upload,
                          color: Colors.grey,
                          size: 15,
                        ),
                        Text(
                          _getFlowStr(history['upload_flow']),
                          style: const TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        const Icon(
                          Icons.download,
                          color: Colors.grey,
                          size: 15,
                        ),
                        Text(
                          _getFlowStr(history['download_flow']),
                          style: const TextStyle(color: Colors.grey),
                        )
                      ],
                    )
                  ],
                )
              ])),
        ),
      ),
    );
  }

  String _getTime(double time) {
    if (time < 0) {
      return '0秒';
    }
    return '${time ~/ 60}分${(time % 60).toInt()}秒';
  }

  String _getFlowStr(num flow) {
    if (flow < 1024) {
      return '${flow.toStringAsFixed(2)}kb';
    }

    return '${(flow / 1024).toStringAsFixed(2)}mb';
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
