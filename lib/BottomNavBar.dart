import 'package:cooktime/Provider/BottomNavigationBarProvider.dart';
import 'package:cooktime/Screens/Account/AccountScreen.dart';
import 'package:cooktime/Screens/Auth/SignUp/SignUpScreen.dart';
import 'package:cooktime/Screens/Capture/CaptureScreen.dart';
import 'package:cooktime/constants.dart';
import 'package:cooktime/Screens/Home/HomeScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({Key? key}) : super(key: key);

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  var currentScreen = [HomeScreen(), CaptureScreen(), AccountScreen()];

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<BottomNavigationBarProvider>(context);
    return Scaffold(
      body: currentScreen[provider.currentIndex],
      bottomNavigationBar: SizedBox(
        height: kDisplayHeight(context) * 0.085,
        child: BottomNavigationBar(
            backgroundColor: Colors.white,
            selectedItemColor: kPrimaryColor,
            unselectedItemColor: kSecondaryColor,
            selectedFontSize: 12,
            unselectedFontSize: 12,
            type: BottomNavigationBarType.fixed,
            currentIndex: provider.currentIndex,
            onTap: (index) {
              provider.currentIndex = index;
            },
            items: [
              BottomNavigationBarItem(
                  //Home
                  icon: Padding(
                      padding: EdgeInsets.all(kDefaultPadding / 4),
                      child: SvgPicture.asset('assets/icons/home.svg',
                          height: kDisplayWidth(context) * 0.05)),
                  activeIcon: Padding(
                    padding: EdgeInsets.all(kDefaultPadding / 4),
                    child: SvgPicture.asset('assets/icons/home-filled.svg',
                        height: kDisplayWidth(context) * 0.05),
                  ),
                  label: 'Home'),
              BottomNavigationBarItem(
                  //Capture
                  icon: Padding(
                      padding: EdgeInsets.all(kDefaultPadding / 2.5),
                      child: SvgPicture.asset('assets/icons/camera.svg',
                          height: kDisplayWidth(context) * 0.05)),
                  activeIcon: Padding(
                    padding: EdgeInsets.all(kDefaultPadding / 2.5),
                    child: SvgPicture.asset('assets/icons/camera-filled.svg',
                        height: kDisplayWidth(context) * 0.05),
                  ),
                  label: 'Capture'),
              BottomNavigationBarItem(
                  //Account
                  icon: Padding(
                      padding: EdgeInsets.all(kDefaultPadding / 4),
                      child: SvgPicture.asset('assets/icons/account.svg',
                          height: kDisplayWidth(context) * 0.05)),
                  activeIcon: Padding(
                    padding: EdgeInsets.all(kDefaultPadding / 4),
                    child: SvgPicture.asset('assets/icons/account-filled.svg',
                        height: kDisplayWidth(context) * 0.05),
                  ),
                  label: 'Account'),
            ]),
      ),
    );
  }
}
