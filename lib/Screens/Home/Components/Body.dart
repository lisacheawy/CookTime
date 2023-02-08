import 'package:cooktime/Screens/Favourites/FavouriteScreen.dart';
import 'package:cooktime/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../Components/RecipeCard.dart';
import '../../../Components/RecipeCardPlaceholder.dart';
import '../../../Utils/CustomDialogUtils.dart';
import '../../../Utils/FetchRecipeUtils.dart';
import '../../RecipeDetail/RecipeDetailScreen.dart';
import 'package:flutter/material.dart';
import '../../RecipeResult/RecipeResultScreen.dart';
import 'Header.dart';
import 'RowHeader.dart';

class Body extends StatefulWidget {
  const Body({Key? key}) : super(key: key);

  @override
  State<Body> createState() => _BodyState();
}

class _BodyState extends State<Body> {
  final _auth = FirebaseAuth.instance;
  List favouriteRecipes = [];
  List recommendedRecipes = [];
  bool isLoading = true;
  bool isRecLoading = true;

  @override
  void initState() {
    super.initState();
    fetchFavourites();
    fetchHomeRecipes();
  }

  Future<void> fetchFavourites() async {
    const url = "https://lisachea.xyz/cooktime/home/fetchFavourites";
    // const url = "http://10.0.2.2:5003/cooktime/home/fetchFavourites";
    try {
      if (mounted) {
        setState(() {
          isLoading = true;
        });
      }
      final res = await http.post(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(
          {
            'uid': _auth.currentUser!.uid,
          },
        ),
      );
      if (res.body.isNotEmpty) {
        if (mounted) {
          setState(() {
            favouriteRecipes = jsonDecode(res.body);
            favouriteRecipes.shuffle();
            isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Unable to retrieve recipe detail $e',
              textScaleFactor: 1.0,
            ),
            backgroundColor: kWarningColor,
          ),
        );
      }
    }
  }

  Future<void> fetchHomeRecipes() async {
    const url = "https://lisachea.xyz/cooktime/home/fetchRecipe";
    // const url = "http://10.0.2.2:5003/cooktime/home/fetchRecipe";
    List categories = [];
    if (favouriteRecipes.isNotEmpty) {
      for (var i = 0; i < favouriteRecipes.length; i++) {
        categories.add(favouriteRecipes[i].category);
      }
    }
    try {
      if (mounted) {
        setState(() {
          isRecLoading = true;
        });
      }
      final res = await http.post(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(
          {
            'categories': categories,
          },
        ),
      );
      if (res.body.isNotEmpty) {
        if (mounted) {
          setState(() {
            recommendedRecipes = jsonDecode(res.body);
            isRecLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isRecLoading = false;
        });
        Navigator.of(context).pop(); //remove dialog box
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Unable to retrieve recipes',
              textScaleFactor: 1.0,
            ),
            backgroundColor: kWarningColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // enables scrolling on small devices
    return SingleChildScrollView(
        child: Column(children: <Widget>[
      Header(),
      //Try something new
      RowHeader(
          title: 'Try something new',
          topMargin: 0,
          onPressed: () async {
            showCustomDialog(context, "loading", "Fetching recipes");
            var recipes =
                await getRecipes(_auth.currentUser!.uid, [], context, mounted);
            if (recipes.isNotEmpty && mounted) {
              Navigator.of(context).pop(); //remove dialog box
              await Navigator.of(context)
                  .push(
                    MaterialPageRoute(
                      builder: (context) => RecipeResultScreen(
                          results: recipes,
                          header: "Browse All",
                          endText: "Based on preferences",
                          backPressed: () async {
                            return true;
                          },
                          onPressed: () {
                            Navigator.of(context).pop();
                          }),
                    ),
                  )
                  .then((_) => fetchFavourites());
            }
          }),
      Container(
          margin: EdgeInsets.only(bottom: kDefaultPadding / 2.5),
          height: (isRecLoading || recommendedRecipes.isNotEmpty)
              ? kDisplayWidth(context) * 0.5
              : kDisplayWidth(context) * 0.1,
          child: (isRecLoading || recommendedRecipes.isNotEmpty)
              ? GridView.builder(
                  physics: BouncingScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: kDisplayWidth(context) * 5,
                    childAspectRatio: kDisplayWidth(context) /
                        (kDisplayHeight(context) * 0.47),
                    crossAxisSpacing: kDisplayWidth(context) * 0.003,
                    mainAxisSpacing: kDisplayWidth(context) * 0.003,
                  ),
                  padding:
                      EdgeInsets.symmetric(horizontal: kDefaultPadding / 1.5),
                  scrollDirection: Axis.horizontal,
                  itemCount: (isRecLoading) ? 2 : recommendedRecipes.length,
                  itemBuilder: (context, index) {
                    return (isRecLoading)
                        ? RecipeCardPlaceHolder()
                        : RecipeCard(
                            recipe: recommendedRecipes[index],
                            onTap: () async {
                              if (!mounted) return;
                              await Navigator.of(context)
                                  .push(
                                MaterialPageRoute(
                                  builder: (context) => RecipeDetailScreen(
                                      recipe: recommendedRecipes[index]),
                                ),
                              )
                                  .then((_) {
                                fetchFavourites();
                              });
                            },
                          );
                  })
              : Align(
                  //for cases where recipes cannot be retrieved
                  alignment: Alignment.center,
                  child: Text(
                    textScaleFactor: 1.0,
                    "Unable to fetch recipes",
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall!
                        .apply(color: kSecondaryColor),
                  ),
                )),
      //Favourited recipes
      RowHeader(
          title: 'Your favourited recipes',
          topMargin: kDefaultPadding * 0.5,
          onPressed: () async {
            if (!mounted) return;
            await Navigator.of(context)
                .push(
              MaterialPageRoute(
                builder: (context) => FavouriteScreen(),
              ),
            )
                .then((_) {
              fetchHomeRecipes();
            });
          }),
      Container(
          margin: EdgeInsets.only(bottom: kDefaultPadding / 2.5),
          height: (isLoading || favouriteRecipes.isNotEmpty)
              ? kDisplayWidth(context) * 0.5
              : kDisplayWidth(context) * 0.1,
          width: kDisplayWidth(context),
          child: (isLoading || favouriteRecipes.isNotEmpty)
              ? GridView.builder(
                  physics: BouncingScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 250,
                    childAspectRatio: kDisplayWidth(context) /
                        (kDisplayHeight(context) * 0.47),
                    crossAxisSpacing: kDisplayWidth(context) * 0.003,
                    mainAxisSpacing: kDisplayWidth(context) * 0.003,
                  ),
                  padding:
                      EdgeInsets.symmetric(horizontal: kDefaultPadding / 1.5),
                  scrollDirection: Axis.horizontal,
                  itemCount: (isLoading)
                      ? 2
                      : (favouriteRecipes.length > 5
                          ? 5
                          : favouriteRecipes.length),
                  itemBuilder: (context, index) {
                    return (isLoading)
                        ? RecipeCardPlaceHolder()
                        : RecipeCard(
                            recipe: favouriteRecipes[index],
                            onTap: () async {
                              if (!mounted) return;
                              await Navigator.of(context)
                                  .push(
                                MaterialPageRoute(
                                  builder: (context) => RecipeDetailScreen(
                                      recipe: favouriteRecipes[index]),
                                ),
                              )
                                  .then((_) {
                                fetchFavourites();
                              });
                            },
                          );
                  })
              : Align(
                  alignment: Alignment.center,
                  child: Text(
                    textScaleFactor: 1.0,
                    "No favourites found!",
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall!
                        .apply(color: kSecondaryColor),
                  ),
                )),
    ]));
  }
}
