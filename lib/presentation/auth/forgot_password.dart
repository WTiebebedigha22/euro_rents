import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _emailController = TextEditingController();
  bool _isLoading = false;

  Future<void> _resetPassword() async {
    setState(() => _isLoading = true);
    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: _emailController.text.trim());

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password reset email sent")),
      );
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Error sending reset email')),
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

    // 🔑 Responsive scaling
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
          // Background Image
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
                    children: [
                      // Logo + Title
                      Column(
                        children: [
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
                        ],
                      ),
                      SizedBox(height: height * 0.06),

                      // Info text
                      Text(
                        "Forgot your password?\nEnter your email to reset it.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: inputFontSize,
                        ),
                      ),
                      SizedBox(height: height * 0.03),

                      // Email input
                      TextField(
                        controller: _emailController,
                        style: TextStyle(color: Colors.white, fontSize: inputFontSize),
                        decoration: InputDecoration(
                          hintText: "Email",
                          hintStyle: TextStyle(
                            color: Colors.grey,
                            fontSize: inputFontSize * 0.9,
                          ),
                          filled: true,
                          fillColor: Colors.grey[900]?.withOpacity(0.7),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      SizedBox(height: height * 0.03),

                      // Reset Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _resetPassword,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            padding: EdgeInsets.symmetric(
                              vertical: height * 0.02,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : Text(
                                  "Reset Password",
                                  style: GoogleFonts.roboto(
                                    fontSize: buttonFontSize,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),

                      SizedBox(height: 15.0),

                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Text(
                          "Continue with Sign In",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: inputFontSize,
                          ),
                        ),
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
