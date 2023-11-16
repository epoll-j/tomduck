import 'package:bruno/bruno.dart';
import 'package:flutter/material.dart';
import 'package:tomduck/components/layouts/basic_scaffold.dart';
import 'package:tomduck/config/app_config.dart';
import 'package:tomduck/database/falsify_model.dart';

class FalsifyEdit extends StatefulWidget {
  FalsifyEdit({super.key, this.params}) {
    params ??= {
      'enable': 0,
      'action': 0,
      'group_id': 0,
      'title': '',
      'uri': '',
      'redirect_host': '',
      'redirect_port': 80,
      'req_body': '',
      'req_param': '',
      'resp_body': ''
    };
  }
  dynamic params;

  @override
  State<FalsifyEdit> createState() => _FalsifyEditState();
}

class _FalsifyEditState extends State<FalsifyEdit> {
  @override
  Widget build(BuildContext context) {
    return BasicScaffold(
        title: "编辑规则",
        child: ListView(
          children: [
            BrnBaseTitle(
              title: "是否启用",
              customActionWidget: Switch(
                value: widget.params['enable'] == 0 ? false : true,
                activeColor: AppConfig.mainColor,
                onChanged: (bool value) {
                  setState(() {
                    widget.params['enable'] = value ? 1 : 0;
                  });
                },
              ),
            ),
            BrnTextInputFormItem(
              title: '名称',
              controller: TextEditingController(text: widget.params['title']),
              onChanged: (val) => {widget.params['title'] = val},
            ),
            BrnTextInputFormItem(
              title: '资源路径',
              isRequire: true,
              subTitle: '请求资源路径，如baidu.com/search，可用*通配符',
              controller: TextEditingController(text: widget.params['uri']),
              onChanged: (val) => {widget.params['uri'] = val},
            ),
            BrnRadioInputFormItem(
              title: '篡改行为',
              options: const ['修改请求/响应参数', '重定向'],
              value: widget.params['action'] == 0 ? '修改请求/响应参数' : '重定向',
              onChanged: (oldVal, newVal) => setState(() {
                widget.params['action'] = newVal == '重定向' ? 1 : 0;
              }),
            ),
            Visibility(
                visible: widget.params['action'] == 1,
                child: BrnTextInputFormItem(
                  title: '重定向域名',
                  subTitle: '重定向到对应域名，如：google.com',
                  controller: TextEditingController(
                      text: widget.params['redirect_host']),
                  onChanged: (val) => {widget.params['redirect_host'] = val},
                )),
            Visibility(
                visible: widget.params['action'] == 1,
                child: BrnTextInputFormItem(
                  title: '重定向端口',
                  subTitle: '重定向到指定端口，http默认80，https默认443',
                  controller: TextEditingController(
                      text: widget.params['redirect_port'].toString()),
                  onChanged: (val) => {widget.params['redirect_port'] = int.tryParse(val) ?? 80},
                )),
            Visibility(
                visible: widget.params['action'] == 0,
                child: BrnTextInputFormItem(
                  title: 'URL参数替换',
                  controller:
                      TextEditingController(text: widget.params['req_param']),
                  onChanged: (val) => {widget.params['req_param'] = val},
                )),
            Visibility(
                visible: widget.params['action'] == 0,
                child: BrnTextBlockInputFormItem(
                  title: '请求体替换',
                  subTitle: '如：{"id": 0, "title": "666"}',
                  controller:
                      TextEditingController(text: widget.params['req_body']),
                  onChanged: (val) => {widget.params['req_body'] = val},
                )),
            Visibility(
                visible: widget.params['action'] == 0,
                child: BrnTextBlockInputFormItem(
                  title: '响应体替换',
                  subTitle: '如：{"code": 0, "data": {"money": 10000000}}',
                  controller:
                      TextEditingController(text: widget.params['resp_body']),
                  onChanged: (val) => {widget.params['resp_body'] = val},
                )),
            const SizedBox(
              height: 10,
            ),
            BrnBottomButtonPanel(
              mainButtonName: '保存',
              mainButtonOnTap: onSave,
            )
          ],
        ));
  }

  onSave() async {
    if (widget.params['id'] != null) {
      await FalsifyModel().update({'id': widget.params['id']},
          Map<String, Object?>.from(widget.params));
    } else {
      var id =
          await FalsifyModel().insert(Map<String, Object?>.from(widget.params));
      widget.params['id'] = id;
    }
    if (context.mounted) {
      BrnToast.show(
        '保存成功',
        context,
        duration: BrnDuration.short,
      );
      Navigator.pop(context);
    }
  }
}
