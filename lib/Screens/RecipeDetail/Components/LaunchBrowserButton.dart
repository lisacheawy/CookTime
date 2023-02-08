import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../constants.dart';

class LaunchBrowserButton extends StatefulWidget {
  const LaunchBrowserButton({Key? key, required this.recipeLink})
      : super(key: key);

  final String recipeLink;

  @override
  State<LaunchBrowserButton> createState() => _LaunchBrowserButtonState();
}

class _LaunchBrowserButtonState extends State<LaunchBrowserButton> {
  Future<void> launchInBrowser(String link) async {
    if (!await launchUrl(
      Uri.parse(link),
      mode: LaunchMode.externalApplication,
    )) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to launch $link',
            textScaleFactor: 1.0,
          ),
          backgroundColor: kWarningColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await launchInBrowser(widget.recipeLink);
      },
      child: Container(
        margin: EdgeInsets.symmetric(
          vertical: kDisplayWidth(context) * 0.05,
        ),
        width: kDisplayWidth(context) * 0.42,
        height: kDisplayWidth(context) * 0.1,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: kSecondaryColor,
              width: 1.5,
            )),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "View full recipe",
              textScaleFactor: 1.0,
              style: TextStyle(color: kSecondaryColor),
            ),
            Container(
                margin: EdgeInsets.only(left: 5),
                child: Icon(
                  Icons.add_to_home_screen_rounded,
                  color: kSecondaryColor,
                ))
          ],
        ),
      ),
    );
  }
}
