import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import '../../Utils/CustomDialogUtils.dart';

Future getRecipes(uid, ingredientList, context, mounted) async {
  const url = "https://lisachea.xyz/cooktime/fetch/recipe";
  // const url = "http://10.0.2.2:5003/cooktime/fetch/recipe";

  List results = [];
  try {
    final res = await http.post(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(
        {'uid': uid, 'ingredientList': ingredientList},
      ),
    );
    if (res.body.isNotEmpty) {
      final recipes = jsonDecode(res.body);
      results = [...recipes];
    }
  } catch (e) {
    if (!mounted) return;
    Navigator.of(context).pop(); //pop from previous dialog
    showCustomDialog(context, "", "Unable to fetch data");
  }
  return results;
}
