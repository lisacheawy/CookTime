import 'package:flutter/material.dart';
import '../constants.dart';

class Header extends StatelessWidget {
  const Header({
    Key? key,
    required this.padding,
    this.onPressed,
    required this.title,
    this.text,
  }) : super(key: key);

  final String title;
  final String? text;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
        width: kDisplayWidth(context),
        padding: padding,
        margin: EdgeInsets.symmetric(horizontal: kDisplayWidth(context) * 0.07),
        child: Row(children: [
          Text(title,
              textScaleFactor: 1.0,
              style: Theme.of(context).textTheme.headlineSmall),
          Spacer(),
          if (onPressed != null)
            TextButton(
                onPressed: onPressed,
                child: Text(text!,
                    textScaleFactor: 1.0,
                    style: Theme.of(context).textTheme.titleSmall!.copyWith(
                        color: kWarningColor, fontWeight: FontWeight.w400)))
        ]));
  }
}
