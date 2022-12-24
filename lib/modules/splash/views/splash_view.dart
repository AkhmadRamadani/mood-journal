import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:moodie/constants/asset_const.dart';
import 'package:moodie/shared/themes/colors.dart';

class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(statusBarColor: ThemeColor.appBar));
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
          backgroundColor: ThemeColor.appBar,
          body: Center(
            child: Image.asset(
              AssetConst.appIcon,
              height: 150,
              width: 150,
            ),
          )),
    );
  }
}
