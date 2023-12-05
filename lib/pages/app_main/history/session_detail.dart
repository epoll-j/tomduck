import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tomduck/config/app_config.dart';
import 'package:tomduck/utils/common_util.dart';
import 'dart:convert';
import '../../../components/layouts/basic_card.dart';
import '../../../components/layouts/basic_scaffold.dart';

class SessionDetail extends StatefulWidget {
  final dynamic params;

  const SessionDetail({super.key, this.params});

  @override
  State<SessionDetail> createState() => _SessionDetailState();
}

class _SessionDetailState extends State<SessionDetail>
    with SingleTickerProviderStateMixin {
  final List<String> _tabs = ['消息头', '响应', '参数', 'Cookie', '耗时'];
  late TabController _tabController;
  late String? _cookie;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BasicScaffold(
      title: '请求详情',
      padding: const EdgeInsets.all(0),
      child: Column(
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            color: Colors.white,
            child: Theme(
                data: Theme.of(context).copyWith(
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent),
                child: TabBar(
                  tabs: _tabs
                      .map((e) => Tab(
                            text: e,
                          ))
                      .toList(),
                  isScrollable: false,
                  controller: _tabController,
                  labelColor: AppConfig.mainColor,
                  indicatorWeight: 3,
                  indicatorPadding: const EdgeInsets.symmetric(horizontal: 10),
                  unselectedLabelColor: Colors.black,
                  indicatorColor: AppConfig.mainColor,
                  unselectedLabelStyle: const TextStyle(fontSize: 14),
                  labelStyle: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.bold),
                )),
          ),
          SizedBox.fromSize(
            size: const Size.fromHeight(15)
          ),
          Expanded(
            child: IntrinsicHeight(
              child: _buildTabBarView(),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildTabBarView() {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return TabBarView(controller: _tabController, children: [
          SingleChildScrollView(
            child: _buildHeaderDetail(),
          ),
          SingleChildScrollView(
            child: _buildResponseDetail(),
          ),
          SingleChildScrollView(child: _buildParamsDetail()),
          SingleChildScrollView(child: _buildCookieDetail()),
          _buildTimeDetail()
        ]);
      },
    );
    // return TabBarView(controller: _tabController, children: _tabs.map((e) => Container(height: 100, color: Colors.amber,)).toList());
  }

  Widget _buildHeaderDetail() {
    List<Widget> children = [];
    if (!CommonUtil.isEmpty(widget.params['request_header'])) {
      Map requestHeader = json.decode(widget.params['request_header']);
      _cookie = requestHeader.remove('cookie');
      List<Widget> requestChildren = [];
      for (var key in requestHeader.keys) {
        requestChildren.add(_detailItem(key, content: requestHeader[key]));
      }
      children.add(_detailTitle('请求头'));
      children.addAll(requestChildren);
    }
    if (!CommonUtil.isEmpty(widget.params['response_header'])) {
      List<Widget> responseChildren = [];
      Map responseHeader = json.decode(widget.params['response_header']);
      for (var key in responseHeader.keys) {
        responseChildren.add(_detailItem(key, content: responseHeader[key]));
      }
      children.add(_detailTitle('响应头'));
      children.addAll(responseChildren);
    }
    return Column(
      children: children,
    );
  }

  Widget _buildResponseDetail() {
    final file = File(
        '${CommonUtil.documentPath}/Task/task-${widget.params['task_id']}/${widget.params['response_body']}');
    try {
      dynamic bytes = file.readAsBytesSync();
      if (bytes[0] == 0x1F && bytes[1] == 0x8B && bytes[2] == 0x08) {
        bytes = GZipCodec().decode(bytes);
      }
      Widget body = Container();
      String suffix = widget.params['suffix'];
      if (suffix == 'json') {
        body = Text(CommonUtil.prettyPrintJson(utf8.decode(bytes)));
      } else if ([
        'html',
        'css',
        'javascript',
        'plain',
        'xml',
        'csv',
        'xml',
        'xhtml+xml'
      ].contains(suffix)) {
        body = Text(utf8.decode(bytes));
      } else if (['gif', 'jpeg', 'png', 'tiff'].contains(suffix)) {
        body = Image.memory(bytes);
      }

      Widget export = FractionallySizedBox(
        widthFactor: 0.95,
        child: RawMaterialButton(
          onPressed: () async {
            final tempDir = await getTemporaryDirectory();
            final path = '${tempDir.path}/${widget.params['response_body']}';
            final file = File(path);
            await file.writeAsBytes(bytes);
            Share.shareXFiles([XFile(path)]);
          },
          splashColor: Colors.white,
          fillColor: Colors.white,
          highlightElevation: 0,
          elevation: 0,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(15))),
          child: Text(
            "导出",
            style: TextStyle(
                fontWeight: FontWeight.bold, color: AppConfig.mainColor),
          ),
        ),
      );

      return Column(
        children: [
          _detailTitle('预览'),
          _detailItem(suffix.toUpperCase(),
              body: Container(
                margin: const EdgeInsets.symmetric(vertical: 20),
                child: body,
              )),
          export
        ],
      );
    } catch (e) {
      return Container(
        color: Colors.white,
        height: MediaQuery.of(context).size.height,
        child: CommonUtil.noData(),
      );
    }
  }

  Widget _buildParamsDetail() {
    String uri = widget.params['uri'];
    List<Widget> children = [];
    if (!CommonUtil.isEmpty(uri)) {
      List<String> uriSplit = uri.split('?');
      if (uriSplit.length >= 2) {
        List<String> query = uriSplit[1].split('&');
        children.add(_detailTitle('Query'));
        for (var element in query) {
          List<String> params = element.split('=');
          children.add(_detailItem(params[0], content: params[1]));
        }
      }
    }

    try {
      final file = File(
          '${CommonUtil.documentPath}/Task/task-${widget.params['task_id']}/${widget.params['request_body']}');
      dynamic bytes = file.readAsBytesSync();
      if (bytes[0] == 0x1F && bytes[1] == 0x8B && bytes[2] == 0x08) {
        bytes = GZipCodec().decode(bytes);
      }
      String contentType = widget.params['request_content_type'];
      children.add(_detailTitle('Body'));
      if (contentType.contains('json')) {
        children.add(_detailItem(
          'JSON',
          body: Container(
              margin: const EdgeInsets.symmetric(vertical: 20),
              child: Text(CommonUtil.prettyPrintJson(utf8.decode(bytes)))),
        ));
      }

      Widget export = FractionallySizedBox(
        widthFactor: 0.95,
        child: RawMaterialButton(
          onPressed: () async {
            final tempDir = await getTemporaryDirectory();
            final path = '${tempDir.path}/${widget.params['request_body']}';
            final file = File(path);
            await file.writeAsBytes(bytes);
            Share.shareXFiles([XFile(path)]);
          },
          splashColor: Colors.white,
          fillColor: Colors.white,
          highlightElevation: 0,
          elevation: 0,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(15))),
          child: Text(
            "导出",
            style: TextStyle(
                fontWeight: FontWeight.bold, color: AppConfig.mainColor),
          ),
        ),
      );
      children.add(export);
    } catch (e) {}

    return children.isEmpty
        ? Container(
            color: Colors.white,
            height: MediaQuery.of(context).size.height,
            child: CommonUtil.noData(),
          )
        : Column(
            children: children,
          );
  }

  Widget _buildCookieDetail() {
    List<Widget> children = [];
    if (_cookie != null) {
      List<String> cookies = _cookie!.split(';');
      for (var element in cookies) {
        List<String> item = element.split('=');
        children.add(_detailItem(item[0], content: item[1]));
      }
    }
    return _cookie == null
        ? Container(
            color: Colors.white,
            height: MediaQuery.of(context).size.height,
            child: CommonUtil.noData(),
          )
        : Column(
            children: children,
          );
  }

  Widget _buildTimeDetail() {
    List<Widget> children = [];

    num connectTime = widget.params['connect_time'] ?? 0;
    num connectedTime = widget.params['connected_time'] ?? 0;
    num handshakeTime = widget.params['handshake_time'].runtimeType == String ? 0 : widget.params['handshake_time'];
    num requestEndTime = widget.params['request_end_time'] ?? 0;
    num responseEndTime = widget.params['response_end_time'] ?? 0;

    children.add(_detailItem('建立连接', content: '${((connectedTime - connectTime) * 1000).toInt()}ms'));
    children.add(_detailItem('TLS握手', content: '${handshakeTime == 0 ? 0 : ((handshakeTime - connectedTime) * 1000).toInt()}ms'));
    children.add(_detailItem('发送请求', content: '${((requestEndTime - connectedTime) * 1000).toInt()}ms'));
    children.add(_detailItem('请求响应', content: '${((responseEndTime - requestEndTime) * 1000).toInt()}ms'));

    return Column(
      children: children,
    );
  }

  Widget _detailTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: FractionallySizedBox(
        widthFactor: 0.95,
        child: Text(
          title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _detailItem(String title, {String? content, Widget? body}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: BasicCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            body ??
                Text(
                  content!,
                  style: const TextStyle(fontSize: 16),
                )
          ],
        ),
      ),
    );
  }
}
