import 'dart:io';
import 'package:cooktime/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../../../Components/Header.dart';

class Body extends StatefulWidget {
  const Body({Key? key, required this.imgCollection, required this.headerTitle})
      : super(key: key);

  final List imgCollection;
  final String headerTitle;

  @override
  State<Body> createState() => _BodyState();
}

class _BodyState extends State<Body> {
  final ScrollController sController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: kDisplayHeight(context),
      child: Column(
        children: [
          Header(
            title: widget.headerTitle,
            padding: EdgeInsets.only(
                top: kToolbarHeight * 1.3, bottom: kToolbarHeight * 0.15),
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            text: 'Cancel',
          ),
          Expanded(
            child: MediaQuery.removePadding(
              context: context,
              removeTop: true,
              child: CupertinoScrollbar(
                thickness: 5,
                thumbVisibility: true,
                controller: sController,
                child: Container(
                  height: kDisplayHeight_WoTool(context),
                  margin: EdgeInsets.symmetric(
                      horizontal: kDisplayWidth(context) * 0.07),
                  child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: kDisplayWidth(context) * 0.003,
                        mainAxisSpacing: kDisplayWidth(context) * 0.003,
                      ),
                      controller: sController,
                      itemCount: widget.imgCollection.length +
                          3, //adding container at the bottom row to avoid items being covered
                      itemBuilder: (context, index) {
                        return (widget.imgCollection.asMap().containsKey(
                                index)) //only for those within the list
                            ? Stack(children: [
                                Padding(
                                  padding: EdgeInsets.only(right: 5, bottom: 5),
                                  child: ClipRRect(
                                      borderRadius: BorderRadius.circular(5),
                                      child: Image.file(
                                          File(widget.imgCollection[index]))),
                                ),
                                Align(
                                  alignment: Alignment.topRight,
                                  child: GestureDetector(
                                    onTap: () async {
                                      if (mounted) {
                                        setState(() {
                                          widget.imgCollection.removeAt(index);
                                        });
                                      }
                                    },
                                    child: Container(
                                      margin: EdgeInsets.only(
                                          right: kDisplayWidth(context) * 0.02,
                                          top: kDisplayWidth(context) * 0.008),
                                      height: kDisplayWidth(context) * 0.07,
                                      width: kDisplayWidth(context) * 0.07,
                                      decoration: BoxDecoration(
                                          color: kWhite,
                                          borderRadius:
                                              BorderRadius.circular(20)),
                                      child: SvgPicture.asset(
                                          'assets/icons/garbage-can.svg',
                                          fit: BoxFit.scaleDown),
                                    ),
                                  ),
                                ),
                              ])
                            : Container();
                      }),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
