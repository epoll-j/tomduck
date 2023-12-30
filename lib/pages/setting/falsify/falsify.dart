import 'package:bruno/bruno.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_swipe_action_cell/core/cell.dart';
import 'package:iflow/components/layouts/basic_scaffold.dart';

import '../../../config/app_config.dart';
import '../../../database/falsify_model.dart';

class Falsify extends StatefulWidget {
  final dynamic params;

  const Falsify({Key? key, this.params}) : super(key: key);

  @override
  State<Falsify> createState() => _FalsifyState();
}

class _FalsifyState extends State<Falsify> {
  List _falsifyData = [];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BasicScaffold(
        title: '请求篡改',
        floatingActionButton: FloatingActionButton(
          backgroundColor: AppConfig.mainColor,
          child: const Icon(Icons.add),
          onPressed: () {
            Navigator.pushNamed(context, '/falsifyEdit')
                .then((value) => {loadData()});
          },
        ),
        child: _falsifyData.isEmpty
            ? BrnAbnormalStateWidget(
                img: Image.asset('asset/images/no_data.png'),
                title: '暂无数据',
              )
            : RefreshIndicator(
                onRefresh: () async {
                  loadData();
                },
                child: ListView.separated(
                  padding: const EdgeInsets.only(top: 20),
                  itemCount: _falsifyData.length,
                  itemBuilder: (context, index) =>
                      _buildItem(_falsifyData[index], index),
                  separatorBuilder: (BuildContext context, int index) {
                    return const SizedBox(
                      height: 10,
                    );
                  },
                ),
              ));
  }

  Widget _buildItem(dynamic falsify, int index) {
    return SwipeActionCell(
        key: Key('${falsify['id']}'),
        backgroundColor: AppConfig.backgroundColor,
        trailingActions: <SwipeAction>[
          SwipeAction(
            performsFirstActionWithFullSwipe: true,
            title: "删除",
            onTap: (CompletionHandler handler) async {
                await handler(true);
                FalsifyModel().remove({'id': falsify['id']});
                setState(() {
                  _falsifyData.removeAt(index);
                });
            },
            color: Colors.red),
        ],
        child: FractionallySizedBox(
          widthFactor: 0.95,
          child: GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, '/falsifyEdit', arguments: falsify);
            },
            child: BrnShadowCard(
                padding: const EdgeInsets.all(15),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            constraints: BoxConstraints(maxWidth: 500.w),
                            child: Text(
                              falsify['uri'],
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Container(
                            constraints: BoxConstraints(maxWidth: 500.w),
                            child: Text(falsify['title'] == ''
                                ? '-'
                                : falsify['title']),
                          ),
                        ],
                      ),
                      IgnorePointer(
                        ignoring: false,
                        child: Switch(
                          value: falsify['enable'] == 0 ? false : true,
                          activeColor: AppConfig.mainColor,
                          onChanged: (bool value) {
                            var val = value ? 1 : 0;
                            FalsifyModel()
                                .update({'id': falsify['id']}, {'enable': val});
                            setState(() {
                              falsify['enable'] = val;
                            });
                          },
                        ),
                      )
                    ])),
          ),
        ));
  }

  void loadData() async {
    var result = [];
    var dbList = await FalsifyModel()
        .rawQuery("select * from falsify order by create_time desc");
    for (var item in dbList) {
      result.add({
        'id': item['id'],
        'enable': item['enable'],
        'action': item['action'],
        'group_id': item['group_id'],
        'title': item['title'],
        'uri': item['uri'],
        'redirect_host': item['redirect_host'],
        'redirect_port': item['redirect_port'],
        'req_body': item['req_body'],
        'req_param': item['req_param'],
        'resp_body': item['resp_body']
      });
    }
    setState(() {
      _falsifyData = result;
    });
  }
}
