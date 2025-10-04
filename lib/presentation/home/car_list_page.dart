import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:euro_rens/data/models/car.dart';
import 'package:euro_rens/presentation/home/car_detail_page.dart';
import 'package:euro_rens/presentation/home/home_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../profile/profile_page.dart';

class CarListPage extends StatefulWidget {
  const CarListPage({super.key});

  @override
  State<CarListPage> createState() => _CarListPageState();
}

class _CarListPageState extends State<CarListPage> {
  String selectedType = "All";
  int selectedSeats = -1;

  final List<String> carTypes = ['All', 'Sedan', 'Coupe', 'Roadster', 'Wagon', 'SUV'];
  final List<int> seatOptions = [-1, 2, 5, 7];

  void _resetFilters() {
    setState(() {
      selectedType = "All";
      selectedSeats = -1;
    });
  }

  int _selectedIndex = 0;

  void _onNavTap(int index) {
    setState(() => _selectedIndex = index);

    if (index == 1) return;
    if (index == 0) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ProfilePage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Query carsQuery = FirebaseFirestore.instance
        .collection("cars")
        .where("isAvailable", isEqualTo: true);

    if (selectedType != "All") {
      carsQuery = carsQuery.where("bodyType", isEqualTo: selectedType);
    }
    if (selectedSeats != -1) {
      carsQuery = carsQuery.where("people", isEqualTo: selectedSeats);
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("All Cars"),
        actions: [
          TextButton(
            onPressed: _resetFilters,
            child: const Text(
              "Reset Filters",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(70),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      filled: true,
                      labelText: "Vehicle Type",
                      border: OutlineInputBorder(),
                    ),
                    value: selectedType,
                    items: carTypes.map((type) {
                      return DropdownMenuItem<String>(
                        value: type,
                        child: Text(type),
                      );
                    }).toList(),
                    onChanged: (value) =>
                        setState(() => selectedType = value ?? "All"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    decoration: const InputDecoration(
                      filled: true,
                      labelText: "Seats",
                      border: OutlineInputBorder(),
                    ),
                    value: selectedSeats,
                    items: seatOptions.map((seats) {
                      return DropdownMenuItem<int>(
                        value: seats,
                        child: Text(seats == -1 ? 'All' : seats.toString()),
                      );
                    }).toList(),
                    onChanged: (value) =>
                        setState(() => selectedSeats = value ?? -1),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: carsQuery.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "No cars available",
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          final cars = snapshot.data!.docs;

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.5,
            ),
            itemCount: cars.length,
            itemBuilder: (context, index) {
              final carData = cars[index].data() as Map<String, dynamic>;
              final car = Car.fromMap(carData, cars[index].id);

              return Container(
                decoration: BoxDecoration(
                  color: const Color.fromARGB(29, 255, 255, 255),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 6,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                      child: AspectRatio(
                        aspectRatio: 16 / 9,
                        child: Image.asset(
                          car.imageUrl.isNotEmpty
                              ? car.imageUrl
                              : "assets/images/default.png",
                          fit: BoxFit.cover,
                          width: double.infinity,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.directions_car,
                            size: 80,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Text(
                            car.name,
                            style: GoogleFonts.roboto(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "£${car.pricePerDay}/day",
                            style: GoogleFonts.roboto(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.blueAccent,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Type: ${car.bodyType}",
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Seats: ${car.people}",
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => CarDetailsPage(car: car),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 36),
                            ),
                            child: const Text("View Details"),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        backgroundColor: Colors.black,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.white70,
        onTap: _onNavTap,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.directions_car), label: "Cars"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}