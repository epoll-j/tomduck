import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tomduck/config/app_config.dart';
import 'package:tomduck/database/falsify_model.dart';
import 'package:tomduck/pages/app_main/home/components/setting_card.dart';
import '../../../database/database.dart';
import '../../../database/task_model.dart';
import '../../../provider/proxy.p.dart';
import '../../../utils/channel_tools.dart';
import 'components/flow_card.dart';
import 'components/resource_card.dart';

const statusText = {0: '启动', 1: '停止', 2: '启动中'};

class Home extends StatefulWidget {
  const Home({Key? key, this.params}) : super(key: key);
  final dynamic params;

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  late ProxyStore _proxyStore;
  late Timer _timer;
  FocusNode blankNode = FocusNode(); // 响应空白处的焦点的Node

  @override
  Widget build(BuildContext context) {
    super.build(context);
    _proxyStore = Provider.of<ProxyStore>(context);
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
                  onPressed: () async {
                    if (_proxyStore.state == 2) {
                      return;
                    }
                    if (_proxyStore.state != 1) {
                      _proxyStore.updateState(2);
                      var param = await loadProxyParam();
                      _proxyStore.taskId = param['taskId'];
                      ChannelTools().invokeMethod('start_proxy', param).then((value) => {
                            _proxyStore.updateState(1),
                            _timer = Timer.periodic(
                                const Duration(milliseconds: 1000), (timer) {
                              _proxyStore.update();
                            })
                          });
                    } else {
                      _timer.cancel();
                      ChannelTools().invokeMethod('stop_proxy', {}).then(
                          (value) => {_proxyStore.updateState(0)});
                    }
                  },
                  padding: EdgeInsets.zero,
                  pressedOpacity: 0.8,
                  borderRadius: BorderRadius.horizontal(
                      left: Radius.circular(25.h),
                      right: Radius.circular(25.h)),
                  color: AppConfig.mainColor,
                  child: Text(
                    statusText[_proxyStore.state]!,
                    style: const TextStyle(fontWeight: FontWeight.bold),
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

  Future<Map<String, dynamic>> loadProxyParam() async {
    var taskId = await TaskModel().insert({});
    var mode = Database.sharedPreferences?.getInt(AppConfig.cacheKey[CacheKey.FILTER_MODE_KEY]!) ?? -1;
    Map<String, dynamic> filter = {
      'type': mode
    };
    if (mode != -1) {
      filter['type'] = mode;
      filter['domain'] = Database.sharedPreferences?.getStringList(AppConfig.cacheKey[mode == 0 ? CacheKey.WHITE_LIST_KEY : CacheKey.BLACK_LIST_KEY]!) ?? [];
    }
    var falsifyList = await FalsifyModel().rawQuery('select * from falsify where enable = 1');
    return { 'taskId': taskId, 'filter': filter, 'falsify': falsifyList };
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
