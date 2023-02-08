import 'dart:io';
import 'package:cooktime/Screens/ImageDisplay/ImageDisplayScreen.dart';
import 'package:camera/camera.dart';
import 'package:cooktime/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_image/flutter_native_image.dart';

class Body extends StatefulWidget {
  const Body({Key? key, required this.camera}) : super(key: key);

  final CameraDescription camera;

  @override
  State<Body> createState() => _BodyState();
}

class _BodyState extends State<Body> {
  //late initializer - handy when initialization is costly and may not be needed
  //enforces the variable's contraints at runtime instead of at compile time
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  var imgCollection = [];
  bool flashAlways = false;
  bool flashAuto = false;
  bool flashOff = true;
  bool isLoading = true;
  bool isPicLoading = false;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(widget.camera, ResolutionPreset.medium,
        enableAudio: false);
    initializeController(_controller);
  }

  Future<void> initializeController(_controller) async {
    if (mounted) {
      setState(() {
        isLoading = true;
      });
    }
    _initializeControllerFuture = _controller.initialize().then((_) async {
      if (mounted) {
        _controller.lockCaptureOrientation();
        await setFlashMode(FlashMode.off);
        setState(() {
          flashOff = true;
          flashAlways = false;
          flashAuto = false;
          isLoading = false;
        });
      }
    }).catchError((Object e) {
      if (e is CameraException) {
        switch (e.code) {
          case 'CameraAccessDenied':
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  e.code,
                  textScaleFactor: 1.0,
                ),
                backgroundColor: kWarningColor,
              ),
            );
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Camera access denied. Enable access in Settings.',
                  textScaleFactor: 1.0,
                ),
                backgroundColor: kWarningColor,
              ),
            );
            break;
          case 'CameraAccessDeniedWithoutPrompt':
            //for iOS when user had previously denied permission. iOS does not allow prompting a second time.
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  e.code,
                  textScaleFactor: 1.0,
                ),
                backgroundColor: kWarningColor,
              ),
            );
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Camera access denied. Go to Settings > Privacy > Camera.',
                  textScaleFactor: 1.0,
                ),
                backgroundColor: kWarningColor,
              ),
            );
            break;
          default:
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  e.code,
                  textScaleFactor: 1.0,
                ),
                backgroundColor: kWarningColor,
              ),
            );
            break;
        }
      }
    });
  }

  Future<void> setFlashMode(FlashMode mode) async {
    try {
      await _controller.setFlashMode(mode);
    } on CameraException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Unable to set flash mode',
            textScaleFactor: 1.0,
          ),
          backgroundColor: kWarningColor,
        ),
      );
      rethrow;
    }
  }

  void onSetFlashModeButtonPressed(FlashMode mode) {
    switch (mode) {
      case FlashMode.off:
        setFlashMode(FlashMode.always).then((_) {
          if (!mounted) return;
          setState(() {
            flashAlways = true;
            flashOff = false;
            flashAuto = false;
          });
        });
        break;
      case FlashMode.always:
        setFlashMode(FlashMode.auto).then((_) {
          if (!mounted) return;
          setState(() {
            flashAuto = true;
            flashAlways = false;
            flashOff = false;
          });
        });
        break;
      case FlashMode.auto:
        setFlashMode(FlashMode.off).then((_) {
          if (!mounted) return;
          setState(() {
            flashOff = true;
            flashAuto = false;
            flashAlways = false;
          });
        });
        break;
      default:
        setFlashMode(FlashMode.off).then((_) {
          if (!mounted) return;
          setState(() {
            flashOff = true;
            flashAuto = false;
            flashAlways = false;
          });
        });
        break;
    }
  }

  takePicture(controller) async {
    //Crop image to be 1:1 and save to collection
    try {
      if (mounted) {
        setState(() {
          isPicLoading = true;
        });
      }
      final img = await controller.takePicture();

      ImageProperties properties =
          await FlutterNativeImage.getImageProperties(img.path);

      File croppedFile = await FlutterNativeImage.cropImage(
          img.path, 0, 0, properties.height!, properties.height!);
      if (mounted) {
        setState(() {
          imgCollection.add(croppedFile.path);
          isPicLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        isPicLoading = false;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '$e',
              textScaleFactor: 1.0,
            ),
            backgroundColor: kWarningColor,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    //dispose the controller when the widget is disposed
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: kDisplayHeight_WoTool(context),
      width: kDisplayWidth(context),
      child: (isLoading)
          ? Container(
              height: kDisplayHeight_WoTool(context),
              color: Colors.black,
              alignment: Alignment.center,
              child: SizedBox(
                height: kDisplayWidth(context) * 0.2,
                width: kDisplayWidth(context) * 0.2,
                child: CircularProgressIndicator(
                  color: kSecondaryColor,
                ),
              ))
          : Column(
              children: [
                FutureBuilder<void>(
                  future: _initializeControllerFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      return ClipRect(
                          //Preview camera to be 1:1
                          child: SizedOverflowBox(
                        alignment: Alignment.topCenter,
                        size: Size(
                            kDisplayWidth(context), kDisplayWidth(context)),
                        child: CameraPreview(_controller),
                      ));
                    } else {
                      return const Center(
                          child: CircularProgressIndicator(
                        color: kSecondaryColor,
                      ));
                    }
                  },
                ),
                Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      margin: EdgeInsets.all(kDefaultPadding * 1.5),
                      width: kDisplayWidth(context) * 0.1,
                      height: kDisplayWidth(context) * 0.1,
                      decoration: BoxDecoration(
                        border:
                            Border.all(color: Colors.grey.shade400, width: 1.3),
                        shape: BoxShape.circle,
                      ),
                      child: GestureDetector(
                          child: Icon(
                            flashOff
                                ? Icons.flash_off_rounded
                                : (flashAlways
                                    ? Icons.flash_on_rounded
                                    : Icons.flash_auto_rounded),
                            color: kWhite,
                          ),
                          onTap: () {
                            onSetFlashModeButtonPressed(
                                _controller.value.flashMode);
                          }),
                    ),
                    (isPicLoading)
                        ? Container(
                            margin: EdgeInsets.all(kDefaultPadding * 1.5),
                            width: kDisplayWidth(context) * 0.15,
                            height: kDisplayWidth(context) * 0.15,
                            child: CircularProgressIndicator(
                              color: kSecondaryColor,
                            ),
                          )
                        : Container(
                            //take picture button
                            margin: EdgeInsets.all(kDefaultPadding * 1.5),
                            width: kDisplayWidth(context) * 0.15,
                            height: kDisplayWidth(context) * 0.15,
                            child: Ink(
                              decoration: BoxDecoration(
                                border: Border.all(color: kWhite, width: 2.7),
                                color: kWhite,
                                shape: BoxShape.circle,
                              ),
                              child: Ink(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color: Colors.black, width: 2.2),
                                  shape: BoxShape.circle,
                                ),
                                child: InkWell(
                                  onTap: () async {
                                    await takePicture(_controller);
                                  },
                                ),
                              ),
                            )),
                    Container(
                      margin: EdgeInsets.all(kDefaultPadding * 1.5),
                      width: kDisplayWidth(context) * 0.12,
                      height: kDisplayWidth(context) * 0.12,
                      decoration: BoxDecoration(
                          border: Border.all(color: kWhite, width: 1),
                          borderRadius: BorderRadius.circular(5)),
                      child: GestureDetector(
                          onTap: imgCollection.isEmpty
                              ? () {} //if empty, do not allow to proceed to next screen
                              : () async {
                                  if (!mounted) return;
                                  await Navigator.of(context)
                                      .push(MaterialPageRoute(
                                          builder: (context) =>
                                              ImageDisplayScreen(
                                                imgCollection: imgCollection,
                                                screenHeader: "Captured Images",
                                                asset:
                                                    'assets/icons/camera-add.svg',
                                              )))
                                      .then((_) {
                                    if (mounted) {
                                      setState(() {
                                        imgCollection = imgCollection;
                                      });
                                    }
                                  });
                                },
                          child: imgCollection.isEmpty
                              ? null
                              : Image.file(File(
                                  imgCollection[imgCollection.length - 1]))),
                    ),
                  ],
                ),
              ],
            ),
    );
  }
}
