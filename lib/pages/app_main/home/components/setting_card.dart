import 'package:bruno/bruno.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tomduck/config/app_config.dart';
import 'package:tomduck/iconfont/icon_font.dart';

class SettingCard extends StatelessWidget {

  final _itemList = [{'title': '证书配置', 'icon': IconFont.icon_https}, {'title': '过滤器', 'icon': IconFont.icon_guolvqi, 'path': '/filter'},{'title': '请求篡改', 'icon': IconFont.icon_xiugai},{'title': '请求转发', 'icon': IconFont.icon_zhuanfa}];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: _itemList.map((e) =>  _buildItem(context,e)).toList(),
    );

  }

  Widget _buildItem(BuildContext context, item) {
    return GestureDetector(
      onTap: ()=> {
        Navigator.pushNamed(context, item['path'])
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