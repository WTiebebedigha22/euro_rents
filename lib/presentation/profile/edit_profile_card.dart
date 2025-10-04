import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:country_code_picker/country_code_picker.dart';

class EditProfilePage extends StatefulWidget {
  final Map<String, dynamic> currentData;
  const EditProfilePage({super.key, required this.currentData});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _usernameController;
  late TextEditingController _phoneController;
  DateTime? _dob;
  File? _profileImage;

  bool _isSaving = false;
  String _selectedDialCode = "+234"; // default country code

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.currentData["name"] ?? "");
    _usernameController =
        TextEditingController(text: widget.currentData["username"] ?? "");

    // If phone has a dial code, split it
    final phone = widget.currentData["phone"] ?? "";
    if (phone.toString().startsWith("+")) {
      final parts = RegExp(r"^(\+\d{1,4})(.*)$").firstMatch(phone);
      if (parts != null) {
        _selectedDialCode = parts.group(1)!;
        _phoneController = TextEditingController(text: parts.group(2)!.trim());
      } else {
        _phoneController = TextEditingController(text: phone);
      }
    } else {
      _phoneController = TextEditingController(text: phone);
    }

    final dobString = widget.currentData["dob"];
    if (dobString != null) {
      _dob = DateTime.tryParse(dobString);
    }
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _profileImage = File(picked.path));
    }
  }

  Future<void> _pickDOB() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _dob ?? DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null) {
      setState(() => _dob = pickedDate);
    }
  }

  Future<void> _saveProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _isSaving = true);

    String? photoUrl = widget.currentData["profilePic"];

    if (_profileImage != null) {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child("profile_pics")
          .child("${user.uid}.jpg");

      await storageRef.putFile(_profileImage!);
      photoUrl = await storageRef.getDownloadURL();
    }

    await FirebaseFirestore.instance.collection("users").doc(user.uid).set({
      "name": _nameController.text,
      "username": _usernameController.text,
      "phone": "$_selectedDialCode${_phoneController.text.trim()}",
      "dob": _dob?.toIso8601String(),
      "profilePic": photoUrl,
    }, SetOptions(merge: true));

    setState(() => _isSaving = false);

    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Profile")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // 🔹 Profile Picture
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: _profileImage != null
                      ? FileImage(_profileImage!)
                      : (widget.currentData["profilePic"] != null
                          ? NetworkImage(widget.currentData["profilePic"])
                          : const AssetImage("assets/images/profile.jpg")
                              as ImageProvider),
                  child: const Align(
                    alignment: Alignment.bottomRight,
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.blue,
                      child:
                          Icon(Icons.camera_alt, size: 18, color: Colors.white),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: "Full Name"),
                validator: (val) =>
                    val == null || val.isEmpty ? "Enter your name" : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(labelText: "Username"),
                validator: (val) =>
                    val == null || val.isEmpty ? "Enter your username" : null,
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  CountryCodePicker(
                    onChanged: (code) {
                      setState(() => _selectedDialCode = code.dialCode ?? "+234");
                    },
                    initialSelection: _selectedDialCode,
                    favorite: const ['+234', 'NG', '+1', 'US'],
                    showCountryOnly: false,
                    alignLeft: false,
                  ),
                  Expanded(
                    child: TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: "Phone Number",
                      ),
                      validator: (val) => val == null || val.isEmpty
                          ? "Enter your phone number"
                          : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              ListTile(
                title: const Text("Date of Birth"),
                subtitle: Text(
                  _dob != null
                      ? "${_dob!.day}/${_dob!.month}/${_dob!.year}"
                      : "Select your date of birth",
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: _pickDOB,
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving
                      ? null
                      : () {
                          if (_formKey.currentState!.validate()) {
                            _saveProfile();
                          }
                        },
                  child: _isSaving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Save Changes"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
