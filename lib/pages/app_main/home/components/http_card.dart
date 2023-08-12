import 'package:flutter/material.dart';
import 'package:bruno/bruno.dart';
import 'home_item_card.dart';

class HttpCard extends StatefulWidget {
  @override
  State<HttpCard> createState() => _HttpCardState();
}

class _HttpCardState extends State<HttpCard> {
  var dataList = [
    BrnDoughnutDataItem(title: '示例', value: 10, color: Colors.amber),
    BrnDoughnutDataItem(title: '示例2', value: 40, color: Colors.blue),
    BrnDoughnutDataItem(title: '示例4', value: 30, color: Colors.yellow),
    BrnDoughnutDataItem(title: '示例5', value: 20, color: Colors.red)
  ];

  @override
  Widget build(BuildContext context) {
    return HomeItemCard(children: [
      const Text(
        '资源类型',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      resourceCard()
    ]);
  }

  Widget resourceCard() {
    return Column(
      children: [
        BrnDoughnutChart(
          padding: const EdgeInsets.all(50),
          width: 200,
          height: 200,
          data: dataList,
          // selectedItem: selectedItem,
          showTitleWhenSelected: true,
          // selectCallback: (BrnDoughnutDataItem? selectedItem) {
          //   setState(() {
          //     this.selectedItem = selectedItem;
          //   });
          // },
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
