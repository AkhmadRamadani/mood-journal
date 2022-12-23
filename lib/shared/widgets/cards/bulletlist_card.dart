import 'package:flutter/material.dart';
import 'package:moodie/shared/themes/colors.dart';

class BulletList extends StatelessWidget {
  final String text;
  const BulletList({
    Key? key,
    required this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text("• "),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.titleSmall!.copyWith(
                  color: ThemeColor.neutral_900,
                  fontWeight: FontWeight.w400,
                ),
          ),
        ),
      ],
    );
  }
}
