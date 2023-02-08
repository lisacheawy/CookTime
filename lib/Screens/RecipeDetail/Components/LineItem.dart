import 'package:flutter/material.dart';
import '../../../constants.dart';

class LineItem extends StatelessWidget {
  const LineItem({
    Key? key,
    this.leading,
    required this.constraints,
    required this.item,
  }) : super(key: key);

  final String? leading;
  final String item;
  final BoxConstraints constraints;

  @override
  Widget build(BuildContext context) {
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: (leading == null)
            ? [
                //for ingredient subheadings
                SizedBox(
                  width: constraints.maxWidth,
                  child: Text(
                    item,
                    textScaleFactor: 1.0,
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge!
                        .apply(color: kPrimaryColor),
                  ),
                )
              ]
            : [
                SizedBox(
                  width: constraints.maxWidth * 0.08,
                  child: Text(
                    leading!,
                    textScaleFactor: 1.0,
                  ),
                ),
                SizedBox(
                  width: constraints.maxWidth * 0.92,
                  child: Text(
                    item,
                    textScaleFactor: 1.0,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                )
              ]);
  }
}
