import 'dart:async';

import 'package:flutter/material.dart';
import 'package:bruno/bruno.dart';
import 'package:provider/provider.dart';
import 'package:tomduck/database/task_model.dart';
import 'package:tomduck/provider/proxy.p.dart';
import 'package:tomduck/utils/channel_tools.dart';
import 'home_item_card.dart';

class ServerCard extends StatefulWidget {
  @override
  State<ServerCard> createState() => _ServerCardState();
}

class _ServerCardState extends State<ServerCard> {
  late Timer _timer;
  late ProxyStore _proxyStore;

  @override
  Widget build(BuildContext context) {
   _proxyStore = Provider.of<ProxyStore>(context);
    return HomeItemCard(
      children: [
        const Text('基础信息', style: TextStyle(fontWeight: FontWeight.bold)),
        Row(children: [serverBasic(), statusBtn()])
      ],
    );
  }

  Widget serverBasic() {
    return Expanded(
        flex: 2,
        child: BrnPairInfoTable(
            isValueAlign: true,
            itemSpacing: 4,
            rowDistance: 10,
            children: [
              BrnInfoModal(keyPart: "代理服务:", valuePart: "192.168.1.1:8001"),
              BrnInfoModal(keyPart: "本地服务:", valuePart: "192.168.1.1.8002")
            ]));
  }

  Widget statusBtn() {

    return Expanded(
        child: IconButton(
      icon: const Icon(Icons.favorite),
      iconSize: 40,
      color: Colors.red,
      onPressed: () async {
        var taskId = await TaskModel().insert({});
        _proxyStore.taskId = taskId;
        _proxyStore.state = 1;
        ChannelTools().invokeMethod("start_proxy", { "taskId": taskId }).then((value) => {
          _timer = Timer.periodic(const Duration(milliseconds: 1000), (timer) {
            _proxyStore.update();
          })
        });
      },
    ));
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    if (_timer != null) {
      _timer.cancel();
    }
  }
}
