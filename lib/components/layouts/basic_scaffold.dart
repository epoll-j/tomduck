import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../config/app_config.dart';

class BasicScaffold extends StatelessWidget {
  final String title;
  final Widget child;

  const BasicScaffold({super.key, required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        backgroundColor: Colors.white,
      ),
      backgroundColor: AppConfig.backgroundColor,
      body: Container(
        padding: EdgeInsets.all(15.w),
        child: child,
      ),
    );
  }
}
