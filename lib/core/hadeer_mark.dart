import 'package:flutter/material.dart';

class HadeerMark extends StatelessWidget {
  const HadeerMark({super.key, this.size = 46});
  final double size;
  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(size * .25),
    child: Image.asset('assets/brand/hadeer.png', width: size, height: size, semanticLabel: 'hadeer'),
  );
}
