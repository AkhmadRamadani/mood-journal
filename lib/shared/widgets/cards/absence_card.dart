import 'package:flutter/material.dart';
import 'package:moodie/shared/icons/custom_icon.dart';
import 'package:moodie/shared/themes/colors.dart';
import 'package:moodie/shared/themes/radius.dart';
import 'package:moodie/shared/themes/spacing.dart';
import 'package:moodie/shared/widgets/buttons/profile_button.dart';
import 'package:moodie/shared/widgets/buttons/rounded_image_button.dart';
import 'package:moodie/shared/widgets/skeleton/skeleton_widget.dart';

class AbsenceCard extends StatefulWidget {
  final String title, desc, date, type;
  final Function(int) onPressed;
  final bool isLoading;
  final String image;

  const AbsenceCard({
    Key? key,
    required this.title,
    required this.desc,
    required this.date,
    required this.type,
    required this.onPressed,
    required this.isLoading,
    required this.image,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _AbsenceCardState();
}

class _AbsenceCardState extends State<AbsenceCard> {
  Color bgColor = ThemeColor.white,
      fgColor = ThemeColor.primary,
      iconColor = ThemeColor.white,
      mainTextColor = ThemeColor.neutral_900,
      secondaryTextColor = ThemeColor.neutral_500;

  @override
  void initState() {
    super.initState();

    setStyle(widget.type);
  }

  setStyle(type) {
    if (type == 'success') {
      setState(() {
        bgColor = ThemeColor.success_400;
        fgColor = ThemeColor.white;
        iconColor = ThemeColor.neutral_900;
        mainTextColor = ThemeColor.white;
        secondaryTextColor = ThemeColor.white;
      });
    } else if (type == 'alert') {
      setState(() {
        bgColor = ThemeColor.secondary_400;
        fgColor = ThemeColor.white;
        iconColor = ThemeColor.neutral_900;
        mainTextColor = ThemeColor.white;
        secondaryTextColor = ThemeColor.white;
      });
    } else {
      setState(() {
        bgColor = ThemeColor.white;
        fgColor = ThemeColor.primary;
        iconColor = ThemeColor.white;
        mainTextColor = ThemeColor.neutral_900;
        secondaryTextColor = ThemeColor.neutral_500;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => widget.onPressed(1),
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(bgColor),
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(CustomRadius.defaultRadius),
          ),
        ),
        elevation: MaterialStateProperty.all(0),
        padding: MaterialStateProperty.all(
            const EdgeInsets.all(Spacing.spacing * 2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ProfileButton(
            image: widget.image,
          ),
          const SizedBox(width: Spacing.spacing * 2),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SkeletonWidget(
                  isLoading: widget.isLoading,
                  height: 20,
                  child: Text(
                    widget.title,
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        color: ThemeColor.primary, fontWeight: FontWeight.w500),
                  ),
                ),
                const SizedBox(height: Spacing.spacing),
                SkeletonWidget(
                  isLoading: widget.isLoading,
                  height: 20,
                  child: Text(
                    widget.desc,
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          color: ThemeColor.neutral_500,
                        ),
                  ),
                ),
                const SizedBox(height: Spacing.spacing),
                SkeletonWidget(
                  isLoading: widget.isLoading,
                  height: 20,
                  child: Text(
                    widget.date,
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        color: ThemeColor.neutral_500,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
