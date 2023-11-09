import 'package:bruno/bruno.dart';
import 'package:flutter/material.dart';
import 'package:tomduck/components/layouts/basic_scaffold.dart';

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
    loadHistory();
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
            Navigator.pushNamed(context, '/falsifyEdit');
          },
        ),
        child: RefreshIndicator(
          onRefresh: () async {
            loadHistory();
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
    return Dismissible(
        key: Key('${falsify['id']}'),
        direction: DismissDirection.endToStart,
        onDismissed: (direction) {
          FalsifyModel().remove({'id': falsify['id']});
          setState(() {
            _falsifyData.removeAt(index);
          });
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('移除 ${falsify['domain']}'),
            backgroundColor: Colors.redAccent,
          ));
        },
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
                          Text(
                            falsify['domain'],
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          Text(falsify['title'] == '' ? '-' : falsify['title']),
                        ],
                      ),
                      Switch(
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
                      )
                    ])),
          ),
        ));
  }

  void loadHistory() async {
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
        'domain': item['domain'],
        'path': item['path'],
        'redirect': item['redirect'],
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
