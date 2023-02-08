import 'package:cooktime/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class Header extends StatelessWidget {
  const Header({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: kDisplayHeight(context) * 0.18, //8% of screen height
      width: kDisplayWidth(context),
      margin: EdgeInsets.only(bottom: kDefaultPadding * 0.5),
      padding: EdgeInsets.only(bottom: kDefaultPadding * 0.2),
      decoration: BoxDecoration(
        color: kPrimaryColor,
        borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(25), bottomRight: Radius.circular(25)),
      ),
      child: Stack(children: [
        SizedBox(
          width: kDisplayWidth(context),
          height: kDisplayHeight(context) * 0.18,
          child: SvgPicture.asset('assets/images/home-asset.svg',
              color: Color(0xFFFFD373),
              fit: BoxFit.contain,
              alignment: Alignment.center),
        ),
        Positioned(
            bottom: kDefaultPadding * 0.8,
            left: kDisplayWidth(context) * 0.07,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('Welcome back!',
                  textScaleFactor: 1.0,
                  style: Theme.of(context).textTheme.headlineSmall),
            ))
      ]),
    );
  }
}
