import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/car.dart';

class FirebaseCarDataSource {
  final FirebaseFirestore firestore;

  FirebaseCarDataSource({required this.firestore});

  Future<void> addCar(Car car) async {
    await firestore.collection('cars').doc(car.id).set(car.toMap());
  }

  Future<Car?> getCar(String id) async {
    final doc = await firestore.collection('cars').doc(id).get();
    if (!doc.exists) return null;
    return Car.fromMap(doc.data()!, doc.id);
  }

  Future<List<Car>> getAvailableCars() async {
    final snapshot = await firestore.collection('cars').where('isAvailable', isEqualTo: true).get();
    return snapshot.docs.map((doc) => Car.fromMap(doc.data(), doc.id)).toList();
  }

  Stream<List<Car>> streamCars() {
    return firestore.collection('cars').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Car.fromMap(doc.data(), doc.id)).toList();
    });
  }
}
