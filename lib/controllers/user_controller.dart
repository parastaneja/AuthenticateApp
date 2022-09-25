import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:profile_details/controllers/firestore_controller.dart';
import 'package:profile_details/controllers/providers/user_provider.dart';
import 'package:profile_details/models/user_model.dart';
import 'package:profile_details/utils/my_print.dart';
import 'package:provider/provider.dart';

class UserController {
  static UserController? _instance;

  factory UserController() {
    if(_instance == null) {
      _instance = UserController._();
    }
    return _instance!;
  }

  UserController._();

  Future<bool> isUserExist(BuildContext context, String uid) async {
    if(uid.isEmpty) return false;

    MyPrint.printOnConsole("Uid:${uid}");
    if(uid.isEmpty) return false;

    bool isUserExist = false;

    try {
      DocumentSnapshot<Map<String, dynamic>> documentSnapshot = await FirestoreController().firestore.collection('users').doc(uid).get();

      UserProvider userProvider = Provider.of<UserProvider>(context, listen: false);
      if(documentSnapshot.exists && (documentSnapshot.data()?.isNotEmpty ?? false)) {
        UserModel userModel = UserModel.fromMap(documentSnapshot.data()!);
        userProvider.userModel = userModel;
        MyPrint.printOnConsole("User Model:${userProvider.userModel}");
        isUserExist = true;
      }
      else {
        // UserModel userModel = UserModel();
        // userModel.id = uid;
        // userModel.name = userProvider.firebaseUser?.displayName ?? "";
        // userModel.mobile = userProvider.firebaseUser?.phoneNumber ?? "";
        // userModel.email = userProvider.firebaseUser?.email ?? "";
        // userModel.image = userProvider.firebaseUser?.photoURL ?? "";
        // userModel.createdTime = Timestamp.now();
        // bool isSuccess = await UserController().createUser(context, userModel);
        // MyPrint.printOnConsole("Insert Client Success:${isSuccess}");
      }
    }
    catch(e) {
      MyPrint.printOnConsole("Error in ClientController.isClientExist:${e}");
    }

    return isUserExist;
  }

  Future<bool> createUser(BuildContext context,UserModel userModel) async {
    try {
      /*Map<String, dynamic> data = {
        "ClientId" : clientModel.ClientId,
      };*/
      //if(clientModel.ClientPhoneNo.isNotEmpty) data['ClientPhoneNo'] = clientModel.ClientPhoneNo;
      //if(clientModel.ClientEmailId.isNotEmpty) data['ClientEmailId'] = clientModel.ClientEmailId;
      //data.remove("ClientId");
      Map<String, dynamic> data = userModel.tomap();

      await FirestoreController().firestore.collection("users").doc(userModel.id).set(data);

      UserProvider userProvider = Provider.of<UserProvider>(context, listen: false);
      userProvider.userModel = userModel;

      return true;
    }
    catch(e) {
      MyPrint.printOnConsole("Error in ClientController.insertClient:${e}");
    }

    return false;
  }
}