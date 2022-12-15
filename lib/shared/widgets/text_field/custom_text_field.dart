import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class CustomTextField extends StatefulWidget {
  const CustomTextField({
    Key? key,
    this.hintText,
    this.labelText,
    this.svgLocation,
    this.keyboardType,
    this.isUsingIcon,
    this.icon,
    this.iconColor,
    this.controller,
  }) : super(key: key);

  final String? hintText, labelText;
  final String? svgLocation;
  final TextInputType? keyboardType;
  final bool? isUsingIcon;
  final IconData? icon;
  final Color? iconColor;
  final TextEditingController? controller;

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool showPassword = false;

  void changeVisibility() {
    setState(() {
      showPassword = !showPassword;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      width: MediaQuery.of(context).size.width - 50,
      height: MediaQuery.of(context).size.width / 7,
      decoration: BoxDecoration(
          color: const Color.fromRGBO(243, 243, 247, 1),
          borderRadius: BorderRadius.circular(15)),
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 5,
            child: TextField(
              controller: widget.controller,
              obscureText: widget.keyboardType == TextInputType.visiblePassword
                  ? !showPassword
                  : false,
              keyboardType: widget.keyboardType ?? TextInputType.text,
              style: const TextStyle(
                fontWeight: FontWeight.w300,
              ),
              decoration: InputDecoration.collapsed(
                hintText: widget.hintText,
              ),
            ),
          ),
          if (widget.keyboardType == TextInputType.visiblePassword)
            Expanded(
              flex: 1,
              child: InkWell(
                onTap: changeVisibility,
                child: Icon(
                  showPassword ? Icons.visibility : Icons.visibility_off,
                  color: widget.iconColor ?? Colors.grey,
                  size: 24,
                ),
              ),
            )
          else if (widget.isUsingIcon ?? false)
            Expanded(
              flex: 1,
              child: Icon(
                widget.icon,
                color: widget.iconColor ?? Colors.grey,
                size: 24,
              ),
            )
          else if (widget.svgLocation != null)
            Expanded(
              flex: 1,
              child: SizedBox(
                width: 24,
                height: 24,
                child: SvgPicture.asset(
                  widget.svgLocation!,
                  color: widget.iconColor ?? Colors.grey,
                  width: 24,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
