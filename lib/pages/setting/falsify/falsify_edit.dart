import 'package:bruno/bruno.dart';
import 'package:flutter/material.dart';
import 'package:tomduck/components/layouts/basic_scaffold.dart';
import 'package:tomduck/config/app_config.dart';
import 'package:tomduck/database/falsify_model.dart';

class FalsifyEdit extends StatefulWidget {
  FalsifyEdit({super.key, this.params}) {
    params ??= {
      'enable': false,
      'action': 0,
      'group_id': 0,
      'title': '',
      'domain': '',
      'path': '',
      'redirect': '',
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
                value: widget.params['enable'],
                activeColor: AppConfig.mainColor,
                onChanged: (bool value) {
                  setState(() {
                    widget.params['enable'] = value;
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
              title: '域名',
              subTitle: '请求域名，如：baidu.com，不需要填写http',
              controller: TextEditingController(text: widget.params['domain']),
              onChanged: (val) => {widget.params['domain'] = val},
            ),
            BrnTextInputFormItem(
              title: 'Path',
              subTitle: '请求路径，如：/api/v1/*',
              controller: TextEditingController(text: widget.params['path']),
              onChanged: (val) => {widget.params['path'] = val},
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
                  title: '重定向到',
                  subTitle: '重定向到对应地址，如：http://google.com/page',
                  controller:
                      TextEditingController(text: widget.params['redirect']),
                  onChanged: (val) => {widget.params['redirect'] = val},
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
                child: BrnTextInputFormItem(
                  title: '请求体替换',
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
      await FalsifyModel().update({'id': widget.params['id']}, Map<String, Object?>.from(widget.params));
    } else {
      var id =
          await FalsifyModel().insert(Map<String, Object?>.from(widget.params));
      widget.params['id'] = id;
    }
    if (context.mounted) {
      print(widget.params['id']);
      BrnToast.show(
        '保存成功',
        context,
        duration: BrnDuration.short,
      );
    }
  }
}
