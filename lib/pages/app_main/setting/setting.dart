import 'package:bruno/bruno.dart';
import 'package:flutter/material.dart';
import 'package:tomduck/components/layouts/basic_scaffold.dart';

import '../../../config/app_config.dart';
import '../../../iconfont/icon_font.dart';

class Setting extends StatefulWidget {
  @override
  State<Setting> createState() => _SettingState();
}

class _SettingState extends State<Setting> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final List _itemList = [
    {
      'title': '证书配置',
      'subTitle': '正确配置证书后即可解析HTTPS数据包',
      'icon': IconFont.icon_https,
      'path': '/cert'
    },
    {
      'title': '过滤器',
      'subTitle': '设定过滤规则，仅解析命中规则的数据包',
      'icon': IconFont.icon_guolvqi,
      'path': '/filter'
    },
    {
      'title': '请求篡改',
      'subTitle': '自定义修改请求参数、响应内容',
      'icon': IconFont.icon_xiugai,
      'path': '/falsify'
    },
    {
      'title': '使用说明',
      'subTitle': '软件使用说明，请按说明进行正确设置',
      'icon': IconFont.icon_help,
      'action': 'help'
    },
    {
      'title': '联系我',
      'subTitle': '提BUG、提需求、提建议',
      'icon': IconFont.icon_contact,
      'action': 'contact'
    }
  ];

  @override
  Widget build(BuildContext context) {
    return BasicScaffold(
        title: "设置",
        child: ListView(
          children: buildList(),
        ));
  }

  List<Widget> buildList() {
    List<Widget> children = [];
    for (var item in _itemList) {
      children.add(Container(
        margin: const EdgeInsets.only(top: 5),
        color: Colors.white,
        child: ListTile(
          title: Text(item['title']),
          subtitle: Text(item['subTitle']),
          leading: Icon(item['icon'], color: AppConfig.mainColor),
          onTap: () {
            if (item.containsKey('action')) {
              String action = item['action'];
              if (action == 'help') {
                BrnEnhanceOperationDialog(
                  context: context,
                  titleText: "暂仅支持WiFi网络下使用",
                  descText:
                      "1、连接WiFi;\n2、点击软件右上方启动，如需解析HTTPS数据则点击证书配置功能进行操作;\n3、打开手机的 设置 -> 无线局域网 -> 已连接WiFi后面的叹号 -> 页面底部配置代理 -> 手动 -> 服务器127.0.0.1，端口9527 -> 右上角存储;",
                  mainButtonText: "我知道了",
                  themeData: BrnDialogConfig(contentTextAlign: TextAlign.start),
                ).show();
              } else if (action == 'contact') {
                BrnEnhanceOperationDialog(
                  iconType: BrnDialogConstants.iconSuccess,
                  context: context,
                  titleText: "联系方式",
                  descText:
                  "Email: epoll@foxmail.com\n\nGithub: https://github.com/epoll-j/tomduck/issues",
                  mainButtonText: "我知道了",
                  themeData: BrnDialogConfig(contentTextAlign: TextAlign.start),
                ).show();
              }
            } else {
              Navigator.pushNamed(context, item['path']);
            }
          },
        ),
      ));
    }
    return children;
  }
}
