import 'package:bruno/bruno.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swipe_action_cell/core/cell.dart';
import 'package:intl/intl.dart';
import 'package:iflow/database/task_model.dart';
import '../../../components/layouts/basic_scaffold.dart';
import '../../../config/app_config.dart';

class HistoryItem extends StatefulWidget {
  final dynamic params;

  const HistoryItem({super.key, this.params});

  @override
  State<HistoryItem> createState() => _HistoryItemState();
}

class _HistoryItemState extends State<HistoryItem> {
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
      title: dateFormat.format(
          DateTime.fromMillisecondsSinceEpoch(widget.params['create_time'])),
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
        onTap: () => {
          Navigator.pushNamed(context, "/sessionDetail", arguments: history)
        },
        child: FractionallySizedBox(
          widthFactor: 0.95,
          child: BrnShadowCard(
              padding: const EdgeInsets.all(10),
              child:
                  Column(mainAxisAlignment: MainAxisAlignment.start, children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                        child: Text(
                      history['host'],
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: TextStyle(
                          color: AppConfig.mainColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    )),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                        child: Text(
                      history['uri'],
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ))
                  ],
                ),
                SizedBox.fromSize(
                  size: const Size.fromHeight(10),
                ),
                Row(
                  // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.only(left: 5, right: 5),
                      color: _httpCodeColor(history['http_code']),
                      child: Text(
                        history['http_code'].toString(),
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Container(
                      width: 10,
                    ),
                    Text(history['methods'],
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    Container(
                      width: 10,
                    ),
                    Text((history['suffix'] ?? '').toUpperCase(),
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                SizedBox.fromSize(
                  size: const Size.fromHeight(10),
                ),
                Row(
                  children: [
                    Text('#${history['id']}'),
                    Container(
                      width: 10,
                    ),
                    Text(dateFormat.format(DateTime.fromMillisecondsSinceEpoch(
                        history['create_time'])))
                  ],
                )
              ])),
        ),
      ),
    );
  }

  Color _httpCodeColor(code) {
    if (code.runtimeType == int && code < 400) {
      return Colors.green;
    }
    return Colors.redAccent;
  }

  void loadHistory() async {
    List<Map<String, dynamic>> dbList = await TaskModel().rawQuery(
        'select * from session where task_id = ${widget.params['id']} order by create_time desc');
    List<Map<String, dynamic>> result = List<Map<String, dynamic>>.generate(
        dbList.length, (index) => Map<String, dynamic>.from(dbList[index]),
        growable: true);
    Map<String, dynamic> a = result[0];
    setState(() {
      historyData = result;
    });
  }
}
