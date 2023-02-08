import 'package:cooktime/Components/Header.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/svg.dart';
import '../../Utils/CustomDialogUtils.dart';
import '../../Utils/FetchRecipeUtils.dart';
import '../RecipeResult/RecipeResultScreen.dart';
import 'package:flutter/material.dart';
import 'package:cooktime/constants.dart';
import 'Components/LabeledRadio.dart';

class IngredientsScreen extends StatefulWidget {
  const IngredientsScreen(
      {Key? key, required this.predictions, required this.storageUrls})
      : super(key: key);

  final List predictions;
  final List storageUrls;

  @override
  State<IngredientsScreen> createState() => _IngredientsScreenState();
}

class _IngredientsScreenState extends State<IngredientsScreen> {
  final _auth = FirebaseAuth.instance;
  final ScrollController sController = ScrollController();
  String editedIngredient = "";
  List<String> ingredientList = [];

  @override
  void initState() {
    super.initState();
    //if prediction exists, store highest predicted ingredient only
    //prediction list is already sorted in descending order of prediction score
    List<String> tempList = [];
    for (var i = 0; i < widget.predictions.length; i++) {
      //add empty string if prediction does not exist
      //this eases indexing when editing ingredient
      (widget.predictions[i].isNotEmpty)
          ? tempList.add(widget.predictions[i][0][0])
          : tempList.add("");
    }
    if (mounted) {
      setState(() {
        ingredientList = tempList;
      });
    }
  }

  void updateIngredientList(index) {
    if (editedIngredient != ingredientList[index]) {
      //avoid redundant update if its the same final ingredient
      if (mounted) {
        setState(() {
          ingredientList[index] = editedIngredient;
          //remove other ingredient so length = 1 and can display delete
        });
      }
    }
    if (mounted) {
      setState(() {
        widget.predictions[index]
            .removeWhere((idx) => idx[0] != ingredientList[index]);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Body(context),
        floatingActionButton: GestureDetector(
            onTap: () async {
              if (ingredientList.isEmpty) {
                showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (BuildContext context) => AlertDialog(
                          content: Container(
                            padding: EdgeInsets.all(kDefaultPadding * 0.3),
                            child: Text(
                              'Ingredient list is empty. Returning to images.',
                              textScaleFactor: 1.0,
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ),
                          actions: [
                            TextButton(
                                onPressed: () {
                                  var count = 0;
                                  Navigator.of(context)
                                      .popUntil((route) => count++ == 2);
                                },
                                child: Text('OK',
                                    textScaleFactor: 1.0,
                                    style: TextStyle(color: kPrimaryColor)))
                          ],
                        ));
              } else {
                showCustomDialog(context, "loading", "Searching for recipes");
                var recipes = await getRecipes(
                    _auth.currentUser!.uid, ingredientList, context, mounted);
                if (recipes.isNotEmpty && mounted) {
                  Navigator.of(context).pop(); //remove dialog box
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => RecipeResultScreen(
                          results: recipes,
                          header: "Recipe Results",
                          returnText: "Return to images",
                          backPressed: () async {
                            var count = 0;
                            (Navigator.of(context)
                                .popUntil((route) => count++ == 2));
                            return false;
                          },
                          onPressed: () {
                            var count = 0;
                            Navigator.of(context)
                                .popUntil((route) => count++ == 2);
                          }),
                      // RecipeResultScreen(),
                    ),
                  );
                }
              }
            },
            child: Container(
              padding: EdgeInsets.symmetric(
                  horizontal: kDisplayWidth(context) * 0.04),
              height: kDisplayHeight(context) * 0.07,
              width: kDisplayWidth(context) * 0.53,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(35),
                  color: kPrimaryColor,
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        offset: Offset(0, 3),
                        blurRadius: 6)
                  ]),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Search for Recipes',
                      textScaleFactor: 1.0,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium!
                          .copyWith(fontWeight: FontWeight.w500)),
                  Icon(
                    CupertinoIcons.right_chevron,
                    color: kTextColor,
                  )
                ],
              ),
            )));
  }

  SizedBox Body(BuildContext context) {
    return SizedBox(
      height: kDisplayHeight(context),
      child: Column(
        children: [
          Header(
              padding: EdgeInsets.only(
                  top: kToolbarHeight * 1.3, bottom: kToolbarHeight * 0.15),
              title: 'Ingredients',
              onPressed: () {
                Navigator.of(context).pop();
              },
              text: 'Back'),
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
                      controller: sController,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: kDisplayWidth(context) * 0.003,
                        mainAxisSpacing: kDisplayWidth(context) * 0.003,
                      ),
                      itemCount: widget.storageUrls.length +
                          3, //adding container at the bottom row to avoid items being covered by button
                      itemBuilder: (context, index) {
                        return (widget.storageUrls.asMap().containsKey(
                                index)) //only for those within the list
                            ? Stack(children: [
                                Padding(
                                  padding: EdgeInsets.only(right: 5, bottom: 5),
                                  child: ClipRRect(
                                      borderRadius: BorderRadius.circular(5),
                                      child: Container(
                                        decoration: BoxDecoration(
                                            color: kWhite,
                                            image: DecorationImage(
                                                fit: BoxFit.cover,
                                                colorFilter: ColorFilter.mode(
                                                    kTextColor.withOpacity(0.2),
                                                    BlendMode.dstATop),
                                                image: NetworkImage(widget
                                                    .storageUrls[index]))),
                                      )),
                                ),
                                Container(
                                    margin: EdgeInsets.symmetric(
                                        horizontal: kDefaultPadding * 0.3),
                                    child: Center(
                                      child: widget.predictions[index]
                                              .isEmpty //if no ingredient detected
                                          ? Container(
                                              margin: EdgeInsets.symmetric(
                                                  vertical:
                                                      kDefaultPadding * 0.2),
                                              child: Text(
                                                "No ingredient found",
                                                maxLines: 2,
                                                textScaleFactor: 1.0,
                                                overflow: TextOverflow.ellipsis,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleSmall!
                                                    .copyWith(height: 1),
                                              ),
                                            )
                                          : ListView.builder(
                                              //show all predictions
                                              shrinkWrap: true,
                                              physics:
                                                  NeverScrollableScrollPhysics(),
                                              itemCount: widget
                                                  .predictions[index].length,
                                              itemBuilder: (ctx, i) {
                                                return Container(
                                                  margin: EdgeInsets.symmetric(
                                                      vertical:
                                                          kDefaultPadding *
                                                              0.2),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        '${widget.predictions[index][i][0]}',
                                                        maxLines: 2,
                                                        textScaleFactor: 1.0,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .titleSmall!
                                                            .copyWith(
                                                              height: 1,
                                                            ),
                                                      ),
                                                      Container(
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                horizontal:
                                                                    kDefaultPadding *
                                                                        0.3),
                                                        decoration: BoxDecoration(
                                                            color: kWhite,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        20)),
                                                        child: Text(
                                                          '${(widget.predictions[index][i][1] * 100).round()}%',
                                                          textScaleFactor: 1.0,
                                                          style: Theme.of(
                                                                  context)
                                                              .textTheme
                                                              .titleSmall!
                                                              .apply(
                                                                  color: (widget
                                                                              .predictions[index]
                                                                              .length ==
                                                                          1)
                                                                      ? kPrimaryColor
                                                                      : kWarningColor),
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                );
                                              },
                                            ),
                                    )),
                                //DELETE or EDIT top right buttons
                                //For multiple predictions only
                                (widget.predictions[index].length > 1)
                                    ? Align(
                                        alignment: Alignment.topRight,
                                        child: GestureDetector(
                                          onTap: () {
                                            if (mounted) {
                                              setState(() {
                                                //refers to currently edited ingredient
                                                editedIngredient =
                                                    ingredientList[index];
                                              });
                                            }
                                            showDialog(
                                                context: context,
                                                barrierDismissible: false,
                                                builder:
                                                    (BuildContext context) {
                                                  return StatefulBuilder(
                                                      builder:
                                                          (context, setState) {
                                                    return AlertDialog(
                                                      shape: RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius.circular(
                                                                      15.0))),
                                                      contentPadding:
                                                          EdgeInsets.all(0),
                                                      title: Text(
                                                        "Select the correct ingredient",
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .titleMedium,
                                                        textAlign:
                                                            TextAlign.center,
                                                      ),
                                                      content: Container(
                                                        padding: EdgeInsets.symmetric(
                                                            horizontal:
                                                                kDefaultPadding,
                                                            vertical:
                                                                kDefaultPadding *
                                                                    0.5),
                                                        height: kDisplayWidth(
                                                                context) *
                                                            0.27,
                                                        width: kDisplayWidth(
                                                                context) *
                                                            0.7,
                                                        child: Column(
                                                          children: [
                                                            ListView.builder(
                                                              shrinkWrap: true,
                                                              itemCount: widget
                                                                  .predictions[
                                                                      index]
                                                                  .length,
                                                              itemBuilder:
                                                                  (context,
                                                                      idx) {
                                                                return LabeledRadio(
                                                                    label: widget
                                                                            .predictions[index]
                                                                        [
                                                                        idx][0],
                                                                    groupValue:
                                                                        editedIngredient,
                                                                    value: widget
                                                                            .predictions[index]
                                                                        [
                                                                        idx][0],
                                                                    onChanged:
                                                                        (value) {
                                                                      setState(
                                                                          () {
                                                                        editedIngredient =
                                                                            value;
                                                                      });
                                                                    });
                                                              },
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      actions: [
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            GestureDetector(
                                                                onTap: () {
                                                                  Navigator.of(
                                                                          context)
                                                                      .pop();
                                                                },
                                                                child:
                                                                    Container(
                                                                  margin: EdgeInsets.only(
                                                                      bottom:
                                                                          kDefaultPadding *
                                                                              0.3,
                                                                      right:
                                                                          kDefaultPadding *
                                                                              0.3,
                                                                      left: kDefaultPadding *
                                                                          0.3),
                                                                  width: kDisplayWidth(
                                                                          context) *
                                                                      0.17,
                                                                  height: kDisplayWidth(
                                                                          context) *
                                                                      0.08,
                                                                  padding:
                                                                      EdgeInsets
                                                                          .all(
                                                                    kDisplayWidth(
                                                                            context) *
                                                                        0.018,
                                                                  ),
                                                                  decoration: BoxDecoration(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              20),
                                                                      border: Border.all(
                                                                          width:
                                                                              2.0,
                                                                          color:
                                                                              kSecondaryColor)),
                                                                  child:
                                                                      SvgPicture
                                                                          .asset(
                                                                    'assets/icons/cross.svg',
                                                                    color:
                                                                        kSecondaryColor,
                                                                  ),
                                                                )),
                                                            GestureDetector(
                                                                onTap: () {
                                                                  updateIngredientList(
                                                                      index);
                                                                  Navigator.of(
                                                                          context)
                                                                      .pop();
                                                                },
                                                                child:
                                                                    Container(
                                                                  margin: EdgeInsets.only(
                                                                      bottom:
                                                                          kDefaultPadding *
                                                                              0.3,
                                                                      right:
                                                                          kDefaultPadding *
                                                                              0.3,
                                                                      left: kDefaultPadding *
                                                                          0.3),
                                                                  width: kDisplayWidth(
                                                                          context) *
                                                                      0.17,
                                                                  height: kDisplayWidth(
                                                                          context) *
                                                                      0.08,
                                                                  padding:
                                                                      EdgeInsets
                                                                          .all(
                                                                    kDisplayWidth(
                                                                            context) *
                                                                        0.022,
                                                                  ),
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            20),
                                                                    color:
                                                                        kPrimaryColor,
                                                                  ),
                                                                  child:
                                                                      SvgPicture
                                                                          .asset(
                                                                    'assets/icons/check.svg',
                                                                  ),
                                                                )),
                                                          ],
                                                        )
                                                      ],
                                                    );
                                                  });
                                                });
                                          },
                                          child: Container(
                                            margin: EdgeInsets.only(
                                                right: kDisplayWidth(context) *
                                                    0.02,
                                                top: kDisplayWidth(context) *
                                                    0.008),
                                            height:
                                                kDisplayWidth(context) * 0.07,
                                            width:
                                                kDisplayWidth(context) * 0.07,
                                            decoration: BoxDecoration(
                                                color: kWhite,
                                                borderRadius:
                                                    BorderRadius.circular(20)),
                                            child: Icon(Icons.create_rounded,
                                                color: kWarningColor,
                                                size: kDisplayWidth(context) *
                                                    0.05),
                                          ),
                                        ),
                                      )
                                    : Align(
                                        alignment: Alignment.topRight,
                                        child: GestureDetector(
                                          onTap: () async {
                                            if (mounted) {
                                              setState(() {
                                                ingredientList.removeAt(index);
                                                widget.storageUrls
                                                    .removeAt(index);
                                                widget.predictions
                                                    .removeAt(index);
                                              });
                                            }
                                            if (widget.storageUrls.isEmpty) {
                                              showDialog(
                                                  context: context,
                                                  barrierDismissible: false,
                                                  builder: (BuildContext
                                                          context) =>
                                                      AlertDialog(
                                                        content: Container(
                                                          padding: EdgeInsets.all(
                                                              kDefaultPadding *
                                                                  0.3),
                                                          child: Text(
                                                            'No ingredients left. Returning to previous screen.',
                                                            style: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .bodyLarge,
                                                          ),
                                                        ),
                                                        actions: [
                                                          TextButton(
                                                              onPressed: () {
                                                                var count = 0;
                                                                Navigator.of(
                                                                        context)
                                                                    .popUntil(
                                                                        (route) =>
                                                                            count++ ==
                                                                            2);
                                                              },
                                                              child: Text('OK',
                                                                  style: TextStyle(
                                                                      color:
                                                                          kPrimaryColor)))
                                                        ],
                                                      ));
                                            }
                                          },
                                          child: Container(
                                            margin: EdgeInsets.only(
                                                right: kDisplayWidth(context) *
                                                    0.02,
                                                top: kDisplayWidth(context) *
                                                    0.008),
                                            height:
                                                kDisplayWidth(context) * 0.07,
                                            width:
                                                kDisplayWidth(context) * 0.07,
                                            decoration: BoxDecoration(
                                                color: kWhite,
                                                borderRadius:
                                                    BorderRadius.circular(20)),
                                            child: SvgPicture.asset(
                                                'assets/icons/garbage-can.svg',
                                                fit: BoxFit.scaleDown),
                                          ),
                                        ),
                                      )
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
