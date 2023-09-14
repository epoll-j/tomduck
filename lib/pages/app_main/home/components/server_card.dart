import 'package:flutter/material.dart';
import 'package:bruno/bruno.dart';
import 'package:flutter/services.dart';
import 'package:tomduck/utils/channel_tools.dart';
import 'home_item_card.dart';

class ServerCard extends StatefulWidget {
  @override
  State<ServerCard> createState() => _ServerCardState();
}

class _ServerCardState extends State<ServerCard> {
  @override
  Widget build(BuildContext context) {
    return HomeItemCard(
      children: [
        const Text('基础信息', style: TextStyle(fontWeight: FontWeight.bold)),
        Row(children: [serverBasic(), statusBtn(context)])
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

  Widget statusBtn(context) {
    return Expanded(
        child: IconButton(
      icon: const Icon(Icons.favorite),
      iconSize: 40,
      color: Colors.red,
      onPressed: () async {
        ChannelTools().invokeMethod("start_mimt").then((value) => {
          print(value)
        });
      },
    ));
  }
}
