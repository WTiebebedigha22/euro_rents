import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  bool _obscurePassword = true;

  Future<void> _login() async {
    setState(() => _isLoading = true);
    try {
      final userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final email = userCredential.user?.email ?? "";

      if (mounted) {
        if (email.toLowerCase().contains("admin")) {
          Navigator.pushReplacementNamed(context, "/admin-dashboard");
        } else {
          Navigator.pushReplacementNamed(context, "/home");
        }
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Login failed')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    // Dynamic scaling
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
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: height * 0.9),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Logo + Title
                      Column(
                        children: [
                          Image.asset("assets/logo/bmw.png", height: logoSize),
                          SizedBox(height: height * 0.015),
                          Text(
                            "Bmw Rentals",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.bebasNeue(
                              fontSize: titleFontSize,
                              color: Colors.blue,
                              letterSpacing: 4,
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: height * 0.08),

                      // Email
                      TextField(
                        controller: _emailController,
                        style: TextStyle(color: Colors.white, fontSize: inputFontSize),
                        decoration: InputDecoration(
                          hintText: "Email",
                          hintStyle: TextStyle(color: Colors.grey, fontSize: inputFontSize),
                          filled: true,
                          fillColor: Colors.grey[900]?.withOpacity(0.7),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      SizedBox(height: height * 0.02),

                      // Password
                      TextField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        style: TextStyle(color: Colors.white, fontSize: inputFontSize),
                        decoration: InputDecoration(
                          hintText: "Password",
                          hintStyle: TextStyle(color: Colors.grey, fontSize: inputFontSize),
                          filled: true,
                          fillColor: Colors.grey[900]?.withOpacity(0.7),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_off : Icons.visibility,
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                      ),
                      SizedBox(height: height * 0.03),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            padding: EdgeInsets.symmetric(vertical: height * 0.02),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : Text(
                                  "Sign In",
                                  style: GoogleFonts.roboto(
                                    fontSize: buttonFontSize,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                      SizedBox(height: height * 0.025),

                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, "/forgot-password");
                        },
                        child: Text(
                          "Forgot your password?",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: inputFontSize * 0.9,
                          ),
                        ),
                      ),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "New Here? ",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: inputFontSize * 0.9,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(context, "/register");
                            },
                            child: Text(
                              "Sign up now",
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
          ),
        ],
      ),
    );
  }
}
