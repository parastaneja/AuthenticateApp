import 'package:cloud_firestore/cloud_firestore.dart';

class CommentModel {
  String comment = "", createdById = "", createdByName = "", createdByImage = "";
  Timestamp? createdTime;

  CommentModel();

  CommentModel.fromMap(Map<String, dynamic> map) {
    comment = map['comment']?.toString() ?? "";
    createdById = map['createdById']?.toString() ?? "";
    createdByName = map['createdByName']?.toString() ?? "";
    createdByImage = map['createdByImage']?.toString() ?? "";
    createdTime = map['createdTime'];
  }

  void updateFromMap(Map<String, dynamic> map) {
    comment = map['comment']?.toString() ?? "";
    createdById = map['createdById']?.toString() ?? "";
    createdByName = map['createdByName']?.toString() ?? "";
    createdByImage = map['createdByImage']?.toString() ?? "";
    createdTime = map['createdTime'];
  }

  Map<String, dynamic> tomap() {
    return {
      "comment" : comment,
      "createdById" : createdById,
      "createdByName" : createdByName,
      "createdByImage" : createdByImage,
      "createdTime" : createdTime,
    };
  }

  @override
  String toString() {
    return "comment:${comment}, createdById:$createdById, createdByName:$createdByName, createdByImage:$createdByImage, "
        "createdTime:$createdTime";
  }
}