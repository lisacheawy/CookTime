import 'package:camera/camera.dart';
import 'package:cooktime/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import './Components/Body.dart';

class TakePictureScreen extends StatelessWidget {
  const TakePictureScreen({Key? key, required this.camera}) : super(key: key);

  final CameraDescription camera;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
          backgroundColor: Colors.black,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              CupertinoIcons.left_chevron,
              color: kWhite,
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          )),
      body: Body(camera: camera),
    );
  }
}
