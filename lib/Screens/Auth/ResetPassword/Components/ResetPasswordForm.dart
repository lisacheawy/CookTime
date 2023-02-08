import 'package:flutter/material.dart';
import '../../../../constants.dart';

class ResetPasswordForm extends StatefulWidget {
  const ResetPasswordForm({Key? key, required this.resetPassword})
      : super(key: key);

  final void Function(
    String email,
    BuildContext ctx,
  ) resetPassword;

  @override
  State<ResetPasswordForm> createState() => _ResetPasswordFormState();
}

class _ResetPasswordFormState extends State<ResetPasswordForm> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  void _trySubmit() {
    FocusScope.of(context).unfocus();
    widget.resetPassword(
      emailController.text.trim(),
      context,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(children: [
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: kDefaultPadding * 1.2,
          ),
          margin: EdgeInsets.symmetric(
              vertical: kDisplayHeight(context) * 0.03,
              horizontal: kDefaultPadding),
          child: MediaQuery(
              data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
              child: TextFormField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                style: Theme.of(context).textTheme.bodyMedium,
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
              )),
        ),
        GestureDetector(
          onTap: _trySubmit,
          child: Container(
            margin: EdgeInsets.only(top: kDefaultPadding),
            height: kDisplayHeight_WoTool(context) * 0.05,
            width: kDisplayWidth(context) * 0.58,
            decoration: BoxDecoration(
                color: kPrimaryColor, borderRadius: BorderRadius.circular(20)),
            child: Align(
              alignment: Alignment.center,
              child: Text(
                'Reset password',
                textScaleFactor: 1.0,
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    color: Color(0xFFF5F5F5), fontWeight: FontWeight.w500),
              ),
            ),
          ),
        )
      ]),
    );
  }
}
