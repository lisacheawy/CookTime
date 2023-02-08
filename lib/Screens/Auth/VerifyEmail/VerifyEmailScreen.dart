import 'dart:async';
import 'package:cooktime/Screens/Capture/Components/Background.dart';
import 'package:cooktime/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../main.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  final auth = FirebaseAuth.instance;
  bool isEmailVerified = false;
  bool canResendEmail = false;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    User user = auth.currentUser!;
    isEmailVerified = user.emailVerified;
    if (!isEmailVerified) {
      sendVerificationEmail();

      timer = Timer.periodic(
        //check every 3 seconds if email has been verified
        Duration(seconds: 3),
        (_) => checkEmailVerified(),
      );
    }
  }

  @override
  void dispose() {
    //dispose timer after used
    timer?.cancel();
    super.dispose();
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  Future checkEmailVerified() async {
    User user = FirebaseAuth.instance.currentUser!;
    if (!mounted) return;
    await user.reload(); //gets new status
    user = FirebaseAuth.instance.currentUser!;
    if (mounted) {
      setState(() {
        isEmailVerified = user.emailVerified;
      });
    }

    if (isEmailVerified) {
      timer?.cancel();
      if (!mounted) return;
      await Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MyApp(),
        ),
      );
    }

    // call after email is verified
  }

  Future sendVerificationEmail() async {
    try {
      await FirebaseAuth.instance.currentUser!.sendEmailVerification();
      if (mounted) {
        setState(() {
          canResendEmail = false;
        });
      }
      await Future.delayed(Duration(seconds: 5));
      if (mounted) {
        setState(() {
          canResendEmail = true;
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString(),
            textScaleFactor: 1.0,
          ),
          backgroundColor: kWarningColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Stack(children: [
          background(
            withPan: false,
          ),
          Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  alignment: Alignment.center,
                  child: Text(
                    "We've sent a verification email to\n${FirebaseAuth.instance.currentUser!.email}",
                    style: Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.center,
                    textScaleFactor: 1.0,
                  ),
                ),
                Container(
                    margin: EdgeInsets.only(top: kDefaultPadding),
                    child: GestureDetector(
                      onTap: canResendEmail ? sendVerificationEmail : null,
                      child: Container(
                        height: kDisplayHeight_WoTool(context) * 0.05,
                        width: kDisplayWidth(context) * 0.58,
                        decoration: BoxDecoration(
                            color: canResendEmail
                                ? kPrimaryColor
                                : kSecondaryColor,
                            borderRadius: BorderRadius.circular(20)),
                        child: Align(
                          alignment: Alignment.center,
                          child: Text(
                            'Resend email',
                            textScaleFactor: 1.0,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium!
                                .copyWith(
                                    color: Color(0xFFF5F5F5),
                                    fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                    )),
                Container(
                    margin: EdgeInsets.only(
                        top: kDefaultPadding / 2, bottom: kDefaultPadding * 2),
                    child: Text(
                      canResendEmail
                          ? ''
                          : 'Email has been sent. Please try again in 5s.',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall!
                          .apply(color: kSecondaryColor),
                      textScaleFactor: 1.0,
                    )),
                TextButton(
                    onPressed: () async {
                      _signOut();
                      if (!mounted) return;
                      await Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MyApp(),
                        ),
                      );
                    },
                    child: Text("Cancel",
                        textScaleFactor: 1.0,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium!
                            .apply(color: kWarningColor)))
              ]),
        ]),
      );
}
