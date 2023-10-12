import 'package:flutter/material.dart';
import 'package:bruno/bruno.dart';
import 'package:provider/provider.dart';
import 'package:tomduck/provider/proxy.p.dart';
import 'home_item_card.dart';

class FlowCard extends StatefulWidget {
  @override
  State<FlowCard> createState() => _FlowCardState();
}

class _FlowCardState extends State<FlowCard> {
  late ProxyStore _proxyStore;

  @override
  Widget build(BuildContext context) {
    _proxyStore = Provider.of<ProxyStore>(context);

    return HomeItemCard(
        align: CrossAxisAlignment.center, children: [title(), statistics()]);
  }

  Widget title() {
    return Container(
      margin: const EdgeInsets.only(bottom: 35),
      child: Column(
        children: [
          Text(
            _proxyStore.state == 0 ? '未开启网络监控' : '已开启网络监控',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          Text('已运行${_proxyStore.time}秒')
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
        BrnNumberInfoItemModel(title: '抓包数量', number: _proxyStore.packageCount.toString(), lastDesc: '个'),
        BrnNumberInfoItemModel(title: '数据上传', number: _proxyStore.uploadFlow.toStringAsFixed(2), lastDesc: 'kb'),
        BrnNumberInfoItemModel(title: '数据下载', number: _proxyStore.downloadFlow.toStringAsFixed(2), lastDesc: 'kb'),
      ],
    );
  }
}
