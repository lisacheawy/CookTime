import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lottie/lottie.dart';
import '../constants.dart';

Future<void> showCustomDialog(context, arg, msg) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: (arg != "loading"),
    builder: (BuildContext ctx) {
      return WillPopScope(
        //do not exit dialog box on back button press
        onWillPop: () async => (arg != "loading"),
        child: Container(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(10.0)),
          margin: EdgeInsets.symmetric(
            horizontal: kDisplayWidth(context) * 0.2,
            vertical: kDisplayWidth(context) * 0.67,
          ),
          child: Dialog(
            child: LayoutBuilder(
                builder: (BuildContext ctx, BoxConstraints constraints) {
              return Container(
                padding: EdgeInsets.all(kDefaultPadding * 0.5),
                child: Column(
                  children: [
                    SizedBox(
                      height: constraints.maxHeight * 0.6,
                      child: (arg == "loading")
                          ? Lottie.asset('assets/lottie/processing.json',
                              height: kDisplayWidth(context) * 0.15,
                              repeat: true)
                          : SvgPicture.asset(
                              'assets/icons/error.svg',
                              height: kDisplayWidth(context) * 0.15,
                            ),
                    ),
                    SizedBox(
                      height: constraints.maxHeight * 0.25,
                      width: constraints.maxWidth * 0.8,
                      child: Text(
                        msg,
                        textScaleFactor: 1.0,
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
      );
    },
  );
}
