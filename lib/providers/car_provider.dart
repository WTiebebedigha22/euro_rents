import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/models/car.dart';
import '../data/datasources/firebase_car_data_source.dart';

class CarProvider extends ChangeNotifier {
  final FirebaseCarDataSource _carDataSource =
      FirebaseCarDataSource(firestore: FirebaseFirestore.instance);

  List<Car> _cars = [];
  List<Car> get cars => _cars;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> loadAvailableCars() async {
    _isLoading = true;
    notifyListeners();

    try {
      _cars = await _carDataSource.getAvailableCars();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Stream<List<Car>> streamCars() {
    return _carDataSource.streamCars();
  }
}
