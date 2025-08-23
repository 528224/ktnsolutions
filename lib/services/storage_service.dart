import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class StorageService {

  Future<String> uploadFile(String filePath, String directoryName) async {
    try {
      if (filePath.isEmpty) return "";
      final extension = ".png";
      File file = File(filePath);
      var fileName = '${DateTime
          .now()
          .millisecondsSinceEpoch}';
      final ref = firebase_storage.FirebaseStorage.instance
          .ref()
          .child(directoryName)
          .child('$fileName$extension'); // Fixed extra bracket

      await ref.putFile(file);
      return await ref.getDownloadURL();
    } catch (e) {
      print("Error uploading files: $e");
      return "";
    }
  }

  Future<void> deleteFile(String fileUrl) async {
    try {
      final ref = firebase_storage.FirebaseStorage.instance.refFromURL(fileUrl);
      await ref.delete();
    } catch (e) {
      throw Exception('Error deleting file: $e');
    }
  }

}