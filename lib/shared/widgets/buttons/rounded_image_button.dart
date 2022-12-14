import 'package:flutter/material.dart';
import 'package:moodie/shared/themes/colors.dart';
import 'package:moodie/shared/themes/radius.dart';
import 'package:moodie/shared/themes/spacing.dart';

class RoundedImageButton extends StatelessWidget {
  final String? image;
  final IconData? icon;
  final Color? color;
  final Color? bgColor;
  final Function(int) onPressed;

  const RoundedImageButton(
      {Key? key,
      required this.onPressed,
      this.image,
      this.icon,
      this.bgColor,
      this.color})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        onPressed(1);
      },
      style: ButtonStyle(
        minimumSize: MaterialStateProperty.all(
            const Size(double.minPositive, double.minPositive)),
        backgroundColor: MaterialStateProperty.all(bgColor ?? ThemeColor.white),
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(CustomRadius.defaultRadius),
          ),
        ),
        elevation: MaterialStateProperty.all(0),
        padding: MaterialStateProperty.all(
            const EdgeInsets.all(Spacing.spacing * 2)),
      ),
      child: image != null
          ? Image.asset(
              image ?? '',
              color: color,
            )
          : Icon(
              icon,
              color: color,
            ),
    );
  }
}
