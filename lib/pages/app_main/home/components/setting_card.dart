import 'package:bruno/bruno.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iflow/config/app_config.dart';
import 'package:iflow/iconfont/icon_font.dart';

class SettingCard extends StatelessWidget {

  final _itemList = [{'title': '证书配置', 'icon': IconFont.icon_https, 'path': '/cert'}, {'title': '过滤器', 'icon': IconFont.icon_guolvqi, 'path': '/filter'},{'title': '请求篡改', 'icon': IconFont.icon_xiugai, 'path': '/falsify'},{'title': '使用说明', 'icon': IconFont.icon_help, 'action': 'help'}];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: _itemList.map((e) =>  _buildItem(context,e)).toList(),
    );
  }

  Widget _buildItem(BuildContext context, item) {
    return GestureDetector(
      onTap: () {
        if (item.containsKey('action')) {
          String action = item['action'];
          if (action == 'help') {
            BrnEnhanceOperationDialog enhanceOperationDialog = BrnEnhanceOperationDialog(
              context: context,
              titleText: "暂仅支持WiFi网络下使用",
              descText: "1、连接WiFi;\n2、点击软件右上方启动，如需解析HTTPS数据则点击证书配置功能进行操作;\n3、打开手机的 设置 -> 无线局域网 -> 已连接WiFi后面的叹号 -> 页面底部配置代理 -> 手动 -> 服务器127.0.0.1，端口9527 -> 右上角存储;",
              mainButtonText: "我知道了",
              themeData: BrnDialogConfig(
                contentTextAlign: TextAlign.start
              ),
            );
            enhanceOperationDialog.show();
          }
        } else {
          Navigator.pushNamed(context, item['path']);
        }
      },
      child: SizedBox(
        height: 130.h,
        width: 130.h,
        child: BrnShadowCard(
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Icon(item['icon'], color: AppConfig.mainColor,),
              Text(item['title'], style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF333333)),)
            ],
          ),
        ),
      ),
    );
  }
}