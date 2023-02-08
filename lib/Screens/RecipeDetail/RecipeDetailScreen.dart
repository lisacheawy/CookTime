import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cooktime/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import './Components/Body.dart';

class RecipeDetailScreen extends StatefulWidget {
  const RecipeDetailScreen({Key? key, required this.recipe}) : super(key: key);

  final Map<String, dynamic> recipe;

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  final _auth = FirebaseAuth.instance;
  bool isFavourite = false;

  @override
  void initState() {
    super.initState();
    checkFavourites();
  }

  void checkFavourites() {
    final userDoc = FirebaseFirestore.instance
        .collection('Users')
        .doc(_auth.currentUser!.uid);
    userDoc.get().then((DocumentSnapshot doc) {
      final data = doc.data() as Map<String, dynamic>;
      if (data["favouriteRecipes"].contains(widget.recipe["id"]) && mounted) {
        setState(() {
          isFavourite = true;
        });
      }
    }, onError: (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Unable to delete retrieve user favourites ',
            textScaleFactor: 1.0,
          ),
          backgroundColor: kWarningColor,
        ),
      );
    });
  }

  Future<void> addToFavourites(id) async {
    try {
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(_auth.currentUser!.uid)
          .update({
        "favouriteRecipes": FieldValue.arrayUnion([id])
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Unable to add to favourites',
            textScaleFactor: 1.0,
          ),
          backgroundColor: kWarningColor,
        ),
      );
    }
  }

  Future<void> removeFromFavourites(id) async {
    try {
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(_auth.currentUser!.uid)
          .update({
        "favouriteRecipes": FieldValue.arrayRemove([id])
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Unable to remove from favourites',
            textScaleFactor: 1.0,
          ),
          backgroundColor: kWarningColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kWhite,
      body: Body(recipe: widget.recipe),
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: kBackgroundColor,
        elevation: 0,
        title: Text(
            '${widget.recipe["category"][0].toUpperCase()}${widget.recipe["category"].substring(1)}',
            textScaleFactor: 1.0,
            style: Theme.of(context).textTheme.bodyLarge),
        leading: IconButton(
          icon: Icon(
            CupertinoIcons.left_chevron,
            color: kTextColor,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: [
          Container(
            margin: EdgeInsets.only(right: kDefaultPadding * 0.5),
            child: IconButton(
              icon: Icon(
                (isFavourite)
                    ? CupertinoIcons.heart_fill
                    : CupertinoIcons.heart,
                color: kPrimaryColor,
              ),
              onPressed: () {
                if (isFavourite && mounted) {
                  removeFromFavourites(widget.recipe["id"]);
                  setState(() {
                    isFavourite = false;
                  });
                } else if (mounted) {
                  addToFavourites(widget.recipe["id"]);
                  setState(() {
                    isFavourite = true;
                  });
                }
              },
            ),
          )
        ],
      ),
    );
  }
}
