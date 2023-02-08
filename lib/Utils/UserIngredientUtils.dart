import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cooktime/Utils/CustomDialogUtils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import '../constants.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

final _auth = FirebaseAuth.instance;
final userIngredientDoc = FirebaseFirestore.instance
    .collection('UserIngredients')
    .doc(_auth.currentUser!.uid);

Future getPredictions(storageUrls, context, mounted) async {
  List modelPredictions = [];
  for (var i = 0; i < storageUrls.length; i++) {
    var url =
        "https://lisachea.xyz/cooktime/classifier/model?imgUrl=${storageUrls[i]}";
    try {
      final res = await http.get(Uri.parse(url));
      if (res.body.isNotEmpty) {
        final prediction = jsonDecode(res.body);
        modelPredictions.add(prediction);
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop(); //remove dialog box
      showCustomDialog(context, "", "Unable to fetch data");
    }
  }
  return modelPredictions;
}

Future<void> deleteDoc(context, mounted) async {
  try {
    await userIngredientDoc.delete();
  } catch (e) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Unable to delete UserIngredient doc $e',
          textScaleFactor: 1.0,
        ),
        backgroundColor: kWarningColor,
      ),
    );
  }
}

Future multiUpload(List imgList, String userId, context, mounted) async {
  List storageUrls = [];
  for (var i = 0; i < imgList.length; i++) {
    var url = await uploadFile(File(imgList[i]), userId, context, mounted);
    storageUrls.add(url);
  }

  try {
    //for recovery purpose - there can only be one instance of ingredient list at a time
    await userIngredientDoc.set({
      'userid': _auth.currentUser!.uid,
      'storageUrls': storageUrls,
    });
  } catch (e) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Unable to upload ingredients to user doc $e',
          textScaleFactor: 1.0,
        ),
        backgroundColor: kWarningColor,
      ),
    );
  }
}

Future uploadFile(File img, String userId, context, mounted) async {
  final fileType = img.path.split('.');
  final dateTime = DateTime.now()
      .toString()
      .replaceAll('.', '')
      .replaceAll(':', '')
      .replaceAll(' ', ''); //to ensure valid file name
  final storageReference = FirebaseStorage.instance
      .ref()
      .child('$userId-$dateTime.${fileType.last}');
  try {
    await storageReference.putFile(img);
    var url = await storageReference
        .getDownloadURL(); //generating a downloadURL is fine here as it is not sensitive data
    return url;
  } on FirebaseException catch (e) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Unable to upload image to cloud',
          textScaleFactor: 1.0,
        ),
        backgroundColor: kWarningColor,
      ),
    );
  }
}
