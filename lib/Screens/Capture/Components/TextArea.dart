import 'package:flutter/material.dart';

import '../../../constants.dart';

class TextArea extends StatelessWidget {
  const TextArea(
      {Key? key,
      required this.headline,
      required this.desc,
      required this.warning})
      : super(key: key);

  final String headline;
  final String desc;
  final String warning;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: kDisplayWidth(context) * 0.7,
      margin: EdgeInsets.only(
          top: kDisplayHeight_WoTool(context) * 0.15,
          left: kDisplayWidth(context) * 0.07),
      child: Column(
        children: [
          Container(
            alignment: Alignment.centerLeft,
            margin: EdgeInsets.symmetric(vertical: kDefaultPadding * 0.08),
            child: Text(headline,
                textScaleFactor: 1.0,
                style: Theme.of(context).textTheme.headlineMedium),
          ),
          Container(
              alignment: Alignment.centerLeft,
              margin: EdgeInsets.symmetric(vertical: kDefaultPadding * 0.5),
              child: Text(
                desc,
                textScaleFactor: 1.0,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium!
                    .copyWith(fontWeight: FontWeight.w500, height: 1.3),
              )),
          Container(
            alignment: Alignment.centerLeft,
            margin: EdgeInsets.symmetric(vertical: kDefaultPadding * 0.5),
            child: Text(
              warning,
              textScaleFactor: 1.0,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium!
                  .apply(color: kWarningColor),
            ),
          )
        ],
      ),
    );
  }
}
