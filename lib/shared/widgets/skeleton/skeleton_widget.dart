import 'package:flutter/material.dart';
import 'package:moodie/shared/themes/radius.dart';
import 'package:moodie/shared/themes/spacing.dart';
import 'package:skeleton_animation/skeleton_animation.dart';

class SkeletonWidget extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final Widget? skeleton;
  final double? width, height;

  const SkeletonWidget({
    Key? key,
    required this.isLoading,
    required this.child,
    this.skeleton,
    this.width,
    this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Padding(
        padding: const EdgeInsets.all(4.0),
        child: SizedBox(
          width: width,
          height: height,
          child: skeleton ?? Skeleton(borderRadius: BorderRadius.circular(5.0)),
        ),
      );
    } else {
      return child;
    }
  }
}

class SkeletonAvatar extends StatelessWidget {
  final double? high, width;

  const SkeletonAvatar({Key? key, this.high, this.width}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        maxHeight: 80,
        maxWidth: 80,
      ),
      child: Skeleton(
        height: high ?? 12,
        width: width ?? 12,
        borderRadius: BorderRadius.circular(
          CustomRadius.defaultRadius,
        ),
      ),
    );
  }
}
