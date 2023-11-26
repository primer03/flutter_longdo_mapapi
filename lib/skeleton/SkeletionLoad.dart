import 'package:flutter/material.dart';
import 'package:skeleton_text/skeleton_text.dart';

class SkeletonLoad extends StatefulWidget {
  final double width;
  final double height;
  const SkeletonLoad._({Key? key, required this.width, required this.height})
      : super(key: key);
  const SkeletonLoad.square({required double width, required double height})
      : this._(width: width, height: height);

  @override
  State<SkeletonLoad> createState() => _SkeletonLoadState();
}

class _SkeletonLoadState extends State<SkeletonLoad> {
  @override
  Widget build(BuildContext context) => SkeletonAnimation(
        child: Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(5),
          ),
        ),
      );
}
