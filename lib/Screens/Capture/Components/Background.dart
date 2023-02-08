import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'dart:math' as math;
import '../../../constants.dart';

class background extends StatelessWidget {
  const background({
    Key? key,
    required this.withPan,
  }) : super(key: key);

  final bool withPan;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Align(
            alignment: Alignment.topRight,
            child: SvgPicture.asset('assets/images/white-blob.svg',
                width: kDisplayWidth(context) * 0.7)),
        Align(
            alignment: Alignment.bottomLeft,
            child: SvgPicture.asset(
              'assets/images/peach-blob.svg',
              width: kDisplayWidth(context),
            )),
        Align(
            alignment: Alignment.bottomRight,
            child: withPan
                ? Container(
                    margin: EdgeInsets.only(bottom: kDefaultPadding * 0.3),
                    width: kDisplayWidth(context) * 0.28,
                    height: kDisplayHeight_WoT_Nav(context) * 0.3,
                    child: Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.rotationY(math.pi),
                      child: SvgPicture.asset(
                        'assets/images/FryingPan-Half.svg',
                        fit: BoxFit.fitWidth,
                      ),
                    ),
                  )
                : null)
      ],
    );
  }
}
