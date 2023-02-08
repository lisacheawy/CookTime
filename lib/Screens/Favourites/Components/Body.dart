import 'package:cooktime/Components/RecipeCardPlaceholder.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../Components/Header.dart';
import '../../../Components/RecipeCard.dart';
import '../../../constants.dart';
import '../../RecipeDetail/RecipeDetailScreen.dart';

class Body extends StatefulWidget {
  const Body({Key? key}) : super(key: key);

  @override
  State<Body> createState() => _BodyState();
}

class _BodyState extends State<Body> {
  final _auth = FirebaseAuth.instance;
  List favouriteRecipes = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchFavourites();
  }

  Future<void> fetchFavourites() async {
    if (mounted) {
      setState(() {
        isLoading = true;
      });
    }
    const url = "https://lisachea.xyz/cooktime/home/fetchFavourites";
    // const url = "http://10.0.2.2:5003/cooktime/home/fetchFavourites";
    try {
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
              'Unable to retrieve recipe detail',
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
    return SizedBox(
      height: kDisplayHeight(context),
      width: kDisplayWidth(context),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Header(
            title: 'Favourited Recipes',
            padding: EdgeInsets.only(bottom: kToolbarHeight * 0.15),
          ),
          Expanded(
              child: MediaQuery.removePadding(
            context: context,
            removeTop: true,
            child: Container(
                child: (isLoading || favouriteRecipes.isNotEmpty)
                    ? Padding(
                        padding: EdgeInsets.only(
                            top: kDisplayWidth(context) * 0.01,
                            right: kDisplayWidth(context) * 0.04,
                            left: kDisplayWidth(context) * 0.04),
                        child: GridView.builder(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            childAspectRatio: kDisplayWidth(context) /
                                (kDisplayHeight_WoTool(context) * 0.6),
                            crossAxisCount: 2,
                            crossAxisSpacing: kDisplayWidth(context) * 0.003,
                            mainAxisSpacing: kDisplayWidth(context) * 0.003,
                          ),
                          itemCount: (isLoading) ? 5 : favouriteRecipes.length,
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
                                          builder: (context) =>
                                              RecipeDetailScreen(
                                                  recipe:
                                                      favouriteRecipes[index]),
                                        ),
                                      )
                                          .then((_) {
                                        fetchFavourites();
                                      });
                                    },
                                  );
                          },
                        ),
                      )
                    : Align(
                        alignment: Alignment.center,
                        child: Text(
                          "No favourites found!",
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge!
                              .apply(color: kSecondaryColor),
                        ),
                      )),
          ))
        ],
      ),
    );
  }
}

// class Header extends StatelessWidget {
//   const Header({
//     Key? key,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: kDisplayWidth(context),
//       padding: EdgeInsets.only(bottom: kToolbarHeight * 0.15),
//       margin: EdgeInsets.symmetric(horizontal: kDisplayWidth(context) * 0.07),
//       child: Text('Favourited Recipes',
//           textScaleFactor: 1.0,
//           style: Theme.of(context).textTheme.headlineSmall),
//     );
//   }
// }
