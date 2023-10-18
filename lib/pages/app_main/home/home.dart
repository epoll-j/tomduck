import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tomduck/config/app_config.dart';
import 'package:tomduck/pages/app_main/home/components/setting_card.dart';
import '../../../components/update_app/check_app_version.dart';
import '../../../config/app_env.dart' show appEnv;
import 'provider/counterStore.p.dart';
import 'components/server_card.dart';
import 'components/flow_card.dart';
import 'components/resource_card.dart';

class Home extends StatefulWidget {
  const Home({Key? key, this.params}) : super(key: key);
  final dynamic params;

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  late CounterStore _counter;
  FocusNode blankNode = FocusNode(); // 响应空白处的焦点的Node

  @override
  Widget build(BuildContext context) {
    super.build(context);
    _counter = Provider.of<CounterStore>(context);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: AppConfig.backgroundColor,
        leading: Container(
          margin: EdgeInsets.only(left: 15.w),
          child: const Image(image: AssetImage('asset/images/logo.png')),
        ),
        leadingWidth: 100,
        actions: [
          Container(
              margin: EdgeInsets.only(right: 15.w),
              width: 150.w,
              child: FractionallySizedBox(
                heightFactor: 0.6,
                child: CupertinoButton(
                  onPressed: () {},
                  padding: EdgeInsets.zero,
                  pressedOpacity: 0.8,
                  borderRadius: BorderRadius.horizontal(
                      left: Radius.circular(25.h),
                      right: Radius.circular(25.h)),
                  color: AppConfig.mainColor,
                  child: const Text(
                    "启动",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ))
        ],
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppConfig.mainColor, AppConfig.backgroundColor]),
          ),
        ),
      ),
      body: GestureDetector(
        onTap: () {
          // 点击空白页面关闭键盘
          FocusScope.of(context).requestFocus(blankNode);
        },
        child: contextWidget(),
      ),
    );
  }

  Widget contextWidget() {
    return Container(
      color: AppConfig.backgroundColor,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: List.generate(1, (index) {
          return Column(
            children: <Widget>[
              SettingCard(),
              // ServerCard(),
              const SizedBox(height: 20),
              FlowCard(),
              const SizedBox(height: 20),
              ResourceCard(),
            ],
          );
        }),
      ),
    );
  }
}
