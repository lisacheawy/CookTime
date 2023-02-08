import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../../../constants.dart';

class Info extends StatefulWidget {
  const Info(
      {Key? key,
      required this.recipe,
      required this.dietList,
      required this.recTime,
      this.desc})
      : super(key: key);

  final Map<String, dynamic> recipe;
  final List dietList;
  final String recTime;
  final String? desc;

  @override
  State<Info> createState() => _InfoState();
}

class _InfoState extends State<Info> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: kDisplayWidth(context),
      padding: EdgeInsets.only(
          top: kDefaultPadding * 0.8,
          right: kDefaultPadding * 0.8,
          left: kDefaultPadding * 0.8),
      child: Column(
        children: [
          Text(
            widget.recipe["recipeName"],
            textAlign: TextAlign.center,
            textScaleFactor: 1.0,
            style:
                Theme.of(context).textTheme.titleMedium!.copyWith(height: 1.2),
          ),
          if (widget.dietList.isNotEmpty) //there are recipes without dietlist
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child:
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                ...widget.dietList.map((d) => Text(
                    d == widget.dietList.first ? '$d ' : '\u2022 $d ',
                    textScaleFactor: 1.0,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall!
                        .apply(color: kSecondaryColor)))
              ]),
            ),
          Container(
            //time and difficulty
            margin: EdgeInsets.symmetric(vertical: 2),
            width: kDisplayWidth(context),
            child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  SizedBox(
                    width: constraints.maxWidth * 0.475,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          margin: EdgeInsets.symmetric(
                              horizontal: kDefaultPadding * 0.3),
                          child: SvgPicture.asset(
                            'assets/icons/clock.svg',
                            height: kDisplayHeight_WoTool(context) * 0.018,
                          ),
                        ),
                        Text(widget.recTime,
                            textScaleFactor: 1.0,
                            style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: constraints.maxWidth * 0.05,
                  ),
                  SizedBox(
                      width: constraints.maxWidth * 0.475,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            margin: EdgeInsets.symmetric(
                                horizontal: kDefaultPadding * 0.3),
                            child: SvgPicture.asset(
                              'assets/icons/difficulty-${widget.recipe["difficulty"].toLowerCase()}.svg',
                              height: kDisplayHeight_WoTool(context) * 0.018,
                            ),
                          ),
                          Text(widget.recipe["difficulty"],
                              textScaleFactor: 1.0,
                              style: Theme.of(context).textTheme.bodySmall),
                        ],
                      ))
                ],
              );
            }),
          ),
          //description
          if (widget.desc!.isNotEmpty)
            Container(
              margin: EdgeInsets.symmetric(vertical: 2),
              child: Text(widget.desc!,
                  textAlign: TextAlign.center,
                  textScaleFactor: 1.0,
                  style: Theme.of(context).textTheme.bodySmall),
            )
        ],
      ),
    );
  }
}
