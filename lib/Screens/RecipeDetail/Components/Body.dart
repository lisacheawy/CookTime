import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cooktime/Screens/RecipeDetail/Components/Info.dart';
import 'package:cooktime/Screens/RecipeDetail/Components/LaunchBrowserButton.dart';
import 'package:cooktime/constants.dart';
import 'package:flutter/material.dart';
import './LineItem.dart';

class Body extends StatefulWidget {
  const Body({Key? key, required this.recipe}) : super(key: key);
  final Map<String, dynamic> recipe;
  @override
  State<Body> createState() => _BodyState();
}

class _BodyState extends State<Body> with SingleTickerProviderStateMixin {
  late TabController _controller;
  String? desc = "";
  String recipeLink = "";
  String recTime = "";
  List dietList = [];
  List ingredients = [];
  List instructions = [];
  bool isLoading = true;

  static List<Tab> recipeTabs = <Tab>[
    Tab(text: 'Ingredients'),
    Tab(text: 'Method')
  ];

  @override
  void initState() {
    super.initState();
    _controller = TabController(length: recipeTabs.length, vsync: this);
    getRecipeDetail();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> getRecipeDetail() async {
    if (mounted) {
      setState(() {
        isLoading = true;
      });
    }
    final recipeDoc = FirebaseFirestore.instance
        .collection('Recipes')
        .doc(widget.recipe["id"]);
    recipeDoc.get().then((DocumentSnapshot doc) {
      final data = doc.data() as Map<String, dynamic>;
      if (mounted) {
        var diets = [];
        data["dietList"].forEach((key, value) {
          if (value) {
            diets.add(key);
          }
        });
        setState(() {
          desc = data['desc'];
          recipeLink = data["link"];
          dietList = diets;
          ingredients = data['ingredients'];
          instructions = data['method'];
          recTime = data['time'];
          isLoading = false;
        });
      }
    }, onError: (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Unable to delete retrieve doc $e',
              textScaleFactor: 1.0,
            ),
            backgroundColor: kWarningColor,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return NestedScrollView(
      headerSliverBuilder: (context, value) {
        return [
          SliverToBoxAdapter(
            child: Column(
              children: [
                SizedBox(
                    //image
                    width: kDisplayWidth(context),
                    height: kDisplayHeight_WoTool(context) * 0.3,
                    child: ClipRRect(
                        child: Image.network(widget.recipe["img"],
                            fit: BoxFit.fitWidth))),
                //recipe details before tab bar
                Info(
                    recipe: widget.recipe,
                    dietList: dietList,
                    recTime: recTime,
                    desc: desc),
                if (isLoading)
                  Container(
                      height: kDisplayHeight(context),
                      color: kWhite.withOpacity(0.9),
                      child: Align(
                        alignment: Alignment.center,
                        child: CircularProgressIndicator(
                          color: kSecondaryColor,
                        ),
                      )),
              ],
            ),
          ),
          SliverToBoxAdapter(
            child: TabBar(
              controller: _controller,
              isScrollable: false,
              padding: EdgeInsets.symmetric(
                  horizontal: kDisplayWidth(context) * 0.2),
              indicatorPadding: EdgeInsets.symmetric(vertical: 7),
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: kPrimaryColor,
              ),
              labelColor: kTextColor,
              unselectedLabelColor: kSecondaryColor,
              tabs: recipeTabs,
            ),
          )
        ];
      },
      body: TabBarView(
          controller: _controller,
          children: recipeTabs.map((Tab tab) {
            final label = tab.text!.toLowerCase();
            return Container(
              margin: EdgeInsets.only(
                left: kDisplayWidth(context) * 0.08,
                right: kDisplayWidth(context) * 0.08,
                top: kDisplayWidth(context) * 0.02,
              ),
              width: kDisplayWidth(context),
              child: ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  scrollDirection: Axis.vertical,
                  itemCount: (label == "method")
                      ? instructions.length
                      : ingredients.length,
                  itemBuilder: (context, index) {
                    return LayoutBuilder(builder:
                        (BuildContext ctx, BoxConstraints constraints) {
                      return Container(
                          margin: EdgeInsets.only(
                              bottom: kDisplayWidth(context) * 0.03),
                          child: (label == "ingredients" &&
                                  index ==
                                      ingredients.length -
                                          1) //insert button below item if last index of ingredient
                              ? Column(
                                  children: [
                                    LineItem(
                                        leading: "\u2022",
                                        item: ingredients[index],
                                        constraints: constraints),
                                    LaunchBrowserButton(
                                      recipeLink: recipeLink,
                                    )
                                  ],
                                )
                              : (label == "ingredients" &&
                                      ingredients[index].contains("_header"))
                                  ? LineItem(
                                      //for subheadings. remove _header tag and display
                                      item: ingredients[index].substring(
                                          0,
                                          ingredients[index]
                                              .indexOf("_header")),
                                      constraints: constraints)
                                  : LineItem(
                                      leading: (label == "ingredients")
                                          ? "\u2022"
                                          : '${index + 1}.',
                                      item: (label == "ingredients")
                                          ? ingredients[index]
                                          : instructions[index],
                                      constraints: constraints));
                    });
                  }),
            );
          }).toList()),
    );
  }
}
