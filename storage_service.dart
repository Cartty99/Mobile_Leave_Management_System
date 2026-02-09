import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadProfilePicture(String uid, File file) async {
    final ref = _storage.ref().child(
      'profiles/$uid/profile_${DateTime.now().millisecondsSinceEpoch}.jpg',
    );
    final upload = await ref.putFile(file);
    final url = await upload.ref.getDownloadURL();
    return url;
  }

  Future<String> uploadSupportingDocument(String uid, File file) async {
    final ref = _storage.ref().child(
      'documents/$uid/doc_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );
    final upload = await ref.putFile(file);
    final url = await upload.ref.getDownloadURL();
    return url;
  }
}
