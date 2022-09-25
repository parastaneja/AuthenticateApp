import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  String id = "", name = "", image = "", mobile = "", email = "", bio = "";
  Timestamp? createdTime;
  List<String> myLikedPosts = [];

  UserModel();

  UserModel.fromMap(Map<String, dynamic> map) {
    id = map['id']?.toString() ?? "";
    name = map['name']?.toString() ?? "";
    image = map['image']?.toString() ?? "";
    mobile = map['mobile']?.toString() ?? "";
    email = map['email']?.toString() ?? "";
    bio = map['bio']?.toString() ?? "";
    createdTime = map['createdTime'];

    try {
      List<String> list = List.castFrom(map['myLikedPosts'] ?? []);
      myLikedPosts = list;
    }
    catch(e) {}

  }

  void updateFromMap(Map<String, dynamic> map) {
    id = map['id']?.toString() ?? "";
    name = map['name']?.toString() ?? "";
    image = map['image']?.toString() ?? "";
    mobile = map['mobile']?.toString() ?? "";
    email = map['email']?.toString() ?? "";
    bio = map['bio']?.toString() ?? "";
    createdTime = map['createdTime'];

    try {
      List<String> list = List.castFrom(map['myLikedPosts'] ?? []);
      myLikedPosts = list;
    }
    catch(e) {}

  }

  Map<String, dynamic> tomap() {
    return {
      "id" : id,
      "name" : name,
      "image" : image,
      "mobile" : mobile,
      "email" : email,
      "bio" : bio,
      "createdTime" : createdTime,
      "myLikedPosts" : myLikedPosts,
    };
  }

  @override
  String toString() {
    return tomap().toString();
  }
}