import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../data/models/car.dart';
import '../../data/models/booking.dart';
import '../../data/repositories/booking_repository.dart';
import '../../core/services/notification_service.dart';
import 'booking_success_page.dart';

class BookingSummaryPage extends StatefulWidget {
  final Car car;
  final DateTime startDate;
  final DateTime endDate;
  final double totalPrice;

  const BookingSummaryPage({
    super.key,
    required this.car,
    required this.startDate,
    required this.endDate,
    required this.totalPrice,
  });

  @override
  State<BookingSummaryPage> createState() => _BookingSummaryPageState();
}

class _BookingSummaryPageState extends State<BookingSummaryPage> {
  final BookingRepository _bookingRepository = BookingRepository();
  bool _isLoading = false;

  Future<void> _confirmBooking() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      NotificationService.showError("You must be logged in to make a booking.");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final booking = Booking(
      id: '',
      userId: user.uid,
      carId: widget.car.id,
      startDate: widget.startDate,
      endDate: widget.endDate,
      totalPrice: widget.totalPrice,
      status: 'pending',
    );

    try {
      await _bookingRepository.createBooking(booking);
      NotificationService.showSuccess("Booking confirmed!");
      // Navigate to success (replace so user can't re-submit with back)
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const BookingSuccessPage()),
      );
    } catch (e) {
      NotificationService.showError("Failed to create booking: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildImage() {
    final image = widget.car.imageUrl;
    if (image.isNotEmpty && (image.startsWith('http://') || image.startsWith('https://'))) {
      return Image.network(image, height: 140, width: double.infinity, fit: BoxFit.cover);
    } else if (image.isNotEmpty) {
      return Image.asset(image, height: 140, width: double.infinity, fit: BoxFit.cover);
    } else {
      return Container(
        height: 140,
        color: Colors.grey.shade200,
        child: const Center(child: Icon(Icons.directions_car, size: 48)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final start = widget.startDate.toLocal().toString().split(' ')[0];
    final end = widget.endDate.toLocal().toString().split(' ')[0];

    return Scaffold(
      appBar: AppBar(title: const Text("Booking Summary")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(borderRadius: BorderRadius.circular(12), child: _buildImage()),
            const SizedBox(height: 12),
            Text(" ${widget.car.name}",
                style: GoogleFonts.roboto(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text("£${widget.car.pricePerDay}/day",
                style: GoogleFonts.roboto(fontSize: 18, color: Colors.blueAccent)),
            const Divider(height: 32),

            Text("Booking Dates", style: GoogleFonts.roboto(fontSize: 20, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text("Start Date: $start", style: GoogleFonts.roboto(fontSize: 16)),
            Text("End Date: $end", style: GoogleFonts.roboto(fontSize: 16)),
            const SizedBox(height: 8),
            Text("Total Price: £${widget.totalPrice.toStringAsFixed(2)}",
                style: GoogleFonts.roboto(fontSize: 18, fontWeight: FontWeight.bold)),
            const Spacer(),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _confirmBooking,
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                child: _isLoading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator())
                    : const Text("Confirm Booking", style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
