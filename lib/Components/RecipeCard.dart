import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../constants.dart';

class RecipeCard extends StatelessWidget {
  const RecipeCard({
    Key? key,
    required this.recipe,
    required this.onTap,
  }) : super(key: key);

  final Map<String, dynamic> recipe;
  final VoidCallback? onTap;

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
            return GestureDetector(
                onTap: onTap,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: constraints.maxWidth,
                      height: constraints.maxHeight * 0.5,
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: FadeInImage.assetNetwork(
                              placeholder: 'assets/images/placeholder.png',
                              image: recipe["img"],
                              fit: BoxFit.fitWidth)),
                    ),
                    Flexible(
                      child: Container(
                          padding: EdgeInsets.symmetric(
                              vertical: kDefaultPadding / 3),
                          height: constraints.maxHeight * 0.4,
                          child: Text(
                            recipe["recipeName"],
                            style: Theme.of(context).textTheme.titleSmall,
                            maxLines: 2,
                            textScaleFactor: 1.0,
                            overflow: TextOverflow.ellipsis,
                          )),
                    ),
                    SizedBox(
                      height: constraints.maxHeight * 0.1,
                      child: Row(
                        children: [
                          SizedBox(
                            width: constraints.maxWidth * 0.45,
                            child: Row(
                              children: [
                                Container(
                                  margin: EdgeInsets.only(
                                      right: kDefaultPadding * 0.3),
                                  child: SvgPicture.asset(
                                    'assets/icons/clock.svg',
                                    height:
                                        kDisplayHeight_WoTool(context) * 0.018,
                                  ),
                                ),
                                Text(recipe["time"],
                                    textScaleFactor: 1.0,
                                    style:
                                        Theme.of(context).textTheme.bodySmall),
                              ],
                            ),
                          ),
                          SizedBox(
                            width: constraints.maxWidth * 0.05,
                          ),
                          SizedBox(
                            width: constraints.maxWidth * 0.5,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                SvgPicture.asset(
                                  "assets/icons/difficulty-${recipe["difficulty"].toLowerCase()}.svg",
                                  height:
                                      kDisplayHeight_WoTool(context) * 0.018,
                                ),
                                Text(recipe["difficulty"],
                                    textScaleFactor: 1.0,
                                    style:
                                        Theme.of(context).textTheme.bodySmall),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ));
          },
        ));
  }
}
