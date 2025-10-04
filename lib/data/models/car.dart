import 'package:cloud_firestore/cloud_firestore.dart';

class Car {
  final String id;
  final String name;
  final String imageUrl;
  final double pricePerDay;
  final int people;
  final String transmission;
  final String fuelType;
  final double latitude;
  final double longitude;
  final bool isAvailable;
  final String bodyType; 

  Car({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.pricePerDay,
    required this.people,
    required this.transmission,
    required this.fuelType,
    required this.latitude,
    required this.longitude,
    required this.isAvailable,
    required this.bodyType,
  });

  factory Car.fromMap(Map<String, dynamic> map, String id) {
    return Car(
      id: id,
      name: map['name'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      pricePerDay: (map['pricePerDay'] as num?)?.toDouble() ?? 0.0,
      people: (map['people'] as num?)?.toInt() ?? 0,
      transmission: map['transmission'] ?? '',
      fuelType: map['fuelType'] ?? '',
      latitude: (map['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 0.0,
      isAvailable: map['isAvailable'] ?? false,
      bodyType: map['bodyType'] ?? 'Unknown',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'imageUrl': imageUrl,
      'pricePerDay': pricePerDay,
      'people': people,
      'transmission': transmission,
      'fuelType': fuelType,
      'latitude': latitude,
      'longitude': longitude,
      'isAvailable': isAvailable,
      'bodyType': bodyType, 
    };
  }

  factory Car.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Car.fromMap(data, doc.id);
  }
}
