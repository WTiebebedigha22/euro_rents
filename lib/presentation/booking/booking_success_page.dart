import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BookingSuccessPage extends StatelessWidget {
  final String? carName;
  final String? bookingId;

  const BookingSuccessPage({super.key, this.carName, this.bookingId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.check_circle_outline,
                color: Colors.green,
                size: 120,
              ),
              const SizedBox(height: 24),
              Text(
                "Booking Confirmed!",
                style: GoogleFonts.roboto(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              if (carName != null)
                Text(
                  "Your $carName has been successfully booked.",
                  style: GoogleFonts.roboto(fontSize: 18),
                  textAlign: TextAlign.center,
                ),

              if (bookingId != null) ...[
                const SizedBox(height: 12),
                Text(
                  "Booking ID: $bookingId",
                  style: GoogleFonts.roboto(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],

              const SizedBox(height: 24),
              Text(
                "Thank you for booking with us. Your car will be ready at the scheduled date.",
                style: GoogleFonts.roboto(fontSize: 16),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Back to Home",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
