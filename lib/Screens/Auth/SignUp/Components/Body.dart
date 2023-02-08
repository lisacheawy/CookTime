import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cooktime/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../main.dart';
import 'SignUpForm.dart';

class Body extends StatefulWidget {
  const Body({Key? key}) : super(key: key);

  @override
  State<Body> createState() => _BodyState();
}

class _BodyState extends State<Body> {
  final _auth = FirebaseAuth.instance;
  bool isLoading = false;

  @override
  void dispose() {
    super.dispose();
  }

  Future _submitAuthForm(
    String email,
    String password,
    String fullName,
    BuildContext ctx,
  ) async {
    UserCredential authResult;
    try {
      if (mounted) {
        setState(() {
          isLoading = true;
        });
      }
      authResult = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(authResult.user!.uid)
          .set({
        'userid': authResult.user!.uid,
        'email': email,
        'fullName': fullName,
        'favouriteRecipes': [],
        'preferences': {
          'veganOnly': false,
          'vegetarianOnly': false,
          'withPork': true,
          'glutenFree': false
        }
      }).then((_) async {
        if (mounted) {
          setState(() {
            isLoading = false;
          });
          await Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => MyApp(),
            ),
          );
        }
      });
    } on FirebaseAuthException catch (err) {
      var message = 'An error occurred, please check your credentials.';

      if (mounted) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            err.code,
            textScaleFactor: 1.0,
          ),
          backgroundColor: kWarningColor,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
          margin: EdgeInsets.only(
              top: kDisplayHeight_WoTool(context) * 0.07,
              left: kDefaultPadding,
              right: kDefaultPadding),
          width: kDisplayWidth(context),
          height: kDisplayHeight_WoTool(context),
          child: Column(
            children: [
              //Logo
              Container(
                margin: EdgeInsets.symmetric(vertical: kDefaultPadding * 0.4),
                child: Column(
                  children: [
                    Container(
                        height: kDisplayHeight(context) * 0.13,
                        margin: EdgeInsets.only(bottom: kDefaultPadding * 0.6),
                        child: SvgPicture.asset('assets/images/FryingPan.svg',
                            fit: BoxFit.fitHeight)),
                    Text('Create Account',
                        textScaleFactor: 1.0,
                        style: Theme.of(context).textTheme.headlineMedium),
                  ],
                ),
              ),
              Expanded(
                  child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: kDefaultPadding * 1.2,
                      ),
                      margin:
                          EdgeInsets.only(top: kDisplayHeight(context) * 0.04),
                      child: SignUpForm(
                          submitFn: _submitAuthForm, isLoading: isLoading))),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text('Already a user?',
                    textScaleFactor: 1.0,
                    style: Theme.of(context).textTheme.bodyMedium),
                TextButton(
                  onPressed: () async {
                    if (!mounted) return;
                    await Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (context) => MyApp()));
                  },
                  child: Text('Sign in',
                      textScaleFactor: 1.0,
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          fontWeight: FontWeight.w500, color: kPrimaryColor)),
                )
              ]),
            ],
          )),
    );
  }
}
