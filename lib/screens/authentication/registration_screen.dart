import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:profile_details/controllers/authentication_controller.dart';
import 'package:profile_details/controllers/providers/connection_provider.dart';
import 'package:profile_details/controllers/providers/user_provider.dart';
import 'package:profile_details/controllers/user_controller.dart';
import 'package:profile_details/screens/authentication/login_screen.dart';
import 'package:profile_details/screens/common/components/modal_progress_hud.dart';
import 'package:profile_details/screens/home_screen/main_page.dart';
import 'package:profile_details/utils/SizeConfig.dart';
import 'package:profile_details/utils/my_print.dart';
import 'package:profile_details/utils/snakbar.dart';
import 'package:profile_details/utils/styles.dart';
import 'package:provider/provider.dart';

import '../../models/user_model.dart';

class RegistrationScreen extends StatefulWidget {
  static const String routeName = "/RegistrationScreen";
  const RegistrationScreen({Key? key}) : super(key: key);

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  bool isFirst = true, isLoading = false;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late TextEditingController emailController, passwordController;

  void signInWithGoogle() async {
    if (isLoading) return;

    setState(() {
      isLoading = true;
    });

    User? user = await AuthenticationController().signInWithGoogle(context);

    if (user != null) {
      onSuccess(user, navigateToHomeIfExist: true);
    }
    else {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> signUpWithEmailAndPassword() async {
    if (isLoading) return;

    setState(() {
      isLoading = true;
    });

    List<bool> list = await AuthenticationController().isEmailValidAndExistInFirebaseAuthForEmailAuthentication(context, emailController.text.trim());
    bool isEmailValid = list[0];
    bool isEmailExist = list[1];
    MyPrint.printOnConsole("isEmailValid:${isEmailValid}, isEmailExist:${isEmailExist}");

    if(isEmailExist) {
      Snakbar().show_error_snakbar(context, "Email Already Exist");
      setState(() {
        isLoading = false;
      });
    }
    else {
      User? user = await AuthenticationController().createAccountWithEmailAndPassword(context, email: emailController.text.trim(), password: passwordController.text.trim());
      MyPrint.printOnConsole("User:$user");

      if (user != null) {
        onSuccess(user);
      }
      else {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> onSuccess(User user, {bool navigateToHomeIfExist = false}) async {
    MyPrint.printOnConsole("Login Screen OnSuccess called");

    UserProvider userProvider = Provider.of<UserProvider>(context, listen: false);
    userProvider.userid = user.uid;
    userProvider.firebaseUser = user;

    MyPrint.printOnConsole("Email:${user.email}");
    MyPrint.printOnConsole("Mobile:${user.phoneNumber}");

    bool isExist = await UserController().isUserExist(context, userProvider.userid);

    print("User Exist:$isExist");

    if(isExist) {
      setState(() {
        isLoading = false;
      });
      if(navigateToHomeIfExist) {
        Navigator.pushNamedAndRemoveUntil(context, MainPage.routeName, (route) => false);
      }
      else {
        AuthenticationController().logout();
        Snakbar().show_error_snakbar(context, "Account Already Exist");
      }
    }
    else {
      UserModel userModel = UserModel();
      userModel.id = user.uid;
      userModel.name = userProvider.firebaseUser?.displayName ?? "";
      userModel.mobile = userProvider.firebaseUser?.phoneNumber ?? "";
      userModel.email = userProvider.firebaseUser?.email ?? "";
      userModel.createdTime = Timestamp.now();
      bool isSuccess = await UserController().createUser(context, userModel);
      MyPrint.printOnConsole("Insert User Success:${isSuccess}");

      setState(() {
        isLoading = false;
      });

      if(isSuccess) {
        Snakbar().show_success_snakbar(context, "Registration Success");
        Navigator.pushNamedAndRemoveUntil(context, MainPage.routeName, (route) => false);
      }
      else {
        AuthenticationController().logout();
        Snakbar().show_error_snakbar(context, "Couldn't Create Account");
      }
    }
  }

  @override
  void initState() {
    emailController = TextEditingController();
    passwordController = TextEditingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    MyPrint.printOnConsole("LoginScreen called");

    MySize().init(context);

    return ModalProgressHUD(
      inAsyncCall: isLoading,
      color: Colors.black,
      progressIndicator: Container(
        padding: EdgeInsets.all(MySize.size100!),
        child: Center(
          child: Container(
            height: MySize.size90,
            width: MySize.size90,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(MySize.size10!),
              color: Colors.white,
            ),
            child: SpinKitFadingCircle(color: Styles.primaryColor,),
          ),
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Container(
          padding: EdgeInsets.only(top: 0),
          child: Column(
            children: <Widget>[
              Expanded(
                child: Center(
                  child: Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          getLogo(),
                          getRegisterText(),
                          // getLoginText2(),
                          getEmailTextField(),
                          getPasswordTextField(),
                          getContinueButton(),
                          getOrText(),
                          getRegisterWithGoogleButton(),
                          getAlreadyAUserLinkText(),
                          //getTermsAndConditionsLink(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget getLogo() {
    return Container(
      margin: EdgeInsets.only(bottom: MySize.size34!),
      width: MySize.size100!,
      height: MySize.size100!,
      child: Image.asset("assets/logo.png"),
    );
  }

  Widget getRegisterText() {
    return InkWell(
      onTap: ()async{

      },
      child: Container(
        margin: EdgeInsets.only(left: MySize.size16!, right: MySize.size16!),
        child: Center(
          child: Text(
            "Register",
            style: TextStyle(
              fontSize: MySize.size26!,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }

  Widget getLoginText2() {
    return Container(
      margin: EdgeInsets.only(left: MySize.size48!, right: MySize.size48!, top: MySize.size40!),
      child: Text(
        "Enter your login details to access your account",
        softWrap: true,
        style: TextStyle(
            fontWeight: FontWeight.w500,
            height: 1.2,
            color: Styles.onBackground.withAlpha(200)),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget getEmailTextField() {
    return Container(
      margin: EdgeInsets.only(left: MySize.size24!, right: MySize.size24!, top: 10),
      child: Container(
        decoration: BoxDecoration(
          color: Styles.background.withAlpha(100),
          borderRadius: BorderRadius.all(Radius.circular(MySize.size16!)),
          boxShadow: [
            BoxShadow(
                blurRadius: 8.0,
                color: Colors.black.withOpacity(0.4).withAlpha(25),
                offset: Offset(0, 3)),
          ],
        ),
        child: TextFormField(
          controller: emailController,
          style: const TextStyle(
            letterSpacing: 0.1,
            color: Styles.onBackground,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: "Enter Email",
            hintStyle: TextStyle(
              letterSpacing: 0.1,
              color: Styles.onBackground.withAlpha(180),
              fontWeight: FontWeight.w500,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(8.0),
              ),
              borderSide: BorderSide(color: Styles.onBackground),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(8.0),),
              borderSide: BorderSide(color: Styles.grey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(8.0),
              ),
              borderSide: BorderSide(color: Styles.grey),
            ),
            filled: true,
            fillColor: Styles.background,
            prefixIcon: Icon(
              Icons.email,
              size: 22,
              color: Styles.onBackground.withAlpha(200),
            ),
            isDense: true,
            contentPadding: EdgeInsets.all(0),
          ),
          keyboardType: TextInputType.emailAddress,
          autofocus: false,
          textCapitalization: TextCapitalization.sentences,
          validator: (val) {
            if(val == null || val.isEmpty) {
              return "Email Cannot be empty";
            }
            else {
              if (RegExp(r"^[a-zA-Z0-9+_.-]+[a-zA-Z0-9+_.-]+@[a-zA-Z0-9][a-zA-Z0-9]+\.[a-zA-Z0-9][a-zA-Z0-9]+").hasMatch(val)) {
                return null;
              }
              else {
                return "Invalid Email Address";
              }
            }
          },
          inputFormatters: [
            FilteringTextInputFormatter(" ", allow: false),
          ],
        ),
      ),
    );
  }

  Widget getPasswordTextField() {
    return Container(
      margin: EdgeInsets.only(left: MySize.size24!, right: MySize.size24!, top: 10),
      child: Container(
        decoration: BoxDecoration(
          color: Styles.background.withAlpha(100),
          borderRadius: BorderRadius.all(Radius.circular(MySize.size16!)),
          boxShadow: [
            BoxShadow(
                blurRadius: 8.0,
                color: Colors.black.withOpacity(0.4).withAlpha(25),
                offset: Offset(0, 3)),
          ],
        ),
        child: TextFormField(
          controller: passwordController,
          style: const TextStyle(
            letterSpacing: 0.1,
            color: Styles.onBackground,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: "Enter Password",
            hintStyle: TextStyle(
              letterSpacing: 0.1,
              color: Styles.onBackground.withAlpha(180),
              fontWeight: FontWeight.w500,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(8.0),
              ),
              borderSide: BorderSide(color: Styles.onBackground),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(8.0),),
              borderSide: BorderSide(color: Styles.grey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(8.0),
              ),
              borderSide: BorderSide(color: Styles.grey),
            ),
            filled: true,
            fillColor: Styles.background,
            prefixIcon: Icon(
              Icons.password,
              size: 22,
              color: Styles.onBackground.withAlpha(200),
            ),
            isDense: true,
            contentPadding: EdgeInsets.all(0),
          ),
          keyboardType: TextInputType.visiblePassword,
          autofocus: false,
          textCapitalization: TextCapitalization.sentences,
          validator: (val) {
            if(val == null || val.isEmpty) {
              return "Password Cannot be empty";
            }
            else {
              return null;
            }
          },
          inputFormatters: [
            FilteringTextInputFormatter(" ", allow: false),
          ],
        ),
      ),
    );
  }

  Widget getTermsAndConditionsLink() {
    return GestureDetector(
      onTap: () {

      },
      child: Container(
        margin: EdgeInsets.only(top: MySize.size16!),
        child: Center(
          child: Text(
            "Terms and Conditions",
            style: TextStyle(
                decoration: TextDecoration.underline),
          ),
        ),
      ),
    );
  }

  Widget getContinueButton() {
    return Container(
      margin: EdgeInsets.only(left: MySize.size24!, right: MySize.size24!, top: 10),
      decoration: BoxDecoration(
        borderRadius:
        BorderRadius.all(Radius.circular(MySize.size48!)),
      ),
      child: FlatButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(MySize.size16!)),
        color: Styles.primaryColor,
        highlightColor: Styles.primaryColor,
        splashColor: Colors.white.withAlpha(100),
        padding: EdgeInsets.only(top: MySize.size16!, bottom: MySize.size16!),
        onPressed: () {
          if(_formKey.currentState?.validate() ?? false) {
            signUpWithEmailAndPassword();
          }
        },
        child: Stack(
          // overflow: Overflow.visible,
          clipBehavior: Clip.antiAlias,
          alignment: Alignment.center,
          children: <Widget>[
            const Align(
              alignment: Alignment.center,
              child: Text(
                "CONTINUE",
                style: TextStyle(
                    color: Colors.white,
                    letterSpacing: 0.8,
                    fontWeight: FontWeight.w700),
              ),
            ),
            Positioned(
              right: 16,
              child: ClipOval(
                child: Container(
                  color: Colors.white,
                  // button color
                  child: SizedBox(
                      width: MySize.size30,
                      height: MySize.size30,
                      child: Icon(
                        Icons.arrow_forward,
                        color: Styles.primaryColor,
                        size: MySize.size18,
                      )),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget getOrText() {
    return Container(
      margin: EdgeInsets.only(left: MySize.size48!, right: MySize.size48!, top: MySize.size40!),
      child: Text(
        "Or",
        softWrap: true,
        style: TextStyle(
            fontWeight: FontWeight.w500,
            height: 1.2,
            color: Styles.onBackground.withAlpha(200)),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget getRegisterWithGoogleButton() {
    return InkWell(
      onTap: signInWithGoogle,
      child: Container(
        margin: EdgeInsets.only(left: MySize.size24!, right: MySize.size24!, top: MySize.size36!),
        decoration: BoxDecoration(
          color: Styles.primaryColor,
          borderRadius: BorderRadius.circular(MySize.size10!),
          boxShadow: [
            BoxShadow(
              color: Styles.primaryColor.withAlpha(100),
              blurRadius: 5,
              offset: Offset(
                  0, 5), // changes position of shadow
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(MySize.size8!),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(MySize.size10!,),
                color: Colors.white,
              ),
              child: Image.asset("assets/google logo.png", width: MySize.size30, height: MySize.size30,),
            ),
            Expanded(
              child: Text(
                "Sign Up With Google",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget getAlreadyAUserLinkText() {
    return Container(
      margin: EdgeInsets.only(left: MySize.size48!, right: MySize.size48!, top: MySize.size40!),
      child: InkWell(
        onTap: () {
          Navigator.pushNamedAndRemoveUntil(context, LoginScreen.routeName, (_) => false);
        },
        child: Text(
          "Already a User?",
          softWrap: true,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            height: 1.2,
            color: Styles.onBackground.withAlpha(200),
            decoration: TextDecoration.underline,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
