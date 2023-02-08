import 'package:cooktime/Screens/Auth/ResetPassword/ResetPasswordScreen.dart';
import 'package:flutter/material.dart';
import '../../../../constants.dart';

class SignInForm extends StatefulWidget {
  const SignInForm({Key? key, required this.submitFn, required this.isLoading})
      : super(key: key);

  final bool isLoading;

  final void Function(
    String email,
    String password,
    BuildContext ctx,
  ) submitFn;

  @override
  State<SignInForm> createState() => _SignInFormState();
}

class _SignInFormState extends State<SignInForm> {
  final _formKey = GlobalKey<FormState>();
  bool _passObscure = true;

  var _userEmail = '';
  var _userPassword = '';

  void _trySubmit() {
    final isValid = _formKey.currentState!.validate();
    FocusScope.of(context).unfocus();

    if (isValid) {
      _formKey.currentState!.save();
      widget.submitFn(_userEmail.trim(), _userPassword.trim(), context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        child: Column(
          children: [
            Container(
              alignment: Alignment.centerLeft,
              margin: EdgeInsets.only(bottom: kDefaultPadding * 0.5),
              child: Text(
                'Sign-in to continue',
                textScaleFactor: 1.0,
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall!
                    .copyWith(fontSize: 20),
              ),
            ),
            MediaQuery(
                data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                child: Padding(
                  padding:
                      EdgeInsets.symmetric(vertical: kDefaultPadding * 0.3),
                  child: TextFormField(
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.emailAddress,
                    style: Theme.of(context).textTheme.bodyMedium,
                    onSaved: (value) => _userEmail = value!.trim(),
                    validator: emailValidator,
                    decoration: InputDecoration(
                      enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: kTextColor)),
                      focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: kTextColor)),
                      errorBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: kWarningColor)),
                      errorStyle: TextStyle(color: kWarningColor),
                      floatingLabelBehavior: FloatingLabelBehavior.never,
                      hintText: 'Email address',
                      hintStyle: Theme.of(context)
                          .textTheme
                          .bodyMedium!
                          .apply(color: kSecondaryColor),
                    ),
                  ),
                )),
            MediaQuery(
                data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                child: Padding(
                  padding: EdgeInsets.only(top: kDefaultPadding * 0.3),
                  child: TextFormField(
                    obscureText: _passObscure,
                    validator: signInPasswordValidator,
                    style: Theme.of(context).textTheme.bodyMedium,
                    onSaved: (value) => _userPassword = value!,
                    decoration: InputDecoration(
                      enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: kTextColor)),
                      focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: kTextColor)),
                      errorBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: kWarningColor)),
                      errorStyle: TextStyle(color: kWarningColor),
                      floatingLabelBehavior: FloatingLabelBehavior.never,
                      hintText: 'Password',
                      hintStyle: Theme.of(context)
                          .textTheme
                          .bodyMedium!
                          .apply(color: kSecondaryColor),
                      suffixIcon: IconButton(
                          icon: Icon(
                            _passObscure
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: kSecondaryColor,
                          ),
                          onPressed: () {
                            if (mounted) {
                              setState(() {
                                _passObscure = !_passObscure;
                              });
                            }
                          }),
                    ),
                  ),
                )),
            Container(
                height: kDefaultPadding * 2,
                margin: EdgeInsets.only(bottom: kDefaultPadding),
                alignment: Alignment.centerRight,
                child: TextButton(
                    onPressed: () async {
                      if (!mounted) return;
                      await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ResetPasswordScreen()));
                    },
                    child: Text(
                      'Forgot password?',
                      textScaleFactor: 1.0,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall!
                          .apply(color: kTextColor),
                    ))),
            if (widget.isLoading)
              CircularProgressIndicator(
                color: kSecondaryColor,
              ),
            if (!widget.isLoading)
              SignInButton(
                press: _trySubmit,
                text: 'Sign In',
                color: kPrimaryColor,
              )
          ],
        ));
  }
}

class SignInButton extends StatelessWidget {
  const SignInButton(
      {Key? key, required this.press, required this.text, required this.color})
      : super(key: key);

  final VoidCallback press;
  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: press,
      child: Container(
        height: kDisplayHeight_WoTool(context) * 0.05,
        width: kDisplayWidth(context) * 0.58,
        decoration: BoxDecoration(
            color: kPrimaryColor, borderRadius: BorderRadius.circular(20)),
        child: Align(
          alignment: Alignment.center,
          child: Text(
            text,
            textScaleFactor: 1.0,
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
                color: Color(0xFFF5F5F5), fontWeight: FontWeight.w500),
          ),
        ),
      ),
    );
  }
}
