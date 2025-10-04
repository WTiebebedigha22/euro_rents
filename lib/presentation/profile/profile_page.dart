import 'package:euro_rens/presentation/home/home_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../home/car_list_page.dart';
import './edit_profile_card.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int _selectedIndex = 0;

  void _onNavTap(int index) {
    setState(() => _selectedIndex = index);

    if (index == 2) return;
    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const CarListPage()),
      );
    } else if (index == 0) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    }
  }

  Map<String, dynamic>? userData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final doc = await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .get();

      if (mounted) {
        setState(() {
          userData = doc.data() ?? {};
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
      debugPrint("❌ Error fetching user data: $e");
    }
  }

  void _goToEditPage() async {
    if (userData == null) return;

    final updated = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditProfilePage(currentData: userData!),
      ),
    );

    if (updated == true) {
      _fetchUserData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authUser = FirebaseAuth.instance.currentUser;
    final fullName = userData?["name"] ?? "";
    final parts = fullName.trim().split(" ");
    final firstName = parts.isNotEmpty ? parts.first : "";
    final lastName = parts.length > 1 ? parts.sublist(1).join(" ") : "";

    // ✅ Email: Firestore value or fallback to FirebaseAuth
    final email =
        (userData?["email"] != null && userData!["email"].toString().isNotEmpty)
        ? userData!["email"]
        : authUser?.email ?? "Not provided";

    // ✅ Phone Number: Firestore value or fallback to FirebaseAuth
    final phoneNumber =
        (userData?["phoneNumber"] != null &&
            userData!["phoneNumber"].toString().isNotEmpty)
        ? userData!["phoneNumber"]
        : authUser?.phoneNumber ?? "Not provided";

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Profile"),
        actions: [
          IconButton(icon: const Icon(Icons.edit), onPressed: _goToEditPage),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : userData == null || userData!.isEmpty
          ? const Center(child: Text("No profile data found. Please update."))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Profile Picture
                  CircleAvatar(
                    radius: 60,
                    backgroundImage:
                        (userData!["profilePic"] != null &&
                            userData!["profilePic"].toString().isNotEmpty)
                        ? NetworkImage(userData!["profilePic"])
                        : const AssetImage("assets/images/profile.jpg")
                              as ImageProvider,
                  ),
                  const SizedBox(height: 18),

                  Text(
                    fullName.isNotEmpty ? fullName : "No Name",
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),

                  _buildInfoCard("First Name", firstName),
                  _buildInfoCard("Last Name", lastName),
                  _buildInfoCard("Username", userData!["username"]),
                  _buildInfoCard("Email", email),
                  _buildInfoCard("Phone Number", phoneNumber),
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
          BottomNavigationBarItem(icon: Icon(Icons.directions_car), label: "Cars",),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
        child: ListTile(
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            (value != null && value.toString().isNotEmpty)
                ? value.toString()
                : "Not provided",
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ),
    );
  }
}
