import 'package:flutter/material.dart';
import '../../../constants.dart';

class UserDetails extends StatelessWidget {
  const UserDetails({Key? key, required this.fullName, required this.email})
      : super(key: key);

  final String fullName;
  final String email;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: kDefaultPadding * 0.8),
      child: Column(
        children: [
          Container(
            alignment: Alignment.centerLeft,
            child: Text(fullName,
                textScaleFactor: 1.0,
                style: Theme.of(context)
                    .textTheme
                    .titleSmall!
                    .copyWith(fontSize: 18)),
          ),
          Container(
            alignment: Alignment.centerLeft,
            child: Text(email,
                textScaleFactor: 1.0,
                style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}
