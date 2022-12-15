import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:moodie/constants/asset_const.dart';
import 'package:moodie/shared/themes/colors.dart';

class AlertHelper {
  AlertHelper._();

  /// This need to be loong
  // ignore: long-parameter-list
  static Future<void> showMsg({
    required String title,
    required String msg,
    int? duration,
    bool countDown = true,
    bool onTop = false,
    bool isError = false,
    bool isWarning = false,
    Future<bool> Function()? onWillPop,
  }) async {
    _Alert alert = _Alert.isCheck;
    int _duration = duration ?? 5;

    if (isWarning) {
      alert = _Alert.isWarnig;
    }

    if (isError) {
      alert = _Alert.isError;
      _duration = 10;
    }

    if ((Get.isDialogOpen ?? false) && !onTop) return;

    await Get.dialog(
      _AlertDialog(
        msg: msg,
        title: title,
        status: alert,
        duration: _duration,
        countDown: countDown,
        onWillPop: onWillPop,
      ),
      barrierDismissible: onWillPop != null ? false : true,
      barrierColor: Colors.grey.withOpacity(0.3),
    );
  }
}

enum _Alert { isCheck, isWarnig, isError }

class _AlertDialog extends StatefulWidget {
  final String title, msg;
  final _Alert status;
  final int? duration;
  final bool countDown;
  final Future<bool> Function()? onWillPop;

  const _AlertDialog({
    Key? key,
    required this.title,
    required this.msg,
    required this.status,
    required this.duration,
    this.countDown = true,
    this.onWillPop,
  }) : super(key: key);

  @override
  State<_AlertDialog> createState() => _AlertDialogState();
}

class _AlertDialogState extends State<_AlertDialog> {
  int _count = 5;

  @override
  void initState() {
    _count = widget.duration ?? 5;

    super.initState();
    if (!widget.countDown) return;

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Timer.periodic(const Duration(seconds: 1), (timer) {
        _count--;
        if (!mounted) {
          timer.cancel();

          return;
        }

        if (_count >= 0) {
          setState(() {
            log("");
          });
        }

        if ((Get.isDialogOpen ?? false) && _count <= 0) {
          timer.cancel();
          widget.onWillPop?.call() ?? Get.close(1);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetAnimationDuration: const Duration(milliseconds: 200),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 18,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            SizedBox(height: 12),
            SizedBox(
              height: 60,
              child: Builder(builder: (context) {
                switch (widget.status) {
                  case _Alert.isCheck:
                    return OverflowBox(
                      minHeight: 220,
                      maxHeight: 220,
                      child: Lottie.asset(
                        AssetConst.animationCheck,
                        repeat: false,
                      ),
                    );
                  case _Alert.isWarnig:
                    return OverflowBox(
                      minHeight: 110,
                      maxHeight: 110,
                      child: Lottie.asset(
                        AssetConst.animationWarning,
                        repeat: false,
                      ),
                    );
                  case _Alert.isError:
                    return OverflowBox(
                      minHeight: 100,
                      maxHeight: 100,
                      child: Lottie.asset(
                        AssetConst.animationError,
                        repeat: false,
                      ),
                    );
                }
              }),
            ),
            SizedBox(height: 22),
            Text(
              widget.title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 4),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 8,
              ),
              child: Text(
                widget.msg,
                style: Theme.of(context).textTheme.subtitle2,
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 18),
            TextButton(
              onPressed: () async {
                widget.onWillPop?.call() ?? Get.close(1);
              },
              style: TextButton.styleFrom(
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                padding: EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                backgroundColor: ThemeColor.primary,
                // primary: Colorshite,
              ),
              child: Container(
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Opacity(
                      opacity: 0,
                      child: Text("$_count"),
                    ),
                    Text(
                      'Ok'.tr,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.subtitle2!.copyWith(
                            color: Colors.white,
                          ),
                    ),
                    Text(
                      "$_count",
                      style: Theme.of(context).textTheme.subtitle2!.copyWith(
                            color: Colors.white,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
