import 'package:flutter/material.dart';
import 'package:bruno/bruno.dart';

class HomeItemCard extends StatefulWidget {
  const HomeItemCard(
      {Key? key, this.align = CrossAxisAlignment.start, required this.children})
      : super(key: key);

  final CrossAxisAlignment align;
  final List<Widget> children;

  @override
  State<HomeItemCard> createState() => _HomeItemCardState();
}

class _HomeItemCardState extends State<HomeItemCard> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BrnShadowCard(
        padding: const EdgeInsets.all(15),
        color: Colors.white,
        child: Column(
            crossAxisAlignment: widget.align, children: widget.children));
  }
}
