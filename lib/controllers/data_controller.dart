import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:profile_details/controllers/firestore_controller.dart';
import 'package:profile_details/utils/my_print.dart';

class DataController {
  Future<String> getNewDocId() async {
    String docId = "";

    docId = await FirestoreController().firestore.collection("Temp").add({"name" : "dfghm"}).then((DocumentReference reference) async {
      await reference.delete();

      return reference.id;
    });

    print("DocId:" + docId);
    return docId;
  }

  Future<List<String>> uploadImages({required String folder, required List<File> images}) async {
    List<String> downloadUrls = [];

    try {
      await Future.wait(images.map((File file) async {
        Uint8List bytes = file.readAsBytesSync();

        String fileName = file.path.substring(file.path.lastIndexOf("/") + 1);
        Reference reference = FirebaseStorage.instance.ref().child(folder).child(fileName);
        UploadTask uploadTask = reference.putData(bytes);
        TaskSnapshot storageTaskSnapshot;

        TaskSnapshot snapshot = await uploadTask.then((TaskSnapshot snapshot) => snapshot);
        if (snapshot.state == TaskState.success) {
          storageTaskSnapshot = snapshot;
          final String downloadUrl = await storageTaskSnapshot.ref.getDownloadURL();
          downloadUrls.add(downloadUrl);

          print('$fileName Upload success, url:${downloadUrl}');
        }
        else {
          print('Error from image repo uploading $fileName: ${snapshot.toString()}');
          //throw ('This file is not an image');
        }
      }),
          eagerError: true, cleanUp: (_) {
            print('eager cleaned up');
          });
    }
    catch(e, s) {
      MyPrint.printOnConsole("Error in Uplaoding Image:$e");
      MyPrint.printOnConsole(s);
    }

    return downloadUrls;
  }
}