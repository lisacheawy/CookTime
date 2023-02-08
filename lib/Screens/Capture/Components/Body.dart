import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cooktime/Screens/Capture/Components/Background.dart';
import 'package:cooktime/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import '../../../Utils/CustomDialogUtils.dart';
import '../../../Utils/UserIngredientUtils.dart';
import '../../ImageDisplay/ImageDisplayScreen.dart';
import '../../Ingredients/IngredientsScreen.dart';
import '../../KeyboardInput/KeyboardInputScreen.dart';
import '../../TakePicture/TakePictureScreen.dart';
import 'TextArea.dart';

class Body extends StatefulWidget {
  const Body({Key? key}) : super(key: key);

  @override
  State<Body> createState() => _BodyState();
}

class _BodyState extends State<Body> {
  final _auth = FirebaseAuth.instance;
  var imageFileList = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    checkUserIngredient();
  }

  Future<void> checkUserIngredient() async {
    //recovery in the event of app crash after uploading to storage
    final userDoc = FirebaseFirestore.instance
        .collection('UserIngredients')
        .doc(_auth.currentUser!.uid);
    await userDoc.get().then((DocumentSnapshot doc) {
      if (!doc.exists) return;
      final data = doc.data() as Map<String, dynamic>;
      final storageUrls = data["storageUrls"];
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext ctx) => AlertDialog(
                content: Container(
                  padding: EdgeInsets.all(kDefaultPadding * 0.3),
                  child: Text(
                    'Continue where you left off?',
                    textScaleFactor: 1.0,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
                actions: [
                  TextButton(
                      onPressed: () async {
                        await deleteDoc(context, mounted);
                        if (!mounted) return;
                        Navigator.of(context).pop();
                      },
                      child: Text('No',
                          textScaleFactor: 1.0,
                          style: TextStyle(color: kSecondaryColor))),
                  TextButton(
                      onPressed: () async {
                        if (!mounted) return;
                        Navigator.of(context).pop();
                        showCustomDialog(
                            context, "loading", "Processing your images");
                        var modelPredictions =
                            await getPredictions(storageUrls, context, mounted);
                        if (modelPredictions.isNotEmpty && mounted) {
                          Navigator.of(context).pop(); //remove dialog box
                          await Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (context) => IngredientsScreen(
                                      predictions: modelPredictions,
                                      storageUrls: storageUrls,
                                    )),
                          );
                        }
                      },
                      child: Text('OK',
                          textScaleFactor: 1.0,
                          style: TextStyle(color: kPrimaryColor))),
                ],
              ));
    }, onError: (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Unable to connect to Firebase',
            textScaleFactor: 1.0,
          ),
          backgroundColor: kWarningColor,
        ),
      );
    });
  }

  void clearCollection() {
    if (mounted) {
      setState(() {
        imageFileList.clear();
      });
    }
  }

  Future<void> pickImage() async {
    try {
      if (mounted) {
        setState(() {
          isLoading = true;
        });
      }
      final List<XFile>? pickedFileList = await ImagePicker().pickMultiImage();
      if (pickedFileList == null && mounted) {
        setState(() {
          isLoading = false;
        });
        return;
      }

      for (var i = 0; i < pickedFileList!.length; i++) {
        ImageProperties properties =
            await FlutterNativeImage.getImageProperties(pickedFileList[i].path);
        //Crop to square before saving
        //Unlike the cropping for the camera feature, this cropping will
        //crop to center instead, as most objects are often focused in the center of images.
        int width = properties.width!;
        int height = properties.height!;
        try {
          //landscape image
          await FlutterNativeImage.cropImage(
                  pickedFileList[i].path,
                  width > height ? ((width - height).abs() / 2).round() : 0,
                  //Crops to center of image
                  width > height ? 0 : ((width - height).abs() / 2).round(),
                  width > height ? height : width,
                  width > height ? height : width)
              .then((croppedFile) => {
                    if (mounted)
                      {
                        setState(() {
                          imageFileList.add(croppedFile.path);
                        })
                      }
                  });
        } on PlatformException {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "Unable to crop ${pickedFileList[i].path.split('/').last}",
                textScaleFactor: 1.0,
              ),
              backgroundColor: kWarningColor,
            ),
          );
        }
      }

      if (!mounted) return;
      await Navigator.of(context)
          .push(
        MaterialPageRoute(
          builder: (context) => ImageDisplayScreen(
            imgCollection: imageFileList,
            screenHeader: "Uploaded Images",
            asset: 'assets/icons/upload-add.svg',
          ),
        ),
      )
          .then((_) {
        if (mounted) {
          setState(() {
            isLoading = false;
          });
          clearCollection();
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
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
  Widget build(BuildContext context) {
    return SizedBox(
      height: kDisplayHeight(context),
      child: Stack(children: [
        background(
          withPan: true,
        ),
        TextArea(
            headline: 'Ready to cook?',
            desc:
                "Select how you would like to input your ingredients, and we'll show you some recipes.",
            warning:
                'Ensure that ingredients are individually captured or uploaded'),
        Positioned.fill(
          top: kDisplayHeight(context) * 0.23,
          child: Align(
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  InputButton(
                      margin: 0.04,
                      onTap: () async {
                        try {
                          await availableCameras().then((cameras) async {
                            if (!mounted) return;
                            await Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) =>
                                    TakePictureScreen(camera: cameras.first)));
                          });
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
                      asset: 'assets/icons/camera-filled.svg',
                      title: 'Capture from camera'),
                  InputButton(
                      margin: 0.05,
                      onTap: () async {
                        await pickImage();
                      },
                      asset: 'assets/icons/upload.svg',
                      title: 'Upload from gallery'),
                  InputButton(
                      margin: 0.12,
                      onTap: () async {
                        if (!mounted) return;
                        await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => KeyboardInputScreen()));
                      },
                      asset: 'assets/icons/keyboard.svg',
                      title: 'Keyboard input'),
                ],
              )),
        ),
        if (isLoading)
          Container(
              height: kDisplayHeight(context),
              color: kWhite.withOpacity(0.9),
              child: Align(
                alignment: Alignment.center,
                child: CircularProgressIndicator(
                  color: kSecondaryColor,
                ),
              )),
      ]),
    );
  }
}

class InputButton extends StatelessWidget {
  const InputButton({
    Key? key,
    required this.onTap,
    required this.asset,
    required this.title,
    required this.margin,
  }) : super(key: key);

  final VoidCallback onTap;
  final String asset;
  final String title;
  final double margin;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: kDisplayHeight(context) * 0.015),
        height: kDisplayHeight(context) * 0.065,
        width: kDisplayWidth(context) * 0.7,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            color: kPrimaryColor,
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  offset: Offset(0, 3),
                  blurRadius: 6)
            ]),
        child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
          return Row(
            children: [
              Container(
                margin: EdgeInsets.symmetric(horizontal: kDefaultPadding * 0.6),
                padding: EdgeInsets.all(kDefaultPadding * 0.35),
                height: constraints.maxWidth * 0.13,
                width: constraints.maxWidth * 0.13,
                decoration:
                    BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: SvgPicture.asset(
                  asset,
                  color: kTextColor,
                ),
              ),
              SizedBox(
                width: constraints.maxWidth * 0.7,
                child: Container(
                  margin: EdgeInsets.only(left: constraints.maxWidth * margin),
                  child: Text(
                    title,
                    textScaleFactor: 1.0,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium!
                        .copyWith(fontWeight: FontWeight.w500),
                  ),
                ),
              )
            ],
          );
        }),
      ),
    );
  }
}
