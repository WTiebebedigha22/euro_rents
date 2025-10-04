import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/models/car.dart';

class CarRepository {
  final FirebaseFirestore _firestore;

  CarRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<List<Car>> getCars() async {
    final snapshot = await _firestore.collection('cars').get();
    return snapshot.docs
        .map((doc) => Car.fromMap(doc.data(), doc.id))
        .toList();
  }

  Future<Car?> getCarById(String id) async {
    final doc = await _firestore.collection('cars').doc(id).get();
    if (!doc.exists) return null;
    return Car.fromMap(doc.data()!, doc.id);
  }

  Future<void> addCar(Car car) async {
    await _firestore.collection('cars').add(car.toMap());
  }

  Future<void> updateCar(Car car) async {
    await _firestore.collection('cars').doc(car.id).update(car.toMap());
  }

  Future<void> deleteCar(String id) async {
    await _firestore.collection('cars').doc(id).delete();
  }
}
