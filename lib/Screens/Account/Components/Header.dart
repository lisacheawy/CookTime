import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../constants.dart';

class Header extends StatelessWidget {
  const Header({
    Key? key,
    required this.onPressed,
  }) : super(key: key);

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.symmetric(vertical: kDefaultPadding * 0.3),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'My Account',
              textScaleFactor: 1.0,
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall!
                  .copyWith(fontSize: 25),
            ),
            SizedBox(
              width: kDisplayWidth(context) * 0.23,
              child: TextButton(
                onPressed: onPressed,
                // child: Icon(CupertinoIcons.heart, color: kPrimaryColor),
                child: Text(
                  'Favourites',
                  textScaleFactor: 1.0,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium!
                      .apply(color: kPrimaryColor),
                ),
              ),
            )
          ],
        ));
  }
}
