import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../config/app_config.dart';

class BasicScaffold extends StatelessWidget {
  final String title;
  final Widget child;
  final FloatingActionButton? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final Color? backgroundColor;
  final EdgeInsets? padding;

  const BasicScaffold({super.key, required this.title, this.floatingActionButton, this.floatingActionButtonLocation, required this.child, this.backgroundColor, this.padding});

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
      backgroundColor: backgroundColor ?? AppConfig.backgroundColor,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      body: Container(
        padding: padding ?? EdgeInsets.all(15.w),
        child: child,
      ),
    );
  }
}
