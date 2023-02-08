import 'package:cooktime/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import './Components/Body.dart';

class FavouriteScreen extends StatefulWidget {
  const FavouriteScreen({Key? key}) : super(key: key);

  @override
  State<FavouriteScreen> createState() => _FavouriteScreenState();
}

class _FavouriteScreenState extends State<FavouriteScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: kBackgroundColor,
        leading: IconButton(
          icon: Icon(
            CupertinoIcons.left_chevron,
            color: kTextColor,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Body(),
    );
  }
}
