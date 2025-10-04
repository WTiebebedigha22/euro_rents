import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:euro_rens/core/services/notification_service.dart';
import 'package:euro_rens/presentation/booking/booking_page.dart';
import 'package:euro_rens/presentation/home/car_detail_page.dart';
import 'package:euro_rens/presentation/home/car_list_page.dart';
import 'package:euro_rens/presentation/profile/profile_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../data/models/car.dart';
import '../../data/models/booking.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  void _onNavTap(int index) {
    setState(() => _selectedIndex = index);

    if (index == 0) return;
    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const CarListPage()),
      );
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ProfilePage()),
      );
    }
  }

  Future<Map<String, dynamic>?> _getUserData(String uid) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .get();
      if (snapshot.exists) {
        return snapshot.data();
      }
    } catch (e) {
      debugPrint("Error fetching user data: $e");
    }
    return null;
  }

  Widget _buildUserHeader(User? user) {
    if (user == null) {
      return const Text(
        "Guest",
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      );
    }

    return FutureBuilder<Map<String, dynamic>?>(
      future: _getUserData(user.uid),
      builder: (context, snapshot) {
        final data = snapshot.data;
        final username = data?["username"] ?? user.email ?? "Guest";
        final photoUrl = data?["photoUrl"] ?? "";

        return Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundImage: (photoUrl.startsWith("http"))
                  ? NetworkImage(photoUrl)
                  : null,
              child: photoUrl.isEmpty
                  ? const Icon(Icons.person, size: 20)
                  : null,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                username,
                style: GoogleFonts.roboto(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("BMW Rentals"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              NotificationService.showSuccess("Signed out successfully");
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text(
              "Welcome Back,",
              style: GoogleFonts.roboto(fontSize: 18, color: Colors.grey[700]),
            ),
            const SizedBox(height: 4),
            _buildUserHeader(user),
            const SizedBox(height: 24),

            Text(
              "Featured Cars",
              style: GoogleFonts.roboto(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 200,
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection("cars")
                    .limit(4)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final cars = snapshot.data!.docs;
                  if (cars.isEmpty) {
                    return const Center(child: Text("No featured cars"));
                  }

                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: cars.length,
                    itemBuilder: (context, index) {
                      final car = Car.fromMap(
                        cars[index].data() as Map<String, dynamic>,
                        cars[index].id,
                      );
                      return _buildCarCard(car);
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 24),

            Text(
              "My Bookings",
              style: GoogleFonts.roboto(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("bookings")
                  .where("userId", isEqualTo: user?.uid)
                  .orderBy("startDate", descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No booking made yet"));
                }

                final bookings = snapshot.data!.docs;

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: bookings.length,
                  itemBuilder: (context, index) {
                    final booking = Booking.fromMap(
                      bookings[index].data() as Map<String, dynamic>,
                      bookings[index].id,
                    );

                    final now = DateTime.now();
                    final isExpired = booking.endDate.isBefore(now);
                    final elapsedDays = now
                        .difference(booking.startDate)
                        .inDays;
                    final totalDays = booking.endDate
                        .difference(booking.startDate)
                        .inDays;

                    return FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance
                          .collection("cars")
                          .doc(booking.carId)
                          .get(),
                      builder: (context, carSnapshot) {
                        if (!carSnapshot.hasData) {
                          return const SizedBox.shrink();
                        }
                        if (!carSnapshot.data!.exists) {
                          return const ListTile(title: Text("Car not found"));
                        }

                        final car = Car.fromMap(
                          carSnapshot.data!.data() as Map<String, dynamic>,
                          carSnapshot.data!.id,
                        );

                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            leading: Image.asset(
                              car.imageUrl,
                              width: 60,
                              fit: BoxFit.cover,
                            ),
                            title: Text(car.name),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Price: £${car.pricePerDay}/day"),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Text("Status: "),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isExpired
                                            ? Colors.red[100]
                                            : (booking.status.toLowerCase() ==
                                                      "pending"
                                                  ? Colors.amber[100]
                                                  : Colors.green[100]),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        isExpired ? "Expired" : booking.status,
                                        style: TextStyle(
                                          color: isExpired
                                              ? Colors.red[800]
                                              : (booking.status.toLowerCase() ==
                                                        "pending"
                                                    ? Colors.amber[800]
                                                    : Colors.green[800]),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  isExpired
                                      ? "Expired ${now.difference(booking.endDate).inDays} day(s) ago"
                                      : "Days elapsed: $elapsedDays / $totalDays",
                                ),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit,
                                    color: Colors.blue,
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => BookingPage(car: car),
                                      ),
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: () async {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (ctx) => AlertDialog(
                                        title: const Text("Delete Booking"),
                                        content: const Text(
                                          "Are you sure you want to delete this booking?",
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(ctx, false),
                                            child: const Text("Cancel"),
                                          ),
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(ctx, true),
                                            child: const Text("Delete"),
                                          ),
                                        ],
                                      ),
                                    );

                                    if (confirm == true) {
                                      await FirebaseFirestore.instance
                                          .collection("bookings")
                                          .doc(booking.id)
                                          .delete();
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text("Booking deleted"),
                                        ),
                                      );
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        backgroundColor: Colors.black,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.white70,
        onTap: _onNavTap,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
            icon: Icon(Icons.directions_car),
            label: "Cars",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }

  Widget _buildCarCard(Car car) {
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: _buildCarImage(car.imageUrl, height: 80),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Text(
                  car.name,
                  style: GoogleFonts.roboto(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  "£${car.pricePerDay}/day",
                  style: GoogleFonts.roboto(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.blueAccent,
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
                    backgroundColor: Colors.blueAccent,
                    minimumSize: const Size(double.infinity, 36),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text("View Details"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCarImage(String imageUrl, {double height = 100}) {
    if (imageUrl.isEmpty) {
      return Container(
        height: height,
        color: Colors.grey.shade200,
        child: const Center(child: Icon(Icons.directions_car, size: 40)),
      );
    }

    if (imageUrl.startsWith("http")) {
      return Image.network(
        imageUrl,
        height: height,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _fallbackCarIcon(height),
      );
    } else {
      return Image.asset(
        imageUrl,
        height: height,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _fallbackCarIcon(height),
      );
    }
  }

  Widget _fallbackCarIcon(double height) {
    return Container(
      height: height,
      color: Colors.grey.shade200,
      child: const Center(child: Icon(Icons.directions_car, size: 40)),
    );
  }
}
