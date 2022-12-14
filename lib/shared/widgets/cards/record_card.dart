import 'package:flutter/material.dart';
import 'package:moodie/shared/icons/custom_icon.dart';
import 'package:moodie/shared/themes/colors.dart';
import 'package:moodie/shared/themes/radius.dart';
import 'package:moodie/shared/themes/spacing.dart';

class RecordCard extends StatefulWidget {
  final int type;
  const RecordCard({Key? key, required this.type}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _RecordCardState();
}

class _RecordCardState extends State<RecordCard> {
  bool _isExpanded = false;

  setColor(type) {
    if (type == 0) {
      return ThemeColor.neutral_900;
    } else if (type == 1) {
      return ThemeColor.secondary_400;
    } else {
      return ThemeColor.warning_400;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        setState(() {
          _isExpanded = !_isExpanded;
        });
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Column(
          //   crossAxisAlignment: CrossAxisAlignment.end,
          //   children: <Widget>[

          //   ],
          // ),
          Text(
            '11:45 PM',
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  color: setColor(widget.type),
                  fontWeight: FontWeight.w500,
                ),
          ),
          const SizedBox(width: Spacing.spacing * 2),
          Container(
            width: Spacing.spacing * 6,
            height: Spacing.spacing * 6,
            decoration: const BoxDecoration(
              color: ThemeColor.primary,
              borderRadius: BorderRadius.all(
                Radius.circular(CustomRadius.defaultRadius),
              ),
            ),
            child: Center(
              child: Text(
                '1',
                style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                      color: ThemeColor.white,
                      fontWeight: FontWeight.bold,
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
                  Text(
                    'Happy',
                    style: Theme.of(context).textTheme.titleSmall!.copyWith(
                          color: setColor(widget.type),
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: Spacing.spacing),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Flexible(
                        child: Text(
                          'I\'m happy because today someone finally said hello to me',
                          style:
                              Theme.of(context).textTheme.bodySmall!.copyWith(
                                    color: ThemeColor.neutral_500,
                                  ),
                        ),
                      )
                    ],
                  ),
                  if (_isExpanded) ...[
                    const SizedBox(height: Spacing.spacing),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(CustomIcons.clock,
                            size: Spacing.spacing * 2),
                        const SizedBox(
                          width: Spacing.spacing,
                        ),
                        Flexible(
                          child: Text(
                            'It\'s been a while since last time someone said hello to me',
                            style:
                                Theme.of(context).textTheme.bodySmall!.copyWith(
                                      color: ThemeColor.neutral_500,
                                    ),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: Spacing.spacing),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(CustomIcons.flag, size: Spacing.spacing * 2),
                        const SizedBox(
                          width: Spacing.spacing,
                        ),
                        Flexible(
                          child: Text(
                            'I\'m really happy because I\'m not alone anymore',
                            style:
                                Theme.of(context).textTheme.bodySmall!.copyWith(
                                      color: ThemeColor.neutral_500,
                                    ),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: Spacing.spacing),
                    SizedBox(
                      width: double.infinity,
                      child: Text(
                        'Hide Details',
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                              color: ThemeColor.secondary_400,
                            ),
                        textAlign: TextAlign.end,
                      ),
                    )
                  ]
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
