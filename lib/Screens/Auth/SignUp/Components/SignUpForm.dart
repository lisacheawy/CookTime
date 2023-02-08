import 'package:flutter/material.dart';
import '../../../../constants.dart';

class SignUpForm extends StatefulWidget {
  SignUpForm({Key? key, required this.submitFn, required this.isLoading})
      : super(key: key);

  final bool isLoading;

  final void Function(
    String email,
    String password,
    String fullName,
    BuildContext ctx,
  ) submitFn;

  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final _formKey = GlobalKey<FormState>();
  bool _passObscure = true;
  bool _confirmPassObscure = true;

  var _fullName = '';
  var _userEmail = '';
  var _userPassword = '';

  void _trySubmit() {
    final isValid = _formKey.currentState!.validate();
    FocusScope.of(context).unfocus();
    if (isValid) {
      _formKey.currentState!.save();
      widget.submitFn(
        _userEmail.trim(),
        _userPassword.trim(),
        _fullName.trim(),
        context,
      );
    }
  }

  String _password = '';
  String _confirmPassword = '';

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          MediaQuery(
            //Full name
            data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: kDefaultPadding * 0.3),
              child: TextFormField(
                textInputAction: TextInputAction.next,
                style: Theme.of(context).textTheme.bodyMedium,
                validator: requiredValidator,
                onSaved: (value) => _fullName = value!,
                decoration: InputDecoration(
                  enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: kTextColor)),
                  focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: kTextColor)),
                  errorBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: kWarningColor)),
                  errorStyle: TextStyle(color: kWarningColor),
                  floatingLabelBehavior: FloatingLabelBehavior.never,
                  hintText: 'Full name',
                  hintStyle: Theme.of(context)
                      .textTheme
                      .bodyMedium!
                      .apply(color: kSecondaryColor),
                ),
              ),
            ),
          ),
          MediaQuery(
            //Email
            data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: kDefaultPadding * 0.3),
              child: TextFormField(
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.emailAddress,
                style: Theme.of(context).textTheme.bodyMedium,
                validator: emailValidator,
                onSaved: (value) => _userEmail = value!,
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
            ),
          ),
          MediaQuery(
            //Password
            data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
            child: Padding(
                padding: EdgeInsets.symmetric(vertical: kDefaultPadding * 0.3),
                child: TextFormField(
                    obscureText: _passObscure,
                    style: Theme.of(context).textTheme.bodyMedium,
                    validator: passwordValidator,
                    onChanged: (value) => _password = value,
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
                    ))),
          ),
          MediaQuery(
            //Confirm password
            data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
            child: Padding(
                padding: EdgeInsets.symmetric(vertical: kDefaultPadding * 0.3),
                child: TextFormField(
                    obscureText: _confirmPassObscure,
                    style: Theme.of(context).textTheme.bodyMedium,
                    validator: (value) =>
                        matchValidator.validateMatch(value!, _password),
                    onSaved: (value) => value = _confirmPassword,
                    decoration: InputDecoration(
                      enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: kTextColor)),
                      focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: kTextColor)),
                      errorBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: kWarningColor)),
                      errorStyle: TextStyle(color: kWarningColor),
                      floatingLabelBehavior: FloatingLabelBehavior.never,
                      hintText: 'Confirm password',
                      hintStyle: Theme.of(context)
                          .textTheme
                          .bodyMedium!
                          .apply(color: kSecondaryColor),
                      suffixIcon: IconButton(
                          icon: Icon(
                            _confirmPassObscure
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: kSecondaryColor,
                          ),
                          onPressed: () {
                            if (mounted) {
                              setState(() {
                                _confirmPassObscure = !_confirmPassObscure;
                              });
                            }
                          }),
                    ))),
          ),
          if (widget.isLoading)
            CircularProgressIndicator(
              color: kSecondaryColor,
            ),
          if (!widget.isLoading)
            SignUpButton(
              press: _trySubmit,
              text: 'Sign Up',
              color: kPrimaryColor,
            )
        ],
      ),
    );
  }
}

class SignUpButton extends StatelessWidget {
  const SignUpButton(
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
        margin: EdgeInsets.symmetric(vertical: kDefaultPadding * 2),
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
