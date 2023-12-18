
import 'package:flutter/material.dart';
import 'package:tomduck/pages/app_main/history/history_item.dart';
import 'package:tomduck/pages/app_main/history/session_detail.dart';
import 'package:tomduck/pages/setting/falsify/falsify_edit.dart';
import 'package:tomduck/pages/setting/filter/filter.dart';
import 'package:tomduck/pages/setting/cert/cert.dart';
import '../pages/setting/falsify/falsify.dart';
import 'route_name.dart';
import '../pages/error_page/error_page.dart';
import '../pages/app_main/app_main.dart';
import '../pages/splash/splash.dart';
import '../pages/test_demo/test_demo.dart';
import '../pages/Login/Login.dart';

final String initialRoute = RouteName.splashPage; // 初始默认显示的路由

final Map<String,
        StatefulWidget Function(BuildContext context, {dynamic params})>
    routesData = {
  // 页面路由定义...
  RouteName.appMain: (context, {params}) => AppMain(params: params),
  RouteName.splashPage: (context, {params}) => SplashPage(),
  RouteName.error: (context, {params}) => ErrorPage(params: params),
  RouteName.testDemo: (context, {params}) => TestDemo(params: params),
  RouteName.login: (context, {params}) => Login(params: params),
  RouteName.filter: (context, {params}) => Filter(),
  RouteName.falsify: (context, {params}) => Falsify(params: params),
  RouteName.falsifyEdit: (context, {params}) => FalsifyEdit(params: params),
  RouteName.historyItem: (context, {params}) => HistoryItem(params: params),
  RouteName.sessionDetail: (context, {params}) => SessionDetail(params: params),
  RouteName.cert: (context, {params}) => Cert(),
};
