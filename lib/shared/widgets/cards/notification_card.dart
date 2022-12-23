import 'package:flutter/material.dart';
import 'package:moodie/shared/themes/colors.dart';
import 'package:moodie/shared/themes/radius.dart';
import 'package:moodie/shared/themes/spacing.dart';
import 'package:get/get.dart';
import 'package:moodie/shared/widgets/buttons/profile_button.dart';
import 'package:moodie/shared/widgets/skeleton/skeleton_widget.dart';

class NotificationCard extends StatelessWidget {
  final int type;
  final String title, desc, time;
  final Function()? onClick;
  final bool isLoading, isRead;

  const NotificationCard({
    Key? key,
    required this.type,
    required this.title,
    required this.desc,
    required this.time,
    required this.isLoading,
    required this.isRead,
    this.onClick,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onClick ?? () {},
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SkeletonWidget(
            isLoading: isLoading,
            width: 10,
            height: 10,
            child: Container(
              margin: EdgeInsets.symmetric(vertical: Spacing.spacing * 2),
              width: Spacing.spacing * 1.5,
              height: Spacing.spacing * 1.5,
              decoration: BoxDecoration(
                color: isRead ? null : ThemeColor.primary,
                borderRadius: BorderRadius.all(
                  Radius.circular(CustomRadius.defaultRadius),
                ),
              ),
            ),
          ),
          const SizedBox(width: Spacing.spacing * 2),
          Expanded(
            child: AnimatedSize(
              alignment: Alignment.topLeft,
              curve: Curves.easeInOut,
              duration: const Duration(milliseconds: 200),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonWidget(
                    isLoading: isLoading,
                    height: 20,
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.titleSmall!.copyWith(
                            color: ThemeColor.neutral_900,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                  const SizedBox(height: Spacing.spacing),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Flexible(
                        child: SkeletonWidget(
                          isLoading: isLoading,
                          height: 30,
                          child: Text(
                            desc,
                            style:
                                Theme.of(context).textTheme.bodySmall!.copyWith(
                                      color: ThemeColor.neutral_500,
                                    ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: Spacing.spacing * 2),
          SkeletonWidget(
            isLoading: isLoading,
            child: Text(
              time,
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    color: ThemeColor.neutral_900,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
