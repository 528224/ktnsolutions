import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadFile(String filePath, String storagePath) async {
    try {
      final File file = File(filePath);
      final String fileName = '${DateTime.now().millisecondsSinceEpoch}${path.extension(filePath)}';
      final String fullPath = '$storagePath/$fileName';
      
      final Reference storageRef = _storage.ref().child(fullPath);
      final UploadTask uploadTask = storageRef.putFile(file);
      final TaskSnapshot snapshot = await uploadTask;
      
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw Exception('Error uploading file: $e');
    }
  }

  Future<void> deleteFile(String fileUrl) async {
    try {
      final Reference ref = _storage.refFromURL(fileUrl);
      await ref.delete();
    } catch (e) {
      throw Exception('Error deleting file: $e');
    }
  }
}
