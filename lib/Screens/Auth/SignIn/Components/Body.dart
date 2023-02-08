import 'package:cooktime/Screens/Auth/SignUp/SignUpScreen.dart';
import 'package:cooktime/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import '../../VerifyEmail/VerifyEmailScreen.dart';
import 'SignInForm.dart';

class Body extends StatefulWidget {
  const Body({Key? key}) : super(key: key);

  @override
  State<Body> createState() => _BodyState();
}

class _BodyState extends State<Body> {
  final _auth = FirebaseAuth.instance;
  bool isLoading = false;
  bool isEmailVerified = false;

  void _submitAuthForm(
    String email,
    String password,
    BuildContext ctx,
  ) async {
    UserCredential authResult;
    try {
      if (mounted) {
        setState(() {
          isLoading = true;
        });
      }

      authResult = await _auth.signInWithEmailAndPassword(
          email: email, password: password);

      if (mounted) {
        setState(() {
          isEmailVerified = _auth.currentUser!.emailVerified;
        });
      }

      if (!isEmailVerified && mounted) {
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => VerifyEmailScreen(),
          ),
        );
      }

      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    } on PlatformException catch (err) {
      var message = 'An error occurred, please check your credentials';

      if (err.message != null) {
        message = 'Error signing in';
      }
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            message,
            textScaleFactor: 1.0,
          ),
          backgroundColor: kWarningColor,
        ));
      }
    } catch (err) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error signing in',
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
    return SingleChildScrollView(
        child: Container(
            margin: EdgeInsets.only(
              top: kDisplayHeight_WoTool(context) * 0.07,
            ),
            width: kDisplayWidth(context),
            height: kDisplayHeight_WoTool(context),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: kDisplayWidth(context) * 0.28,
                      height: kDisplayHeight_WoTool(context) * 0.3,
                      child: SvgPicture.asset(
                          'assets/images/FryingPan-Half.svg',
                          fit: BoxFit.fitWidth),
                    ),
                    Container(
                      margin: EdgeInsets.only(
                          bottom: kDisplayHeight_WoTool(context) * 0.05),
                      child: Text(
                        'Ready to cook?',
                        textScaleFactor: 1.0,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                    )
                  ],
                ),
                Expanded(
                  child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: kDefaultPadding * 1.2,
                      ),
                      margin: EdgeInsets.symmetric(
                          vertical: kDisplayHeight(context) * 0.03,
                          horizontal: kDefaultPadding),
                      child: SignInForm(
                        submitFn: _submitAuthForm,
                        isLoading: isLoading,
                      )),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Don't have an account?",
                        textScaleFactor: 1.0,
                        style: Theme.of(context).textTheme.bodyMedium),
                    TextButton(
                      onPressed: () async {
                        if (!mounted) return;
                        await Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SignUpScreen()));
                      },
                      child: Text('Register now',
                          textScaleFactor: 1.0,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium!
                              .copyWith(
                                  fontWeight: FontWeight.w500,
                                  color: kPrimaryColor)),
                    )
                  ],
                )
              ],
            )));
  }
}
