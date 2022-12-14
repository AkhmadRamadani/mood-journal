import 'package:flutter/material.dart';
import 'package:moodie/shared/themes/radius.dart';
import 'package:moodie/shared/themes/spacing.dart';

class ProfileButton extends StatelessWidget {
  final String image;
  final double? size;
  final bool? isRounded;
  const ProfileButton(
      {Key? key, required this.image, this.size, this.isRounded})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return isRounded != null
        ? CircleAvatar(
            radius: size ?? Spacing.spacing * 6,
            backgroundImage: NetworkImage(image),
          )
        : ClipRRect(
            borderRadius: BorderRadius.circular(CustomRadius.defaultRadius),
            child: Image.network(
              image,
              width: size ?? Spacing.spacing * 6,
              height: size ?? Spacing.spacing * 6,
            ),
          );
  }
}
