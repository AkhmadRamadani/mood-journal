import 'package:flutter/material.dart';
import 'package:moodie/shared/themes/colors.dart';
import 'package:moodie/shared/themes/spacing.dart';
import 'package:get/get.dart';
import 'package:moodie/shared/widgets/buttons/profile_button.dart';

class PageHeader extends StatelessWidget {
  final bool greet;
  final bool? isDark;
  final String type, image, name;
  final IconData? icon;
  final Function(int)? onSuffixPressed;
  final IconData? suffixIcon;

  const PageHeader(
      {Key? key,
      required this.image,
      required this.name,
      required this.greet,
      required this.type,
      this.isDark,
      this.icon,
      this.suffixIcon,
      this.onSuffixPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment:
          type == 'name' ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Greet
            Visibility(
              visible: greet,
              child: Text(
                "Hello,".tr,
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      color: isDark == true
                          ? ThemeColor.white
                          : ThemeColor.neutral_900,
                    ),
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Icon
                Visibility(
                  visible: icon == null ? false : true,
                  child: Column(
                    children: [
                      Icon(
                        icon ?? Icons.settings,
                        color: isDark == true
                            ? ThemeColor.white
                            : ThemeColor.neutral_900,
                      ),
                      const SizedBox(width: Spacing.spacing * 2),
                    ],
                  ),
                ),
                // Page Title
                Text(
                  name,
                  style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                        color: isDark == true
                            ? ThemeColor.white
                            : type == "name"
                                ? ThemeColor.primary
                                : ThemeColor.neutral_900,
                        fontWeight:
                            type == "name" ? FontWeight.bold : FontWeight.w600,
                      ),
                )
              ],
            ),
          ],
        ),
        if (suffixIcon != null) ...[
          InkWell(
            onTap: () => onSuffixPressed!(1),
            child: Icon(
              suffixIcon ?? Icons.settings,
              color: isDark == true ? ThemeColor.white : ThemeColor.neutral_900,
            ),
          ),
        ] else ...[
          ProfileButton(
            image: image,
          ),
        ]
      ],
    );
  }
}
