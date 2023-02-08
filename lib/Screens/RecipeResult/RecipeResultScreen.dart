import 'package:cooktime/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../Utils/UserIngredientUtils.dart';
import '../../Components/RecipeCard.dart';
import '../RecipeDetail/RecipeDetailScreen.dart';

class RecipeResultScreen extends StatefulWidget {
  const RecipeResultScreen({
    Key? key,
    required this.results,
    required this.header,
    required this.onPressed,
    this.returnText,
    this.endText,
    required this.backPressed,
  }) : super(key: key);

  final List results;
  final String header;
  final VoidCallback onPressed;
  final Future<bool> Function() backPressed;
  final String? endText;
  final String? returnText;

  @override
  State<RecipeResultScreen> createState() => _RecipeResultScreenState();
}

class _RecipeResultScreenState extends State<RecipeResultScreen>
    with SingleTickerProviderStateMixin {
  List<Tab> cTabs = <Tab>[];
  List allRecipes = [];

  @override
  void initState() {
    super.initState();
    deleteDoc(context, mounted);
    List<Tab> tabs = <Tab>[];
    List total = [];

    widget.results[0].forEach((String key, final value) {
      tabs.add(Tab(
        text: '${key[0].toUpperCase()}${key.substring(1)}',
      ));
      total.addAll(value);
      value.shuffle();
    });

    //Alphabetically sort category
    tabs.sort((a, b) {
      return a.text!.compareTo(b.text!);
    });

    if (mounted) {
      setState(() {
        cTabs = tabs;
        cTabs.insert(
          0,
          Tab(
            text: 'All',
          ),
        );
        allRecipes = total;
        allRecipes.shuffle();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: widget.backPressed,
        child: DefaultTabController(
          length: cTabs.length,
          child: Scaffold(
            appBar: PreferredSize(
                preferredSize:
                    Size(kDisplayWidth(context), kDisplayWidth(context) * 0.35),
                child: AppBar(
                  elevation: 0,
                  backgroundColor: kBackgroundColor,
                  leading: IconButton(
                    icon: Icon(
                      CupertinoIcons.left_chevron,
                      color: kTextColor,
                    ),
                    onPressed: widget.onPressed,
                  ),
                  title: Text(
                    widget.returnText ?? "",
                    textScaleFactor: 1.0,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  actions: [
                    Align(
                      alignment: Alignment.center,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: kDefaultPadding * 0.6),
                        child: Text(
                          widget.endText ?? "",
                          textScaleFactor: 1.0,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium!
                              .copyWith(
                                  color: kSecondaryColor,
                                  fontStyle: FontStyle.italic),
                        ),
                      ),
                    )
                  ],
                  bottom: PreferredSize(
                      preferredSize: Size(
                          kDisplayWidth(context), kDisplayWidth(context) * 0.1),
                      child: (allRecipes.isNotEmpty)
                          ? Align(
                              alignment: Alignment.centerLeft,
                              child: TabBar(
                                padding: EdgeInsets.symmetric(
                                    horizontal: kDefaultPadding),
                                isScrollable: true,
                                physics: BouncingScrollPhysics(),
                                indicatorPadding: EdgeInsets.symmetric(
                                    vertical: 7, horizontal: 3),
                                indicator: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: kPrimaryColor,
                                ),
                                labelColor: kTextColor,
                                unselectedLabelColor: kSecondaryColor,
                                tabs: cTabs,
                              ),
                            )
                          : Container()),
                  flexibleSpace: Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      height: kDisplayHeight(context) * 0.05,
                      margin: EdgeInsets.symmetric(
                        horizontal: kDisplayWidth(context) * 0.07,
                        vertical: kDisplayWidth(context) * 0.13,
                      ),
                      child: Align(
                        alignment: Alignment.bottomLeft,
                        child: Text(widget.header,
                            textScaleFactor: 1.0,
                            style: Theme.of(context).textTheme.headlineSmall),
                      ),
                    ),
                  ),
                )),
            body: (allRecipes.isNotEmpty)
                ? TabBarView(
                    children: cTabs.map((Tab tab) {
                      final label = tab.text!.toLowerCase();
                      return RecipeGridView(
                        label: label,
                        allRecipes: allRecipes,
                        results: widget.results,
                      );
                    }).toList(),
                  )
                : SizedBox(
                    height: kDisplayWidth(context),
                    child: Align(
                      alignment: Alignment.center,
                      child: Text(
                        "No recipes found",
                        textScaleFactor: 1.0,
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge!
                            .apply(color: kSecondaryColor),
                      ),
                    )),
          ),
        ));
  }
}

//Prevents rebuilding when switching tabs, and allows scroll offset for each grid view to be saved as it is different context
class RecipeGridView extends StatefulWidget {
  const RecipeGridView({
    Key? key,
    required this.label,
    required this.allRecipes,
    required this.results,
  }) : super(key: key);

  final String label;
  final List allRecipes;
  final List results;

  @override
  State<RecipeGridView> createState() => _RecipeGridViewState();
}

class _RecipeGridViewState extends State<RecipeGridView>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  final ScrollController sController = ScrollController();

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return CupertinoScrollbar(
      thickness: 5,
      thumbVisibility: true,
      controller: sController,
      radius: Radius.circular(10),
      child: Padding(
        padding: EdgeInsets.only(
            top: kDisplayWidth(context) * 0.01,
            right: kDisplayWidth(context) * 0.04,
            left: kDisplayWidth(context) * 0.04),
        child: GridView.builder(
          controller: sController,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            childAspectRatio:
                kDisplayWidth(context) / (kDisplayHeight_WoTool(context) * 0.6),
            crossAxisCount: 2,
            crossAxisSpacing: kDisplayWidth(context) * 0.003,
            mainAxisSpacing: kDisplayWidth(context) * 0.003,
          ),
          itemCount: (widget.label == "all")
              ? widget.allRecipes.length
              : widget.results[0][widget.label].length,
          itemBuilder: (context, index) {
            return (widget.label == "all")
                ? RecipeCard(
                    recipe: widget.allRecipes[index],
                    onTap: () async {
                      if (!mounted) return;
                      await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => RecipeDetailScreen(
                              recipe: widget.allRecipes[index]),
                        ),
                      );
                    },
                  )
                : RecipeCard(
                    recipe: widget.results[0][widget.label][index],
                    onTap: () async {
                      if (!mounted) return;
                      await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => RecipeDetailScreen(
                              recipe: widget.results[0][widget.label][index]),
                        ),
                      );
                    });
          },
        ),
      ),
    );
  }
}
