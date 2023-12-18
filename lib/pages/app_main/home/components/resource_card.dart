import 'package:flutter/material.dart';
import 'package:bruno/bruno.dart';
import 'package:provider/provider.dart';
import 'package:tomduck/config/app_config.dart';
import '../../../../provider/proxy.p.dart';
import 'home_item_card.dart';

class ResourceCard extends StatefulWidget {
  @override
  State<ResourceCard> createState() => _ResourceCardState();
}

class _ResourceCardState extends State<ResourceCard> {
  late ProxyStore _proxyStore;
  List<Color> colors = [AppConfig.mainColor, Colors.redAccent, Colors.amber, Colors.blueGrey, Colors.deepPurpleAccent, Colors.limeAccent, Colors.brown, Colors.orangeAccent, Colors.teal, Colors.indigo, Colors.white30, Colors.black12, Colors.indigo, Colors.cyan, Colors.purple];
  BrnDoughnutDataItem? selectedItem;

  @override
  Widget build(BuildContext context) {
    _proxyStore = Provider.of<ProxyStore>(context);

    return HomeItemCard(children: [
      const Text(
        '资源类型',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      resourceCard()
    ]);
  }

  Widget resourceCard() {
    var dataList =_proxyStore.suffixList.asMap().keys.map((e) => BrnDoughnutDataItem(title: _proxyStore.suffixList[e]['suffix'], value: double.parse(_proxyStore.suffixList[e]['count'].toString()), color: colors[e])).toList();
    return Column(
      children: [
        BrnDoughnutChart(
          padding: const EdgeInsets.all(50),
          width: 200,
          height: 200,
          data: dataList,
          selectedItem: selectedItem,
          showTitleWhenSelected: true,
          selectCallback: (BrnDoughnutDataItem? selectedItem) {
            setState(() {
              this.selectedItem = selectedItem;
            });
          },
        ),
        SizedBox(
          width: double.infinity,
          child: Center(
            child: DoughnutChartLegend(
                data: dataList, legendStyle: BrnDoughnutChartLegendStyle.wrap),
          ),
        )
      ],
    );
  }
}
