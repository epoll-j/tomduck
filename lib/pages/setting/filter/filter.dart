import 'package:bruno/bruno.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tomduck/config/app_config.dart';
import 'package:tomduck/database/database.dart';

const FILTER_MODE_KEY = 'filter_mode_key';
const WHITE_LIST_KEY = 'white_list_key';
const BLACK_LIST_KEY = 'black_list_key';

class Filter extends StatefulWidget {
  @override
  State<Filter> createState() => _FilterState();
}

class _FilterState extends State<Filter> {
  UniqueKey _blackListKey = UniqueKey();
  final List<String> _blackList = [];
  UniqueKey _whiteListKey = UniqueKey();
  final List<String> _whiteList = [];
  String _filterMode = '不使用';

  @override
  void initState() {
    super.initState();
    var mode = Database.sharedPreferences?.getInt(FILTER_MODE_KEY) ?? -1;
    if (mode != -1) {
      _filterMode = mode == 0 ? '白名单' : '黑名单';
    }

    var whiteList =
        Database.sharedPreferences?.getStringList(WHITE_LIST_KEY) ?? [];
    var blackList =
        Database.sharedPreferences?.getStringList(BLACK_LIST_KEY) ?? [];
    setState(() {
      _whiteList.addAll(whiteList);
      _blackList.addAll(blackList);
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  void onSave() {
    var mode = -1;
    if (_filterMode != '不使用') {
      mode = _filterMode == '白名单' ? 0 : 1;
    }
    Database.sharedPreferences?.setInt(FILTER_MODE_KEY, mode);
    _whiteList.removeWhere((element) => element == '');
    _blackList.removeWhere((element) => element == '');
    Database.sharedPreferences?.setStringList(WHITE_LIST_KEY, _whiteList);
    Database.sharedPreferences?.setStringList(BLACK_LIST_KEY, _blackList);
    BrnToast.show(
      "保存成功",
      context,
      duration: BrnDuration.short,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '过滤器',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        backgroundColor: Colors.white,
      ),
      backgroundColor: AppConfig.backgroundColor,
      body: Container(
        padding: EdgeInsets.all(15.w),
        child: ListView(
          children: [
            BrnBaseTitle(
              title: "选择过滤模式",
              subTitle: "黑白名单只能单选一项",
            ),
            BrnPortraitRadioGroup.withSimpleList(
              options: const [
                '白名单',
                '黑名单',
                '不使用',
              ],
              selectedOption: _filterMode,
              onChanged: (BrnPortraitRadioGroupOption? old,
                  BrnPortraitRadioGroupOption? newList) {
                _filterMode = newList!.title!;
              },
            ),
            const SizedBox(
              height: 10,
            ),
            _buildFormGroup(
                _whiteListKey,
                '白名单',
                '只监控下列域名',
                _whiteList,
                (index, val) => setState(() {
                      _whiteList.setAll(index, [val]);
                    }),
                () => setState(() {
                      _whiteList.add('');
                    }),
                (index) => setState(() {
                      _whiteListKey = UniqueKey();
                      _whiteList.removeAt(index);
                    })),
            _buildFormGroup(
                _blackListKey,
                '黑名单',
                '不监控下列域名',
                _blackList,
                (index, val) => setState(() {
                      _blackList.setAll(index, [val]);
                    }),
                () => setState(() {
                      _blackList.add('');
                    }),
                (index) => setState(() {
                      _blackListKey = UniqueKey();
                      _blackList.removeAt(index);
                    })),
            const SizedBox(
              height: 10,
            ),
            BrnBottomButtonPanel(
              mainButtonName: '保存',
              mainButtonOnTap: onSave,
            )
          ],
        ),
      ),
    );
  }

  List<Widget> _buildFormItem(String title, List list,
      void Function(int, String) onChange, void Function(int) onDelete) {
    List<Widget> widgets = [];
    for (var i = 0; i < list.length; i++) {
      var item = BrnTextInputFormItem(
        title: "$title${i + 1}",
        hint: "可输入正则表达式或通配符*",
        prefixIconType: BrnPrefixIconType.remove,
        onRemoveTap: () => onDelete(i),
        onChanged: (newValue) {
          onChange(i, newValue);
        },
        controller: TextEditingController()..text = list[i],
      );
      widgets.add(item);
    }

    return widgets;
  }

  Widget _buildFormGroup(
      Key? key,
      String title,
      String subTitle,
      List list,
      void Function(int, String) onChange,
      void Function() onAdd,
      void Function(int) onDelete) {
    return Stack(
      key: key,
      children: [
        BrnExpandFormGroup(
          title: title,
          subTitle: subTitle,
          children: _buildFormItem(title, list, onChange, onDelete),
        ),
        Positioned(
          top: 35.w,
          right: 40.w,
          child: GestureDetector(
              onTap: onAdd,
              child: Text(
                '添加',
                style: TextStyle(
                    color: AppConfig.mainColor, fontWeight: FontWeight.bold),
              )),
        )
      ],
    );
  }
}
