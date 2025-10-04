import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
// NOTE: Make sure you have 'firebase_options.dart' in the same directory
import 'firebase_options.dart'; 

final List<Map<String, dynamic>> cars = [
  {
    'name': 'M240i Coupe',
    'imageUrl': 'assets/images/M240i_Coupe.png',
    'pricePerDay': 45.0,
    'people': 2,
    'transmission': 'Automatic',
    'fuelType': 'Petrol',
    'bodyType': 'Coupe',
    'latitude': 6.5244,
    'longitude': 3.3792,
    'isAvailable': true,
  },
  {
    'name': 'M340i Sedan',
    'imageUrl': 'assets/images/M340i_Sedan.png',
    'pricePerDay': 45.0,
    'people': 5,
    'transmission': 'Automatic',
    'fuelType': 'Petrol',
    'bodyType': 'Sedan',
    'latitude': 6.4654,
    'longitude': 3.4064,
    'isAvailable': true,
  },
  {
    'name': 'M440i Gran Coupe',
    'imageUrl': 'assets/images/M440i_Gran_Coupe.png',
    'pricePerDay': 45.0,
    'people': 5,
    'transmission': 'Automatic',
    'fuelType': 'Petrol',
    'bodyType': 'Coupe',
    'latitude': 6.6018,
    'longitude': 3.3515,
    'isAvailable': true,
  },
  {
    'name': 'XM',
    'imageUrl': 'assets/images/XM.png',
    'pricePerDay': 70.0,
    'people': 5,
    'transmission': 'Automatic',
    'fuelType': 'Hybrid',
    'bodyType': 'SUV',
    'latitude': 6.5244,
    'longitude': 3.3792,
    'isAvailable': true,
  },
  {
    'name': 'X7 M60i',
    'imageUrl': 'assets/images/X7_M60i.png',
    'pricePerDay': 70.0,
    'people': 7,
    'transmission': 'Automatic',
    'fuelType': 'Petrol',
    'bodyType': 'SUV',
    'latitude': 6.4551,
    'longitude': 3.3942,
    'isAvailable': true,
  },
  {
    'name': 'X5 M',
    'imageUrl': 'assets/images/X5_M.png',
    'pricePerDay': 70.0,
    'people': 5,
    'transmission': 'Automatic',
    'fuelType': 'Petrol',
    'bodyType': 'SUV',
    'latitude': 6.4654,
    'longitude': 3.4064,
    'isAvailable': true,
  },
  {
    'name': 'X5 M60i',
    'imageUrl': 'assets/images/X5_M60i.png',
    'pricePerDay': 70.0,
    'people': 5,
    'transmission': 'Automatic',
    'fuelType': 'Petrol',
    'bodyType': 'SUV',
    'latitude': 6.4210,
    'longitude': 3.4500,
    'isAvailable': true,
  },
  {
    'name': 'X4 M Competition',
    'imageUrl': 'assets/images/X4_M_Competition.png',
    'pricePerDay': 70.0,
    'people': 5,
    'transmission': 'Automatic',
    'fuelType': 'Petrol',
    'bodyType': 'SUV',
    'latitude': 6.5244,
    'longitude': 3.3792,
    'isAvailable': true,
  },
  {
    'name': 'X3 M40i',
    'imageUrl': 'assets/images/X3_M40i.png',
    'pricePerDay': 70.0,
    'people': 5,
    'transmission': 'Automatic',
    'fuelType': 'Petrol',
    'bodyType': 'SUV',
    'latitude': 6.5244,
    'longitude': 3.3792,
    'isAvailable': true,
  },
  {
    'name': 'Z4 M40i',
    'imageUrl': 'assets/images/Z4_M40i.png',
    'pricePerDay': 55.0,
    'people': 2,
    'transmission': 'Automatic',
    'fuelType': 'Petrol',
    'bodyType': 'Roadster',
    'latitude': 6.4654,
    'longitude': 3.4064,
    'isAvailable': true,
  },
  {
    'name': 'M8 Competition Coupe',
    'imageUrl': 'assets/images/M8_Competition_Coupe.png',
    'pricePerDay': 60.0,
    'people': 2,
    'transmission': 'Automatic',
    'fuelType': 'Petrol',
    'bodyType': 'Coupe',
    'latitude': 6.5244,
    'longitude': 3.3792,
    'isAvailable': true,
  },
  {
    'name': 'M5 Sedan',
    'imageUrl': 'assets/images/M5_Sedan.png',
    'pricePerDay': 80.0,
    'people': 5,
    'transmission': 'Automatic',
    'fuelType': 'Petrol',
    'bodyType': 'Sedan',
    'latitude': 6.6018,
    'longitude': 3.3515,
    'isAvailable': true,
  },
  {
    'name': 'M5 Touring',
    'imageUrl': 'assets/images/M5_Touring.png',
    'pricePerDay': 90.0,
    'people': 5,
    'transmission': 'Automatic',
    'fuelType': 'Hybrid',
    'bodyType': 'Wagon',
    'latitude': 6.5244,
    'longitude': 3.3792,
    'isAvailable': true,
  },
  {
    'name': 'M3 CS Touring',
    'imageUrl': 'assets/images/M3_CS_Touring.png', 
    'pricePerDay': 95.0, 
    'people': 5,
    'transmission': 'Automatic',
    'fuelType': 'Petrol',
    'bodyType': 'Wagon',
    'latitude': 6.4551,
    'longitude': 3.3942,
    'isAvailable': true,
  },
  {
    'name': 'M4 Coupe',
    'imageUrl': 'assets/images/M4_Coupe.png',
    'pricePerDay': 80.0,
    'people': 2,
    'transmission': 'Automatic',
    'fuelType': 'Petrol',
    'bodyType': 'Coupe',
    'latitude': 6.4551,
    'longitude': 3.3942,
    'isAvailable': true,
  },
  {
    'name': 'M3 Sedan',
    'imageUrl': 'assets/images/M3_Sedan.png',
    'pricePerDay': 80.0,
    'people': 5,
    'transmission': 'Automatic',
    'fuelType': 'Petrol',
    'bodyType': 'Sedan',
    'latitude': 6.5244,
    'longitude': 3.3792,
    'isAvailable': true,
  },
  {
    'name': 'M2 Competition',
    'imageUrl': 'assets/images/M2_Competition.png',
    'pricePerDay': 80.0,
    'people': 2,
    'transmission': 'Automatic',
    'fuelType': 'Petrol',
    'bodyType': 'Coupe',
    'latitude': 6.4654,
    'longitude': 3.4064,
    'isAvailable': true,
  },
  {
    'name': 'M7 M760i',
    'imageUrl': 'assets/images/M7_760i_sedan.png',
    'pricePerDay': 120.0,
    'people': 5,
    'transmission': 'Automatic',
    'fuelType': 'Petrol',
    'bodyType': 'Sedan',
    'latitude': 6.4654,
    'longitude': 3.4064,
    'isAvailable': true,
  },
];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final firestore = FirebaseFirestore.instance;
  final carsCollection = firestore.collection('cars');

  final snapshot = await carsCollection.get();
  for (var doc in snapshot.docs) {
    await doc.reference.delete();
  }

  for (var car in cars) {
    await carsCollection.add(car);
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Text(
            "Cars seeded successfully", 
            style: TextStyle(fontSize: 20),
          ),
        ),
      ),
    );
  }
}