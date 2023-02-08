import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cooktime/Screens/Favourites/FavouriteScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../constants.dart';
import 'Header.dart';
import 'UserDetails.dart';

class Body extends StatefulWidget {
  const Body({Key? key}) : super(key: key);

  @override
  State<Body> createState() => _BodyState();
}

class _BodyState extends State<Body> {
  final _auth = FirebaseAuth.instance;

  var fullName = "";
  var email = "";
  bool porkSwitch = true;
  bool withPork = true;
  bool veganSwitch = false;
  bool veganOnly = false;
  bool vegetarianSwitch = false;
  bool vegetarianOnly = false;
  bool glutenFree = false;
  bool isLoading = true;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    if (mounted) {
      setState(() {
        isLoading = true;
      });
    }
    getUserData();
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  void stateSwitch(param) {
    switch (param) {
      case 'withPork':
        {
          setState(() {
            porkSwitch = true;
            veganSwitch = false;
            vegetarianSwitch = false;
          });
        }
        break;
      case 'veganOnly':
        {
          setState(() {
            veganSwitch = true;
            vegetarianSwitch = false;
            porkSwitch = false;
          });
        }
        break;
      case 'vegetarianOnly':
        {
          setState(() {
            vegetarianSwitch = true;
            veganSwitch = false;
            porkSwitch = false;
          });
        }
        break;
    }
  }

  void getUserData() async {
    final userDoc = FirebaseFirestore.instance
        .collection('Users')
        .doc(_auth.currentUser!.uid);
    userDoc.get().then((DocumentSnapshot doc) {
      final data = doc.data() as Map<String, dynamic>;
      if (mounted) {
        setState(() {
          fullName = data['fullName'];
          email = data['email'];
          withPork = data['preferences']['withPork'];
          veganOnly = data['preferences']['veganOnly'];
          vegetarianOnly = data['preferences']['vegetarianOnly'];
          glutenFree = data['preferences']['glutenFree'];

          if (withPork) {
            stateSwitch('withPork');
          } else if (veganOnly) {
            stateSwitch('veganOnly');
          } else if (vegetarianOnly) {
            stateSwitch('vegetarianOnly');
          } else {
            setState(() {
              vegetarianSwitch = true;
              veganSwitch = true;
              porkSwitch = true;
            });
          }

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
              'Unable to delete retrieve user doc $e',
              textScaleFactor: 1.0,
            ),
            backgroundColor: kWarningColor,
          ),
        );
      }
    });
  }

  void updateUserData(param, value) async {
    final doc = FirebaseFirestore.instance
        .collection('Users')
        .doc(_auth.currentUser!.uid);
    await doc.update({'preferences.$param': value}).then((_) {
      getUserData();
    }, onError: (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Unable to update preferences',
            textScaleFactor: 1.0,
          ),
          backgroundColor: kWarningColor,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
          width: kDisplayWidth(context),
          padding: EdgeInsets.only(top: kToolbarHeight),
          margin:
              EdgeInsets.symmetric(horizontal: kDisplayWidth(context) * 0.07),
          child: isLoading
              ? Container(
                  height: kDisplayHeight_WoTool(context),
                  color: kBackgroundColor,
                  alignment: Alignment.center,
                  child: SizedBox(
                    height: kDisplayWidth(context) * 0.2,
                    width: kDisplayWidth(context) * 0.2,
                    child: CircularProgressIndicator(
                      color: kSecondaryColor,
                    ),
                  ))
              : Column(
                  children: [
                    Header(
                      onPressed: () async {
                        if (!mounted) return;
                        await Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => FavouriteScreen()));
                      },
                    ),
                    UserDetails(fullName: fullName, email: email),
                    Container(
                        margin: EdgeInsets.symmetric(
                            vertical: kDefaultPadding * 0.5),
                        child: Column(
                          children: [
                            MergeSemantics(
                              child: ListTile(
                                contentPadding:
                                    EdgeInsets.symmetric(horizontal: 0),
                                title: Text('Show vegan recipes only',
                                    textScaleFactor: 1.0,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .apply(
                                            color: veganSwitch
                                                ? kTextColor
                                                : kSecondaryColor)),
                                trailing: Transform.scale(
                                  scale: 0.8,
                                  child: CupertinoSwitch(
                                    activeColor: kPositiveColor,
                                    trackColor: kSecondaryColor,
                                    value: veganOnly,
                                    onChanged: veganSwitch
                                        ? (bool value) {
                                            updateUserData('veganOnly', value);
                                          }
                                        : null,
                                  ),
                                ),
                              ),
                            ),
                            MergeSemantics(
                              child: ListTile(
                                contentPadding:
                                    EdgeInsets.symmetric(horizontal: 0),
                                title: Text('Show vegetarian recipes only',
                                    textScaleFactor: 1.0,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .apply(
                                            color: vegetarianSwitch
                                                ? kTextColor
                                                : kSecondaryColor)),
                                trailing: Transform.scale(
                                  scale: 0.8,
                                  child: CupertinoSwitch(
                                    activeColor: kPositiveColor,
                                    trackColor: kSecondaryColor,
                                    value: vegetarianOnly,
                                    onChanged: vegetarianSwitch
                                        ? (bool value) {
                                            updateUserData(
                                                'vegetarianOnly', value);
                                          }
                                        : null,
                                  ),
                                ),
                              ),
                            ),
                            MergeSemantics(
                              child: ListTile(
                                contentPadding:
                                    EdgeInsets.symmetric(horizontal: 0),
                                title: Text('Show recipes which contain pork',
                                    textScaleFactor: 1.0,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .apply(
                                            color: porkSwitch
                                                ? kTextColor
                                                : kSecondaryColor)),
                                trailing: Transform.scale(
                                  scale: 0.8,
                                  child: CupertinoSwitch(
                                    activeColor: kPositiveColor,
                                    trackColor: kSecondaryColor,
                                    value: withPork,
                                    onChanged: porkSwitch
                                        ? (bool value) {
                                            updateUserData('withPork', value);
                                          }
                                        : null,
                                  ),
                                ),
                              ),
                            ),
                            MergeSemantics(
                              child: ListTile(
                                contentPadding:
                                    EdgeInsets.symmetric(horizontal: 0),
                                title: Text('Show gluten-free recipes only',
                                    textScaleFactor: 1.0,
                                    style:
                                        Theme.of(context).textTheme.bodyMedium),
                                trailing: Transform.scale(
                                  scale: 0.8,
                                  child: CupertinoSwitch(
                                    activeColor: kPositiveColor,
                                    trackColor: kSecondaryColor,
                                    value: glutenFree,
                                    onChanged: (bool value) {
                                      updateUserData('glutenFree', value);
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )),
                    Divider(),
                    TextButton(
                        style: TextButton.styleFrom(padding: EdgeInsets.zero),
                        onPressed: _signOut,
                        child: Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(right: 8.0),
                              child: Text(
                                "Log out",
                                textScaleFactor: 1.0,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall!
                                    .apply(color: kWarningColor),
                              ),
                            ),
                            Icon(
                              Icons.logout_rounded,
                              color: kWarningColor,
                              size: kDisplayHeight(context) * 0.02,
                            )
                          ],
                        )),
                  ],
                )),
    );
  }
}
