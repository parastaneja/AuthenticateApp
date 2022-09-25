import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:profile_details/controllers/firestore_controller.dart';
import 'package:profile_details/controllers/providers/user_provider.dart';
import 'package:profile_details/models/user_model.dart';
import 'package:profile_details/screens/common/components/app_bar.dart';
import 'package:profile_details/screens/common/components/modal_progress_hud.dart';
import 'package:profile_details/utils/SizeConfig.dart';
import 'package:profile_details/utils/snakbar.dart';
import 'package:profile_details/utils/styles.dart';
import 'package:provider/provider.dart';

class EditProfileScreen extends StatefulWidget {
  static const String routeName = "/EditProfileScreen";

  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final picker = ImagePicker();

  bool isLoading = false;

  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController phoneController = TextEditingController();

  Future<void> editProfile() async {
    UserProvider userProvider = Provider.of<UserProvider>(context, listen: false);
    if((userProvider.userid).isEmpty) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    Map<String, dynamic> data = {
      "name" : nameController.text,
      "mobile" : phoneController.text,
      "bio" : descriptionController.text,
    };

    await FirestoreController().firestore.collection("users").doc(userProvider.userid).update(data);

    UserModel? userModel = userProvider.userModel;

    if(userModel != null) {
      userModel.name = nameController.text;
      userModel.mobile = phoneController.text;
      userModel.bio = descriptionController.text;
      userProvider.notifyListeners();
    }

    setState(() {
      isLoading = false;
    });

    Navigator.pop(context);
  }

  @override
  void initState() {
    super.initState();
    UserProvider userProvider = Provider.of<UserProvider>(context, listen: false);
    nameController.text = userProvider.userModel?.name ?? "";
    phoneController.text = userProvider.userModel?.mobile ?? "";
    descriptionController.text = userProvider.userModel?.bio ?? "";
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return !isLoading;
      },
      child: ModalProgressHUD(
        opacity: 0.3,
        inAsyncCall: isLoading,
        color: Colors.black,
        child: Container(
          color: Styles.background,
          child: SafeArea(
            child: Scaffold(
              backgroundColor: Styles.background,
              body: Column(
                children: [
                  MyAppBar(title: "Create Post", backbtnVisible: true, color: Colors.white,),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            getNameTextField(),
                            getMobileTextField(),
                            getDescriptionTextField(),
                            getEditProfileButton(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  //Main UI Components
  Widget getNameTextField() {
    return Container(
      margin: EdgeInsets.only(top: MySize.size10!),
      padding: const EdgeInsets.only(top: 24, left: 16, right: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(MySize.size10!),
      ),
      child: TextFormField(
        controller: nameController,
        validator: (val) => (val?.isNotEmpty ?? false) ? null : "*required",
        decoration: InputDecoration(
          hintText: "Name",
          isDense: true,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(MySize.size5!),
            borderSide: const BorderSide(color: Colors.transparent),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(MySize.size5!),
            borderSide: const BorderSide(color: Colors.transparent),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(MySize.size5!),
            borderSide: const BorderSide(color: Colors.transparent),
          ),
        ),
        textCapitalization: TextCapitalization.sentences,
        maxLines: 1,
      ),
    );
  }

  Widget getMobileTextField() {
    return Container(
      margin: EdgeInsets.only(top: MySize.size10!),
      padding: const EdgeInsets.only(top: 24, left: 16, right: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(MySize.size10!),
      ),
      child: TextFormField(
        controller: phoneController,
        keyboardType: TextInputType.phone,
        validator: (val) => (val?.isNotEmpty ?? false) ? null : "*required",
        decoration: InputDecoration(
          hintText: "Mobile",
          isDense: true,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(MySize.size5!),
            borderSide: const BorderSide(color: Colors.transparent),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(MySize.size5!),
            borderSide: const BorderSide(color: Colors.transparent),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(MySize.size5!),
            borderSide: const BorderSide(color: Colors.transparent),
          ),
        ),
        textCapitalization: TextCapitalization.sentences,
        maxLines: 1,
        inputFormatters: [
          LengthLimitingTextInputFormatter(11),
        ],
      ),
    );
  }

  Widget getDescriptionTextField() {
    return Container(
      margin: EdgeInsets.only(top: MySize.size10!),
      padding: const EdgeInsets.only(top: 24, left: 16, right: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(MySize.size10!),
      ),
      child: TextFormField(
        controller: descriptionController,
        validator: (val) => (val?.isNotEmpty ?? false) ? null : "*required",
        decoration: InputDecoration(
          hintText: "Description",
          isDense: true,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(MySize.size5!),
            borderSide: const BorderSide(color: Colors.transparent),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(MySize.size5!),
            borderSide: const BorderSide(color: Colors.transparent),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(MySize.size5!),
            borderSide: const BorderSide(color: Colors.transparent),
          ),
        ),
        textCapitalization: TextCapitalization.sentences,
        minLines: 5,
        maxLines: 10,
      ),
    );
  }

  Widget getEditProfileButton() {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(const Radius.circular(8)),
      ),
      child: FlatButton(
        onPressed: () async {
          if(_formKey.currentState!.validate() ?? false) {
            print("Valid Fields");

            await editProfile();
            /*for(int i = 10; i < 20; i++) {
              nameController.text = "Name${i+1}";
              descriptionController.text = "Description${i+1}";
              print(i);
              await addProduct();
            }*/
          }
        },
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        color: Styles.primaryColor,
        splashColor: Colors.white.withAlpha(150),
        highlightColor: Styles.primaryColor,
        padding: const EdgeInsets.only(
            left: 24, right: 24),
        child: const Text(
          "Edit Profile",
          style: TextStyle(
            fontWeight: FontWeight.w500,
            letterSpacing: 0.2,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
