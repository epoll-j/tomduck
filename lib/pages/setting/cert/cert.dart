import 'package:flutter/material.dart';
import 'package:iflow/components/layouts/basic_card.dart';
import 'package:iflow/components/layouts/basic_scaffold.dart';
import 'package:iflow/utils/channel_tools.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../config/app_config.dart';

class Cert extends StatefulWidget {
  final dynamic params;

  const Cert({Key? key, this.params}) : super(key: key);

  @override
  State<Cert> createState() => _CertState();
}

class _CertState extends State<Cert> {
  @override
  void initState() {
    super.initState();
    ChannelTools().invokeMethod('start_local_http_service');
  }

  @override
  void dispose() {
    super.dispose();
    ChannelTools().invokeMethod('stop_local_http_service');
  }

  @override
  Widget build(BuildContext context) {
    return BasicScaffold(
        title: '证书配置',
        child: Column(
          children: [
            BasicCard(
                child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.dataset_linked,
                      color: AppConfig.mainColor,
                      size: 40,
                    ),
                    Container(
                      margin: const EdgeInsets.only(left: 20),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "iflow HTTPS 根证书",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          Text("证书安装并信任后即可抓取HTTPS数据包", style: TextStyle(fontSize: 12))
                        ],
                      ),
                    )
                  ],
                ),
                Container(
                  margin: const EdgeInsets.only(top: 40, bottom: 20),
                  width: MediaQuery.of(context).size.width * 0.7,
                  height: 40,
                  child: MaterialButton(
                    onPressed: () {
                      launchUrl(Uri.parse("http://127.0.0.1:8080"));
                    },
                    textColor: Colors.white,
                    color: AppConfig.mainColor,
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(15))),
                    child: const Text(
                      '下载证书',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                )
              ],
            )),
            SizedBox.fromSize(size: const Size.fromHeight(20),),
            BasicCard(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              const Text('两步完成证书安装及信任', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),),
                _buildStep("① 安装证书", "点击页面上方 “安装证书”，系统将弹出对话框询问是否允许下载配置描述文件，请点击允许。随后打开手机的设置 -> 已下载描述文件 -> 点击右上角安装 -> 输入手机的开机密码 -＞ 再次点击右上角安装 -> 安装。"),
                _buildStep("② 信任证书", "打开手机的 设置 -> 通用-> 关于本机-> 页面最底部证书信任设置 -> 找到 Storm Sniffer CA -> 点击右侧的开关进行开启 -> 弹出的对话框选择 继续即可。")
            ],))
          ],
        ));
  }

  Widget _buildStep(String title, String content) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: AppConfig.mainColor), ),
        Text(content),
      ],
    ),);
  }
}
