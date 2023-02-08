import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../constants.dart';

class RecipeCardPlaceHolder extends StatelessWidget {
  const RecipeCardPlaceHolder({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.only(
            bottom: kDisplayWidth(context) * 0.025,
            right: kDisplayWidth(context) * 0.02,
            left: kDisplayWidth(context) * 0.02),
        height: kDisplayWidth(context) * 0.05,
        padding: EdgeInsets.all(kDefaultPadding / 1.5),
        decoration: BoxDecoration(
            color: kWhite, borderRadius: BorderRadius.all(Radius.circular(15))),
        child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Shimmer.fromColors(
                baseColor: kBackgroundColor,
                highlightColor: kWhite,
                child: Container(
                  width: constraints.maxWidth,
                  height: constraints.maxHeight * 0.5,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: kBackgroundColor),
                ),
              ),
              Shimmer.fromColors(
                baseColor: kBackgroundColor,
                highlightColor: kWhite,
                child: Container(
                  width: constraints.maxWidth,
                  margin: EdgeInsets.only(top: kDefaultPadding * 0.5),
                  height: constraints.maxHeight * 0.08,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: kBackgroundColor),
                ),
              ),
              Shimmer.fromColors(
                baseColor: kBackgroundColor,
                highlightColor: kWhite,
                child: Container(
                  width: constraints.maxWidth * 0.5,
                  margin: EdgeInsets.only(top: kDefaultPadding * 0.4),
                  height: constraints.maxHeight * 0.08,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: kBackgroundColor),
                ),
              ),
              SizedBox(
                height: constraints.maxHeight * 0.15,
              ),
              SizedBox(
                height: constraints.maxHeight * 0.07,
                child: Row(
                  children: [
                    Shimmer.fromColors(
                      baseColor: kBackgroundColor,
                      highlightColor: kWhite,
                      child: Container(
                        width: constraints.maxWidth * 0.45,
                        margin: EdgeInsets.only(right: kDefaultPadding * 0.3),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: kBackgroundColor),
                      ),
                    ),
                    SizedBox(
                      width: constraints.maxWidth * 0.05,
                    ),
                    Shimmer.fromColors(
                      baseColor: kBackgroundColor,
                      highlightColor: kWhite,
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: kBackgroundColor),
                        width: constraints.maxWidth * 0.45,
                      ),
                    ),
                  ],
                ),
              )
            ],
          );
        }));
  }
}
