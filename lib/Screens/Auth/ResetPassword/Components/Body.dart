import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cooktime/Screens/Capture/Components/Background.dart';
import 'package:cooktime/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'ResetPasswordForm.dart';

class Body extends StatefulWidget {
  const Body({
    Key? key,
  }) : super(key: key);

  @override
  State<Body> createState() => _BodyState();
}

class _BodyState extends State<Body> {
  bool isLoading = false;

  void _submitResetForm(String email, BuildContext ctx) async {
    try {
      if (mounted) {
        setState(() {
          isLoading = true;
        });
      }
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "We've sent you a password reset email.",
            textScaleFactor: 1.0,
          ),
          backgroundColor: kPrimaryColor,
        ),
      );
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
      Navigator.of(context).popUntil((route) => route.isFirst);
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.toString(),
              textScaleFactor: 1.0,
            ),
            backgroundColor: kWarningColor,
          ),
        );
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      background(
        withPan: false,
      ),
      Align(
          alignment: Alignment.topLeft,
          child: Container(
            margin: EdgeInsets.only(top: kToolbarHeight),
            child: TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Icon(
                CupertinoIcons.left_chevron,
                color: kTextColor,
              ),
            ),
          )),
      Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              alignment: Alignment.center,
              child: Text(
                "Reset your password",
                textScaleFactor: 1.0,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            ResetPasswordForm(
              resetPassword: _submitResetForm,
            ),
          ]),
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
    ]);
  }
}
