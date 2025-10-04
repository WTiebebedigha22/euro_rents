import 'package:euro_rens/core/services/notification_service.dart';
import 'package:euro_rens/presentation/home/car_list_page.dart';
import 'package:euro_rens/presentation/home/home_page.dart';
import 'package:euro_rens/presentation/profile/profile_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboardPage> {
  int _selectedIndex = 0;
  Stream<QuerySnapshot>? bookingsStream;
  bool _isAdmin = false;
  User? _user;

  @override
  void initState() {
    super.initState();
    _setupUserStream();
  }

  Future<void> _setupUserStream() async {
    _user = FirebaseAuth.instance.currentUser;
    if (_user == null) return;

    final isAdmin = await _checkIfAdmin(_user!);

    setState(() {
      _isAdmin = isAdmin;
      bookingsStream = isAdmin
          ? FirebaseFirestore.instance
              .collection('bookings')
              .orderBy('createdAt', descending: true)
              .snapshots()
          : FirebaseFirestore.instance
              .collection('bookings')
              .where('userId', isEqualTo: _user!.uid)
              .orderBy('createdAt', descending: true)
              .snapshots();
    });

    debugPrint("Admin status: $_isAdmin");
  }

  Future<bool> _checkIfAdmin(User user) async {
    try {
      final tokenResult = await user.getIdTokenResult(true);
      if (tokenResult.claims?['admin'] == true) {
        return true;
      }

      final snap = await FirebaseFirestore.instance.collection("users").doc(user.uid).get();
      if (snap.exists && snap.data()?['role'] == 'admin') {
        return true;
      }
    } catch (e) {
      debugPrint("Error checking admin role: $e");
    }
    return false;
  }

  void _onNavTap(int index) {
    setState(() => _selectedIndex = index);

    if (index == 0) return;
    if (index == 1) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const CarListPage()));
    } else if (index == 2) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const HomePage()));
    } else if (index == 3) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfilePage()));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_user == null) {
      return const Scaffold(body: Center(child: Text("Not signed in")));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("BMW Rentals", style: TextStyle(color: Colors.blueAccent)),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              NotificationService.showSuccess("Signed out successfully");
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, "/login");
              }
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Welcome Back,", style: GoogleFonts.roboto(fontSize: 18, color: Colors.grey[700])),
                const SizedBox(height: 4),
                _buildUserHeader(_user),
                const SizedBox(height: 16),
                Text(
                  _isAdmin ? "All Vehicle Bookings" : "My Vehicle Bookings",
                  style: GoogleFonts.roboto(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),

          Expanded(
            child: bookingsStream == null
                ? const Center(child: CircularProgressIndicator())
                : StreamBuilder<QuerySnapshot>(
                    stream: bookingsStream,
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Center(child: Text("Error: ${snapshot.error}"));
                      }
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final docs = snapshot.data?.docs ?? [];
                      debugPrint("Bookings fetched: ${docs.length}");

                      if (docs.isEmpty) {
                        return const Center(child: Text("No bookings found"));
                      }

                      return ListView(
                        padding: const EdgeInsets.only(bottom: 80),
                        children: docs.map((d) {
                          final data = d.data() as Map<String, dynamic>;
                          return _buildBookingCard(d.id, data);
                        }).toList(),
                      );
                    },
                  ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        backgroundColor: Colors.black,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.white70,
        onTap: _onNavTap,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.list_outlined), label: "Dashboard"),
          BottomNavigationBarItem(icon: Icon(Icons.directions_car), label: "Cars"),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }

  Widget _buildBookingCard(String id, Map<String, dynamic> data) {
    final carId = data['carId'] ?? "Unknown Car";
    final status = (data['status'] ?? "pending").toLowerCase();
    final requestedBy = data['requestedBy'] ?? "Unknown User";
    final amount = data['amount']?.toString() ?? "0";

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text('$carId — ${status[0].toUpperCase()}${status.substring(1)}'),
        subtitle: Text('By: $requestedBy • Amount: $amount'),
        trailing: _isAdmin && status == "pending"
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.check, color: Colors.green),
                    onPressed: () async {
                      await FirebaseFirestore.instance.collection('bookings').doc(id).update({
                        'status': 'approved',
                        'approvedAt': FieldValue.serverTimestamp(),
                      });
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.red),
                    onPressed: () async {
                      await FirebaseFirestore.instance.collection('bookings').doc(id).update({
                        'status': 'declined',
                        'declinedAt': FieldValue.serverTimestamp(),
                      });
                    },
                  ),
                ],
              )
            : null,
      ),
    );
  }

  Future<Map<String, dynamic>?> _getUserData(String uid) async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection("users").doc(uid).get();
      if (snapshot.exists) return snapshot.data();
    } catch (e) {
      debugPrint("Error fetching user data: $e");
    }
    return null;
  }

  Widget _buildUserHeader(User? user) {
    if (user == null) {
      return const Text("Admin", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold));
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
              backgroundImage: (photoUrl.startsWith("http")) ? NetworkImage(photoUrl) : null,
              child: photoUrl.isEmpty ? const Icon(Icons.person, size: 20) : null,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                username,
                style: GoogleFonts.roboto(fontSize: 20, fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        );
      },
    );
  }
}
