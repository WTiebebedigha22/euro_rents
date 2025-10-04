import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';

class FirebaseUserDataSource {
  final FirebaseFirestore firestore;

  FirebaseUserDataSource({required this.firestore});

  Future<void> saveUser(AppUser user) async {
    await firestore.collection('users').doc(user.id).set(user.toMap(), SetOptions(merge: true));
  }

  Future<AppUser?> getUser(String id) async {
    final doc = await firestore.collection('users').doc(id).get();
    if (!doc.exists) return null;
    return AppUser.fromMap(doc.data()!, doc.id);
  }

  Stream<AppUser?> streamUser(String id) {
    return firestore.collection('users').doc(id).snapshots().map((doc) {
      if (!doc.exists) return null;
      return AppUser.fromMap(doc.data()!, doc.id);
    });
  }
}
