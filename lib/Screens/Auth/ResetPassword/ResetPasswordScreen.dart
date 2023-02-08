import 'package:flutter/material.dart';
import 'Components/Body.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  @override
  Widget build(BuildContext context) => Scaffold(
        resizeToAvoidBottomInset: true,
        body: GestureDetector(
            onTap: () {
              FocusManager.instance.primaryFocus?.unfocus();
            },
            child: Body()),
      );
}
