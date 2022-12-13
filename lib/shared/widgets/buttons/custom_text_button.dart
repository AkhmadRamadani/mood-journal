import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:moodie/constants/asset_const.dart';

class CustomTextButton extends StatelessWidget {
  CustomTextButton({
    Key? key,
    this.title,
    this.svgLocation,
    this.onPressed,
    this.backgroundColor,
    this.textColor,
  }) : super(key: key);

  String? title;
  String? svgLocation;
  Function()? onPressed;
  Color? backgroundColor, textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 50,
      padding: EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
        borderRadius: BorderRadius.circular(50),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          if (svgLocation != null)
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: backgroundColor ?? Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: SvgPicture.asset(
                      svgLocation!,
                      width: 24,
                      height: 24,
                    ),
                  ),
                ),
                SizedBox(
                  width: 16,
                ),
              ],
            ),
          Expanded(
            child: Center(
              child: Text(
                title ?? "",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: textColor ?? Colors.black,
                ),
              ),
            ),
          ),
          if (svgLocation != null)
            SizedBox(
              width: 50,
            )
        ],
      ),
    );
  }
}
