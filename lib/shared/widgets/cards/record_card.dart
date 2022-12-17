import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:moodie/constants/asset_const.dart';
import 'package:moodie/shared/enum/mood_enum.dart';
import 'package:moodie/shared/icons/custom_icon.dart';
import 'package:moodie/shared/themes/colors.dart';
import 'package:moodie/shared/themes/radius.dart';
import 'package:moodie/shared/themes/spacing.dart';
import 'package:moodie/shared/widgets/skeleton/skeleton_widget.dart';

class RecordCard extends StatefulWidget {
  final int type;
  final bool isLoading;
  final String? title, desc, time, date, emotions;
  final MoodConditions? mood;
  const RecordCard({
    Key? key,
    required this.type,
    required this.isLoading,
    this.title,
    this.desc,
    this.time,
    this.date,
    this.mood,
    this.emotions,
  }) : super(key: key);

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
    return GestureDetector(
      onTap: () {
        setState(() {
          _isExpanded = !_isExpanded;
        });
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonWidget(
            height: 12,
            width: 20,
            isLoading: widget.isLoading,
            child: Text(
              widget.time ?? '',
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    color: setColor(widget.type),
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
          const SizedBox(width: Spacing.spacing * 2),
          SkeletonWidget(
            isLoading: widget.isLoading,
            height: Spacing.spacing * 6,
            width: Spacing.spacing * 6,
            child: Container(
              width: Spacing.spacing * 6,
              height: Spacing.spacing * 6,
              decoration: const BoxDecoration(
                color: ThemeColor.primary,
                borderRadius: BorderRadius.all(
                  Radius.circular(CustomRadius.defaultRadius),
                ),
              ),
              child: Center(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.mood == MoodConditions.tired) ...[
                    Lottie.asset(
                      AssetConst.cryingAnimation,
                      width: 40,
                      height: 40,
                    ),
                  ] else if (widget.mood == MoodConditions.happy) ...[
                    Lottie.asset(
                      AssetConst.smileyAnimation,
                      width: 40,
                      height: 40,
                    ),
                  ] else if (widget.mood == MoodConditions.sad) ...[
                    Lottie.asset(
                      AssetConst.sadAnimation,
                      width: 40,
                      height: 40,
                    ),
                  ] else if (widget.mood == MoodConditions.excited) ...[
                    Lottie.asset(
                      AssetConst.winkingAnimation,
                      width: 40,
                      height: 40,
                    ),
                  ] else if (widget.mood == MoodConditions.cheerful) ...[
                    Lottie.asset(
                      AssetConst.blushingAnimation,
                      width: 40,
                      height: 40,
                    ),
                  ]
                ],
              )),
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
                    isLoading: widget.isLoading,
                    height: 100,
                    child: Text(
                      "${widget.title ?? ''} - ${widget.emotions ?? ''}",
                      maxLines: _isExpanded ? null : 2,
                      overflow: _isExpanded ? null : TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall!.copyWith(
                            color: setColor(widget.type),
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                  const SizedBox(height: Spacing.spacing),
                  SkeletonWidget(
                    isLoading: widget.isLoading,
                    height: 25,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Flexible(
                          child: Text(
                            widget.desc ?? '',
                            maxLines: _isExpanded ? null : 2,
                            overflow:
                                _isExpanded ? null : TextOverflow.ellipsis,
                            style:
                                Theme.of(context).textTheme.bodySmall!.copyWith(
                                      color: ThemeColor.neutral_500,
                                    ),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
