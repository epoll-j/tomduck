import 'package:bruno/bruno.dart';
import 'package:flutter/material.dart';

class BasicCard extends StatelessWidget {
  const BasicCard({
    Key? key,
    required this.child,
  }) : super(key: key);
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
        widthFactor: 0.95,
        child: BrnShadowCard(
          padding: const EdgeInsets.all(10),
          child: child,
        ));
  }
}
