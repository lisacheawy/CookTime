import 'package:flutter/material.dart';
import '../../../constants.dart';

class RowHeader extends StatelessWidget {
  const RowHeader(
      {Key? key,
      required this.title,
      required this.onPressed,
      required this.topMargin})
      : super(key: key);

  final String title;
  final double topMargin;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
          left: kDefaultPadding, right: kDefaultPadding, top: topMargin),
      child: Row(children: <Widget>[
        Container(
          padding: EdgeInsets.only(left: kDefaultPadding / 4),
          child: Text(title,
              textScaleFactor: 1.0,
              style: Theme.of(context).textTheme.titleMedium),
        ),
        Spacer(),
        TextButton(
            onPressed: onPressed,
            child: Text("View all",
                textScaleFactor: 1.0,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall!
                    .apply(color: kPrimaryColor)))
      ]),
    );
  }
}
