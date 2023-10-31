import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:json_theme/json_theme.dart';
import 'package:tomduck/components/layouts/basic_layout.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:jh_debug/jh_debug.dart' show DebugMode, jhDebug, jhDebugMain;
import 'package:tomduck/database/database.dart';
import 'routes/generate_route.dart' show generateRoute;
import 'routes/routes_data.dart'; // 路由配置
import 'providers_config.dart' show providersConfig; // providers配置文件
import 'provider/theme_store.p.dart'; // 全局主题
import 'config/common_config.dart' show commonConfig;
import 'package:ana_page_loop/ana_page_loop.dart' show anaAllObs;
import 'utils/app_setup/index.dart' show appSetupInit;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final themeJson = jsonDecode(await rootBundle.loadString('asset/theme/main_theme.json'));

  jhDebugMain(
    appChild: MultiProvider(
      providers: providersConfig,
      child: MyApp(theme: ThemeDecoder.decodeThemeData(themeJson)!,),
    ),
    debugMode: DebugMode.inConsole,
    errorCallback: (details) {},
  );
  Database.initialize();
}

class MyApp extends StatelessWidget {
  final ThemeData theme;
  const MyApp({Key? key, required this.theme}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    jhDebug.setGlobalKey = commonConfig.getGlobalKey;
    appSetupInit();

    return Consumer<ThemeStore>(
      builder: (context, themeStore, child) {
        return BasicLayout(
          child: MaterialApp(
            navigatorKey: jhDebug.getNavigatorKey,
            showPerformanceOverlay: false,
            locale: const Locale('zh', 'CH'),
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('zh', 'CH'),
              Locale('en', 'US'),
            ],
            theme: theme,
            initialRoute: initialRoute,
            onGenerateRoute: generateRoute,
            // 路由处理
            // debugShowCheckedModeBanner: false,
            navigatorObservers: [...anaAllObs()],
          ),
        );
      },
    );
  }
}
