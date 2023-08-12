import 'package:flutter/material.dart';
import 'package:bruno/bruno.dart';
import 'home_item_card.dart';

class FlowCard extends StatefulWidget {
  @override
  State<FlowCard> createState() => _FlowCardState();
}

class _FlowCardState extends State<FlowCard> {
  @override
  Widget build(BuildContext context) {
    return HomeItemCard(
        align: CrossAxisAlignment.center, children: [title(), statistics()]);
  }

  Widget title() {
    return Container(
      margin: const EdgeInsets.only(bottom: 35),
      child: const Column(
        children: [
          Text(
            '未开启网络监控',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          Text('已经监控xx秒')
        ],
      ),
    );
  }

  Widget statistics() {
    return BrnEnhanceNumberCard(
      rowCount: 3,
      itemTextAlign: TextAlign.left,
      padding: const EdgeInsets.only(left: 25),
      itemChildren: [
        BrnNumberInfoItemModel(title: '抓包数量', number: '24', lastDesc: '个'),
        BrnNumberInfoItemModel(title: '数据上传', number: '180.4', lastDesc: 'kb'),
        BrnNumberInfoItemModel(title: '数据下载', number: '180.2', lastDesc: 'kb'),
      ],
    );
  }
}
