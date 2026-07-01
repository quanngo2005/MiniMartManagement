import 'package:flutter/material.dart';

class SkeletonLine extends StatelessWidget {
  const SkeletonLine({required this.width, required this.height, super.key});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SkeletonBox(
      width: width,
      height: height,
      borderRadius: BorderRadius.circular(8),
    );
  }
}

class SkeletonCircle extends StatelessWidget {
  const SkeletonCircle({required this.size, super.key});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SkeletonBox(
      width: size,
      height: size,
      borderRadius: BorderRadius.circular(size / 2),
    );
  }
}

class SkeletonBox extends StatelessWidget {
  const SkeletonBox({
    required this.width,
    required this.height,
    required this.borderRadius,
    super.key,
  });

  final double width;
  final double height;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F0),
        borderRadius: borderRadius,
      ),
      child: SizedBox(width: width, height: height),
    );
  }
}
