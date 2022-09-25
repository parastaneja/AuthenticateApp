import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:profile_details/screens/authentication/login_screen.dart';
import 'package:profile_details/screens/authentication/registration_screen.dart';
import 'package:profile_details/screens/home_screen/edit_profile_screen.dart';
import 'package:profile_details/screens/home_screen/main_page.dart';
import 'package:profile_details/splash_screen.dart';
import 'package:profile_details/utils/my_print.dart';

class NavigationController {
  static GlobalKey<NavigatorState> mainAppKey = GlobalKey<NavigatorState>();

  Route? onGeneratedRoutes(RouteSettings routeSettings) {
    MyPrint.printOnConsole("OnGeneratedRoutes Called for ${routeSettings.name} with arguments:${routeSettings.arguments}");

    Widget? widget;

    switch(routeSettings.name) {
      case SplashScreen.routeName : {
        widget = const SplashScreen();
        break;
      }
      case LoginScreen.routeName : {
        widget = const LoginScreen();
        break;
      }
      case RegistrationScreen.routeName : {
        widget = const RegistrationScreen();
        break;
      }
      case MainPage.routeName : {
        widget = const MainPage();
        break;
      }
      case EditProfileScreen.routeName : {
        widget = const EditProfileScreen();
        break;
      }
      default : {
        widget = const SplashScreen();
      }
    }

    if(widget != null)return MaterialPageRoute(builder: (_) => widget!);
  }
}