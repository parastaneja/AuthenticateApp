import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:profile_details/controllers/navigation_controller.dart';
import 'package:profile_details/controllers/providers/user_provider.dart';
import 'package:profile_details/screens/authentication/login_screen.dart';
import 'package:profile_details/utils/my_print.dart';
import 'package:profile_details/utils/snakbar.dart';
import 'package:provider/provider.dart';

//To Perform Authentication Operations
class AuthenticationController {
  static AuthenticationController? _instance;

  factory AuthenticationController() {
    _instance ??= AuthenticationController._();
    return _instance!;
  }

  AuthenticationController._();

  //To Check if User is Login
  //This Method will Check if User is Login and if login and initializeUserid is True then it will Store User data in UserProvider
  //It will Return true or false
  Future<bool> isUserLogin({bool initializeUserid = false, BuildContext? context}) async {
    User? user = FirebaseAuth.instance.currentUser;
    bool isLogin = user != null;
    if(isLogin && initializeUserid && context != null) {
      UserProvider userProvider = Provider.of<UserProvider>(context, listen: false);
      userProvider.userid = user.uid;
      userProvider.firebaseUser = user;
      //clientProvider.clientId = "CI008";
      userProvider.firebaseUser = user;
    }
    MyPrint.printOnConsole("Login:$isLogin");
    return isLogin;
  }

  //Will Sing in with google
  //If Sign in success, will return User Object else return null
  Future<User?> signInWithGoogle(BuildContext context) async {
    GoogleSignInAccount? googleSignInAccount;

    try {
      googleSignInAccount = await GoogleSignIn().signIn();
    }
    catch(e) {
      MyPrint.printOnConsole("Error in Google Sign In:$e");
      return null;
    }

    if (googleSignInAccount != null) {
      final GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      try {
        UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);

        return userCredential.user!;
      }
      on FirebaseAuthException catch (e) {
        String message = "";

        MyPrint.printOnConsole("Code:${e.code}");
        switch (e.code) {
          case "account-exists-with-different-credential" :
            {
              List<String> methods = await FirebaseAuth.instance.fetchSignInMethodsForEmail(e.email!);
              MyPrint.printOnConsole("Methods:$methods");

              MyPrint.printOnConsole("Message:Account Already Exist With Different Method");
              Snakbar().show_error_snakbar(context, "Account Already Exist With Different Method");
            }
            break;

          case "invalid-credential" :
            {
              message = "Credential is Invalid";
              MyPrint.printOnConsole("Message:Invalid Credentials");
              Snakbar().show_error_snakbar(context, "Invalid Credentials");
            }
            break;

          case "operation-not-allowed" :
            {
              MyPrint.printOnConsole("Message:${e.message}");
              Snakbar().show_error_snakbar(context, "${e.message}");
            }
            break;

          case "user-disabled" :
            {
              MyPrint.printOnConsole("Message:${e.message}");
              Snakbar().show_error_snakbar(context, "${e.message}");
            }
            break;

          case "user-not-found" :
            {
              MyPrint.printOnConsole("Message:${e.message}");
              Snakbar().show_error_snakbar(context, "${e.message}");
            }
            break;

          case "wrong-password" :
            {
              MyPrint.printOnConsole("Message:${e.message}");
              Snakbar().show_error_snakbar(context, "${e.message}");
            }
            break;

          default :
            {
              message = "Error in Authentication";
              MyPrint.printOnConsole("Message:${e.message}");
              Snakbar().show_error_snakbar(context, "${e.message}");
            }
        }
      }

      return null;
    }
  }

  //This Method Returns a list of two bool,
  //First is "isEmailValid", which means if entered email is valid for email authentication
  //Second is "isEmailExist", which means if entered email is already exist in firebase authentication
  Future<List<bool>> isEmailValidAndExistInFirebaseAuthForEmailAuthentication(BuildContext context, String email) async {
    bool isEmailValid = false, isEmailExist = false;

    try {
      List<String> methods = await FirebaseAuth.instance.fetchSignInMethodsForEmail(email);
      MyPrint.printOnConsole("Methods:${methods}");

      if(methods.isNotEmpty) {
        if(methods.contains("password")) {
          isEmailValid = true;
          isEmailExist = true;
        }
        else {
          String method = "";
          if(methods[0] == "google.com") method = "Google Sign In";
          else if(methods[0] == "facebook.com") method = "Facebook";
          Snakbar().show_info_snakbar(context, "This Email is Created with ${method}\nSo Login With $method");
        }
      }
      else {
        isEmailValid = true;
        isEmailExist = false;
      }
    }
    on FirebaseAuthException catch(e) {
      // String message = "";

      MyPrint.printOnConsole("Code:${e.code}");
      switch(e.code) {
        case "invalid-email" : {
          MyPrint.printOnConsole("Message:Entered Email is Invalid");
          Snakbar().show_error_snakbar(context, "Entered Email is Invalid");
        }
        break;

        default : {
          MyPrint.printOnConsole("Message:Error in Authentication");
          Snakbar().show_error_snakbar(context, "Error in Authentication");
        }
      }
    }
    catch(e) {
      MyPrint.printOnConsole("Error in AuthenticationController().isEmailValidAndExistInFirebaseAuthForEmailAuthentication():${e}");
      Snakbar().show_error_snakbar(context, "Error in Authentication");
    }

    return [isEmailValid, isEmailExist];
  }

  Future<User?> createAccountWithEmailAndPassword(BuildContext context, {required String email, required String password}) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
      if(userCredential.user != null && !userCredential.user!.emailVerified) {
        await userCredential.user!.sendEmailVerification();
      }

      return userCredential.user;
    }
    on FirebaseAuthException catch(e) {
      MyPrint.printOnConsole("Code:${e.code}");
      MyPrint.printOnConsole("Error in Create User with Email and Password:${e.message}");
      Snakbar().show_error_snakbar(context, "Error in Email Account Creation:${e.message}");
    }
    catch(e, s) {
      MyPrint.printOnConsole("Error in createAccountWithEmailAndPassword:$e");
      MyPrint.printOnConsole(s);
      Snakbar().show_error_snakbar(context, "Error in Email Account Creation:$e");
    }
  }

  //This Method will take email and password as parameter and sign user in
  //If Sign in Success, will return user object else return null
  //If user not exist then will create new user
  Future<User?> signInWithEmailAndPassword(BuildContext context, {required String email, required String password}) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
      return userCredential.user;
    }
    on FirebaseAuthException catch(e) {
      // String message = "";

      MyPrint.printOnConsole("Code:${e.code}");
      switch(e.code) {
        case "invalid-email" : {

          MyPrint.printOnConsole("Message:Entered Email is Invalid");
          Snakbar().show_error_snakbar(context, "Entered Email is Invalid");

        }
        break;

        case "user-disabled" : {

          MyPrint.printOnConsole("Message:Entered Email is Disabled");
          Snakbar().show_info_snakbar(context, "Entered Email is Disabled");

        }
        break;

        case "user-not-found" : {
          //message = "Entered Email doesn't exist";
          MyPrint.printOnConsole("Message:Email Doens't ");
          Snakbar().show_error_snakbar(context, "Email Doens't Exist");
        }
        break;

        case "wrong-password" : {
          MyPrint.printOnConsole("Message:Entered Password is wrong");
          Snakbar().show_error_snakbar(context, "Entered Password is wrong");
        }
        break;
        default : {
          MyPrint.printOnConsole("Message:Error in Authentication");
          Snakbar().show_error_snakbar(context, "Error in Authentication");

        }
      }
    }

    return null;
  }

  Future<bool> sendPasswordResetMail(BuildContext context, String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      return true;
    }
    on FirebaseAuthException catch(e, s) {
      // String message = "";

      MyPrint.printOnConsole("Code:${e.code}");
      switch (e.code) {
        case "invalid-email" :
          {
            MyPrint.printOnConsole("Message:Entered Email is Invalid");
            Snakbar().show_error_snakbar(context,"Entered Email is Invalid");
            // MyToast.showError(message, context);
          }
          break;

        case "missing-android-pkg-name" :
          {
            MyPrint.printOnConsole("Message:Package Name is Missing");
            Snakbar().show_error_snakbar(context,"Package Name is Missing");
            //MyToast.showError(message, context);
          }
          break;

        case "missing-continue-uri" :
          {
            MyPrint.printOnConsole("Message:Missing Continue Url");
            Snakbar().show_error_snakbar(context,"Missing Continue Url");
            //MyToast.showError(message, context);
          }
          break;

        case "invalid-continue-uri" :
          {
            MyPrint.printOnConsole("Message:Invalid Continue Url");
            Snakbar().show_info_snakbar(context, "Invalid Continue Url");

          }
          break;

        case "unauthorized-continue-uri" :
          {
            MyPrint.printOnConsole("Message:Unauthorized Continue Url");
            Snakbar().show_error_snakbar(context, "Unauthorized Continue Url");
            //MyToast.showError(message, context);
          }
          break;

        case "user-not-found" :
          {
            MyPrint.printOnConsole("Message:Email Not Exist");
            Snakbar().show_error_snakbar(context, "Email Not Exist");
            //MyToast.showError(message, context);
          }
          break;

        default :
          {
            MyPrint.printOnConsole("Message:${e.message}");
            Snakbar().show_error_snakbar(context, "Error in Sending Password Reset Link");
           // MyToast.showError(message, context);
          }
      }
    }

    return false;
  }

  //Will logout from system and remove data from UserProvider and local memory
  Future<bool> logout({BuildContext? context, bool isNavigateToLoginScreen = true}) async {
    UserProvider userProvider = Provider.of<UserProvider>(NavigationController.mainAppKey.currentContext!, listen: false);
    userProvider.firebaseUser = null;
    userProvider.userModel = null;
    userProvider.userid = "";

    await FirebaseAuth.instance.signOut();
    await GoogleSignIn().signOut();

    if(context != null && isNavigateToLoginScreen) {
      Navigator.pushNamedAndRemoveUntil(context, LoginScreen.routeName, (_) => false);
    }

    return true;
  }
}
