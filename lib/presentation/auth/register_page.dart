import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_passwordController.text.trim() !=
        _confirmPasswordController.text.trim()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }
    setState(() => _isLoading = true);

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();
      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      final user = userCredential.user;
      if (user != null) {
        await user.updateDisplayName(_usernameController.text.trim());

        await _addUserDetails(
          userId: user.uid,
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          username: _usernameController.text.trim(),
          email: email,
        );

        if (mounted) {
          Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
        }
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? 'Registration failed')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _addUserDetails({
    required String userId,
    required String firstName,
    required String lastName,
    required String username,
    required String email,
  }) async {
    await FirebaseFirestore.instance.collection('users').doc(userId).set({
      'firstName': firstName,
      'lastName': lastName,
      'username': username,
      'email': email,
      'createdAt': Timestamp.now(),
    });
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String hint,
    required FormFieldValidator<String> validator,
    bool obscure = false,
    VoidCallback? toggle,
    required double fontSize,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      style: TextStyle(color: Colors.white, fontSize: fontSize),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey, fontSize: fontSize * 0.9),
        filled: true,
        fillColor: Colors.grey[900]?.withOpacity(0.7),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        errorStyle: TextStyle(fontSize: fontSize * 0.8),
        suffixIcon: toggle != null
            ? IconButton(
                icon: Icon(
                  obscure ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey,
                ),
                onPressed: toggle,
              )
            : null,
      ),
      validator: validator,
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    // Responsive font sizes and padding
    double basePadding = width * 0.06;
    double inputFontSize = width * 0.04;
    double buttonFontSize = width * 0.045;
    double titleFontSize = width * 0.12;
    double logoSize = width * 0.18;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset("assets/images/background.jpeg", fit: BoxFit.cover),
          Container(color: Colors.black.withOpacity(0.6)),
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: basePadding,
                vertical: height * 0.04,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Logo and Title
                    Image.asset("assets/logo/bmw.png", height: logoSize),
                    SizedBox(height: height * 0.015),
                    Text(
                      "Bmw Rentals",
                      style: GoogleFonts.bebasNeue(
                        fontSize: titleFontSize,
                        color: Colors.blue,
                        letterSpacing: 4,
                      ),
                    ),
                    SizedBox(height: height * 0.06),

                    // Input Fields
                    _buildTextFormField(
                      controller: _firstNameController,
                      hint: "First Name",
                      fontSize: inputFontSize,
                      validator: (value) =>
                          value!.isEmpty ? 'Please enter your first name' : null,
                    ),
                    SizedBox(height: height * 0.018),
                    _buildTextFormField(
                      controller: _lastNameController,
                      hint: "Last Name",
                      fontSize: inputFontSize,
                      validator: (value) =>
                          value!.isEmpty ? 'Please enter your last name' : null,
                    ),
                    SizedBox(height: height * 0.018),
                    _buildTextFormField(
                      controller: _usernameController,
                      hint: "Username",
                      fontSize: inputFontSize,
                      validator: (value) =>
                          value!.isEmpty ? 'Please enter a username' : null,
                    ),
                    SizedBox(height: height * 0.018),
                    _buildTextFormField(
                      controller: _emailController,
                      hint: "Email",
                      fontSize: inputFontSize,
                      validator: (value) {
                        if (value!.isEmpty) return 'Please enter an email';
                        if (!value.contains('@')) return 'Enter a valid email';
                        return null;
                      },
                    ),
                    SizedBox(height: height * 0.018),
                    _buildTextFormField(
                      controller: _passwordController,
                      hint: "Password",
                      obscure: _obscurePassword,
                      toggle: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                      fontSize: inputFontSize,
                      validator: (value) {
                        if (value!.isEmpty) return 'Please enter a password';
                        if (value.length < 6)
                          return 'Password must be at least 6 characters';
                        return null;
                      },
                    ),
                    SizedBox(height: height * 0.018),
                    _buildTextFormField(
                      controller: _confirmPasswordController,
                      hint: "Confirm Password",
                      obscure: _obscureConfirmPassword,
                      toggle: () => setState(() =>
                          _obscureConfirmPassword = !_obscureConfirmPassword),
                      fontSize: inputFontSize,
                      validator: (value) => value!.isEmpty
                          ? 'Please confirm your password'
                          : null,
                    ),
                    SizedBox(height: height * 0.03),

                    // Sign Up Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _register,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: EdgeInsets.symmetric(
                              vertical: height * 0.02),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : Text(
                                "Sign Up",
                                style: GoogleFonts.roboto(
                                  fontSize: buttonFontSize,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                    SizedBox(height: height * 0.04),

                    // Link to Sign In Page
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Already have an account? ",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: inputFontSize * 0.9,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Text(
                            "Sign In",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: inputFontSize,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
