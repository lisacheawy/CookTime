import 'package:flutter/material.dart';
import '../../../constants.dart';

class LabeledRadio extends StatelessWidget {
  const LabeledRadio({
    super.key,
    required this.label,
    required this.groupValue,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final String groupValue;
  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (value != groupValue) {
          onChanged(value);
        }
      },
      child: Padding(
          padding: EdgeInsets.all(0),
          child: Theme(
            data: ThemeData(
              unselectedWidgetColor: kSecondaryColor,
            ),
            child: Row(
              children: <Widget>[
                Radio<String>(
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  activeColor: kPrimaryColor,
                  groupValue: groupValue,
                  value: value,
                  onChanged: (value) {
                    onChanged(value!);
                  },
                ),
                Text(label, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          )),
    );
  }
}
