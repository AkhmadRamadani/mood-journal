import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomTextButton extends StatelessWidget {
  const CustomTextButton({
    Key? key,
    this.title,
    this.svgLocation,
    this.onPressed,
    this.backgroundColor,
    this.textColor,
  }) : super(key: key);

  final String? title;
  final String? svgLocation;
  final Function()? onPressed;
  final Color? backgroundColor, textColor;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        width: double.infinity,
        height: 50,
        padding: const EdgeInsets.symmetric(
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
              offset: const Offset(0, 5),
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
                  const SizedBox(
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
              const SizedBox(
                width: 50,
              )
          ],
        ),
      ),
    );
  }
}
