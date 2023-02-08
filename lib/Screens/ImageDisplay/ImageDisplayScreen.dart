import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import '../../Utils/CustomDialogUtils.dart';
import '../../Utils/UserIngredientUtils.dart';
import '../Ingredients/IngredientsScreen.dart';
import './Components/Body.dart';
import 'package:flutter/material.dart';
import 'package:cooktime/constants.dart';

class ImageDisplayScreen extends StatefulWidget {
  const ImageDisplayScreen(
      {required this.imgCollection,
      Key? key,
      required this.screenHeader,
      required this.asset})
      : super(key: key);

  final List imgCollection;
  final String screenHeader;
  final String asset;

  @override
  State<ImageDisplayScreen> createState() => _ImageDisplayScreenState();
}

class _ImageDisplayScreenState extends State<ImageDisplayScreen> {
  final _auth = FirebaseAuth.instance;
  List predictions = [];
  List storageUrls = [];

  Future<void> getIngredientUrl() async {
    final userIngredientDoc = FirebaseFirestore.instance
        .collection('UserIngredients')
        .doc(_auth.currentUser!.uid);
    await userIngredientDoc.get().then((DocumentSnapshot doc) {
      final data = doc.data() as Map<String, dynamic>;
      setState(() {
        storageUrls = data['storageUrls'];
      });
    }, onError: (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Unable to retrieve image',
            textScaleFactor: 1.0,
          ),
          backgroundColor: kWarningColor,
        ),
      );
    });
  }

  Future<void> pickImage() async {
    try {
      final List<XFile>? pickedFileList = await ImagePicker().pickMultiImage();
      if (pickedFileList!.isEmpty) return;

      for (var i = 0; i < pickedFileList.length; i++) {
        ImageProperties properties =
            await FlutterNativeImage.getImageProperties(pickedFileList[i].path);

        //Crop to square before saving
        //Unlike the cropping for the camera feature, this cropping will
        //crop to center instead, as most objects are often focused in the center of images.

        int width = properties.width!;
        int height = properties.height!;
        int offset = ((width - height).abs() / 2).round();
        File croppedFile = await FlutterNativeImage.cropImage(
            pickedFileList[i].path,
            (width > height) ? offset : 0, //Crops to center of image
            (width > height) ? 0 : offset,
            (width > height) ? height : width,
            (width > height) ? height : width);
        if (mounted) {
          setState(() {
            widget.imgCollection.add(croppedFile.path);
          });
        }
      }
    } on PlatformException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to pick image $e',
            textScaleFactor: 1.0,
          ),
          backgroundColor: kWarningColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Body(
        imgCollection: widget.imgCollection,
        headerTitle: widget.screenHeader,
      ),
      floatingActionButton: Container(
        margin: EdgeInsets.only(
            left: kDisplayWidth(context) * 0.12,
            right: kDisplayWidth(context) * 0.035),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            GestureDetector(
                onTap: (widget.screenHeader == "Captured Images")
                    ? () {
                        Navigator.of(context).pop();
                      }
                    : () async {
                        try {
                          await pickImage();
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
                      },
                child: Container(
                  padding: EdgeInsets.only(
                      left: kDefaultPadding * 0.85,
                      right: kDefaultPadding * 0.65),
                  height: kDisplayWidth(context) * 0.17,
                  width: kDisplayWidth(context) * 0.17,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(35),
                      color: kWhite,
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            offset: Offset(0, 3),
                            blurRadius: 6)
                      ]),
                  child: SvgPicture.asset(widget.asset, color: kTextColor),
                )),
            Spacer(),
            GestureDetector(
                onTap: () async {
                  if (widget.imgCollection.isEmpty) {
                    showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (BuildContext context) => AlertDialog(
                              content: Container(
                                padding: EdgeInsets.all(kDefaultPadding * 0.3),
                                child: Text(
                                  (widget.screenHeader == "Captured Images")
                                      ? 'Please capture at least one image.'
                                      : 'Please upload at least one image.',
                                  textScaleFactor: 1.0,
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                              ),
                              actions: [
                                TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Text('OK',
                                        textScaleFactor: 1.0,
                                        style: TextStyle(color: kPrimaryColor)))
                              ],
                            ));
                  } else {
                    showCustomDialog(
                      context,
                      "loading",
                      "Processing your images",
                    );
                    await multiUpload(widget.imgCollection,
                        _auth.currentUser!.uid, context, mounted);
                    await getIngredientUrl();
                    if (!mounted) return;
                    var modelPredictions =
                        await getPredictions(storageUrls, context, mounted);
                    if (modelPredictions.isNotEmpty && mounted) {
                      setState(() {
                        predictions = modelPredictions;
                      });
                      Navigator.of(context).pop(); //remove dialog box
                      await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => IngredientsScreen(
                              predictions: predictions,
                              storageUrls: storageUrls),
                        ),
                      );
                    }
                  }
                },
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: kDefaultPadding * 1.2),
                  height: kDisplayHeight(context) * 0.07,
                  width: kDisplayWidth(context) * 0.38,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(35),
                      color: kPrimaryColor,
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            offset: Offset(0, 3),
                            blurRadius: 6)
                      ]),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Continue',
                          textScaleFactor: 1.0,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium!
                              .copyWith(fontWeight: FontWeight.w500)),
                      Icon(
                        CupertinoIcons.right_chevron,
                        color: kTextColor,
                      )
                    ],
                  ),
                ))
          ],
        ),
      ),
    );
  }
}
