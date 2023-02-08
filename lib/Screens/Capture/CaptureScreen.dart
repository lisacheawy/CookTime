import 'package:flutter/material.dart';
import './Components/Body.dart';

class CaptureScreen extends StatelessWidget {
  const CaptureScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Body(),
    );
  }
}
