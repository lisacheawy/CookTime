import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';

const kPrimaryColor = Color(0xFFFEBD2F);
const kSecondaryColor = Color(0xFFDCD4BD);
const kTextColor = Color(0xFF2A2A2A);
const kWarningColor = Color(0xFFD15D5D);
const kPositiveColor = Color(0XFF6CBB99);
const kBackgroundColor = Color(0xFFF5F3EF);
const kWhite = Color(0XFFFEFEFE);

const double kDefaultPadding = 20.0;

Size kDisplaySize(BuildContext context) {
  return MediaQuery.of(context).size;
}

double kDisplayHeight(BuildContext context) {
  return kDisplaySize(context).height;
}

double kDisplayWidth(BuildContext context) {
  return kDisplaySize(context).width;
}

//Section after toolbar
double kDisplayHeight_WoTool(BuildContext context) {
  return kDisplayHeight(context) - kToolbarHeight;
}

//Middle section between toolbar and navbar
double kDisplayHeight_WoT_Nav(BuildContext context) {
  return kDisplayHeight(context) - kToolbarHeight - kBottomNavigationBarHeight;
}

//Form validators
final requiredValidator = RequiredValidator(errorText: 'Required');

final emailValidator = MultiValidator([
  RequiredValidator(errorText: 'Required'),
  EmailValidator(errorText: 'Enter a valid email address')
]);

final passwordValidator = MultiValidator([
  RequiredValidator(errorText: 'Required'),
  MinLengthValidator(8, errorText: 'Min. 8 digits with one special character'),
  PatternValidator(r'(?=.*?[#?!@$%^&*-/])',
      errorText: 'Min. 8 digits with one special character')
]);

final signInPasswordValidator = MultiValidator([
  RequiredValidator(errorText: 'Required'),
  MinLengthValidator(8, errorText: 'Incorrect password'),
  PatternValidator(r'(?=.*?[#?!@$%^&*-/])', errorText: 'Incorrect password')
]);

final matchValidator = MatchValidator(errorText: 'Passwords do not match');
