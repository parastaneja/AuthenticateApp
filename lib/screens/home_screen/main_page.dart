import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:profile_details/controllers/authentication_controller.dart';
import 'package:profile_details/controllers/data_controller.dart';
import 'package:profile_details/controllers/firestore_controller.dart';
import 'package:profile_details/controllers/providers/user_provider.dart';
import 'package:profile_details/screens/common/components/MyCupertinoAlertDialogWidget.dart';
import 'package:profile_details/screens/common/components/app_bar.dart';
import 'package:profile_details/screens/common/components/modal_progress_hud.dart';
import 'package:profile_details/screens/home_screen/edit_profile_screen.dart';
import 'package:profile_details/utils/SizeConfig.dart';
import 'package:profile_details/utils/my_print.dart';
import 'package:profile_details/utils/snakbar.dart';
import 'package:profile_details/utils/styles.dart';
import 'package:provider/provider.dart';

class MainPage extends StatefulWidget {
  static const String routeName = "/MainPage";
  const MainPage({Key? key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with SingleTickerProviderStateMixin {
  bool isLoading = false;

  Future<void> logout() async {
    MyPrint.printOnConsole("logout");
    setState(() {
      isLoading = true;
    });
    bool? isLogout = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return MyCupertinoAlertDialogWidget(
          title: "Logout",
          description: "Are you sure want to logout?",
          negativeCallback: () {
            Navigator.pop(context, false);
          },
          positiviCallback: () {
            Navigator.pop(context, true);
          },
        );
      },
    );

    if(isLogout != null && isLogout) {
      await AuthenticationController().logout(context: context);
    }
    setState(() {
      isLoading = false;
    });
  }

  Future<void> updateProfileImage()async{
    UserProvider userProvider = Provider.of<UserProvider>(context, listen: false);
    XFile? imageFile = await ImagePicker().pickImage(source: ImageSource.gallery,);
    MyPrint.printOnConsole("imageFile:${imageFile?.path}");
    MyPrint.printOnConsole("UserId:${userProvider.userid}");

    if(imageFile != null && (userProvider.userid ?? "").isNotEmpty) {
      setState(() {
        isLoading = true;
      });

      List<String> imageUrls = await DataController().uploadImages(folder: "users/${userProvider.userid}", images: [File(imageFile.path)]);
      MyPrint.printOnConsole("ImageUrls:$imageUrls");

      if(imageUrls.isNotEmpty) {
        userProvider.userModel?.image = imageUrls.first;
        await FirestoreController().firestore.collection("users").doc(userProvider.userid).update({"image" : imageUrls.first});
      }
      else {
        Snakbar().show_error_snakbar(context, "Image Upload Failed");
      }

      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ModalProgressHUD(
        inAsyncCall: isLoading,
        child: Scaffold(
          backgroundColor: Styles.background,
          body: Column(
            children: [
              MyAppBar(title: "User Profile", color: Colors.white, backbtnVisible: false,),
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: MySize.size20!),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      getProfileDetails(),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          singleOption1(
                            iconData: Icons.logout,
                            option: "Edit Profile",
                            ontap: () async {
                              Navigator.pushNamed(context, EditProfileScreen.routeName);
                            },
                          ),
                          singleOption1(
                            iconData: Icons.logout,
                            option: "Logout",
                            ontap: () async {
                              logout();
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget getProfileDetails() {
    UserProvider userProvider = Provider.of<UserProvider>(context,);
    return Container(
      margin: EdgeInsets.only(bottom: MySize.getScaledSizeHeight(30)),
      child: Column(
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(bottom: MySize.size8!),
            width: MySize.getScaledSizeHeight(120),
            height: MySize.getScaledSizeHeight(120),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Styles.primaryColor,),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(300),
                    child: (userProvider.userModel?.image.isNotEmpty ?? false)
                        ? CachedNetworkImage(
                            imageUrl: userProvider.userModel!.image,
                            fit: BoxFit.fill,
                            placeholder: (_, __) => SpinKitFadingCircle(color: Styles.primaryColor,),
                            errorWidget: (_, __, ___) => const Icon(Icons.info),
                          )
                        : Padding(
                          padding: const EdgeInsets.all(10),
                          child: Image.asset("assets/male profile vector.png", fit: BoxFit.fill,),
                        ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: InkWell(
                    onTap: () {
                      updateProfileImage();
                    },
                    child: Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Styles.primaryColor,
                      ),
                      padding: const EdgeInsets.all(5),
                      child: const Icon(Icons.camera, color: Colors.white,),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Text(userProvider.userModel?.name ?? "", style: const TextStyle(color: Colors.black),),
          Text(userProvider.userModel?.bio ?? "", style: const TextStyle(color: Colors.black),),
          Visibility(
            visible: (userProvider.userModel?.email ?? "").isNotEmpty,
            child: Text(userProvider.userModel?.email ?? "", style: const TextStyle(color: Colors.black),),
          ),
          Visibility(
            visible: (userProvider.userModel?.mobile ?? "").isNotEmpty,
            child: Text(userProvider.userModel?.mobile ?? ""),
          ),
        ],
      ),
    );
  }

  Widget singleOption1({required IconData iconData, required String option, Function? ontap}) {
    return InkWell(
      onTap: ()async {
        if(ontap != null) ontap();
      },
      focusColor: Colors.transparent,
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: MySize.size10!),
        decoration: BoxDecoration(
          color: Styles.bottomAppbarColor,
          borderRadius: BorderRadius.circular(MySize.size10!),
        ),
        padding: EdgeInsets.symmetric(vertical: MySize.size16!, horizontal: MySize.size10!),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              child: Icon(
                iconData,
                size: MySize.size22,
                color: Styles.onBackground,
              ),
            ),
            Expanded(
              child: Container(
                margin: EdgeInsets.only(left: MySize.size16!),
                child: Text(option,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            Container(
              child: Icon(Icons.arrow_forward_ios_rounded,
                size: MySize.size22,
                color: Styles.onBackground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
