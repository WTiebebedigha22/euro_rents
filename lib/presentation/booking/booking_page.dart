import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../data/models/car.dart';
import 'booking_summary_page.dart';

class BookingPage extends StatefulWidget {
  final Car car;

  const BookingPage({super.key, required this.car});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  DateTime? _startDate;
  DateTime? _endDate;
  double _totalPrice = 0.0;

  final DateFormat _formatter = DateFormat('dd-MM-yyyy');

  /// Calculate total price
  void _calculateTotalPrice() {
    if (_startDate != null && _endDate != null) {
      final days = _endDate!.difference(_startDate!).inDays + 1; // inclusive
      setState(() {
        _totalPrice = days * widget.car.pricePerDay;
      });
    } else {
      setState(() => _totalPrice = 0.0);
    }
  }

  Future<void> _selectStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        _startDate = picked;
        if (_endDate != null && _endDate!.isBefore(_startDate!)) {
          _endDate = _startDate;
        }
      });
      _calculateTotalPrice();
    }
  }

  Future<void> _selectEndDate() async {
    final initial = _endDate ?? _startDate ?? DateTime.now();
    final first = _startDate ?? DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: first,
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() => _endDate = picked);
      _calculateTotalPrice();
    }
  }

  /// Handle image
  Widget _buildImage() {
    final image = widget.car.imageUrl.trim();

    if (image.isEmpty) return _placeholder();

    if (image.startsWith('http')) {
      return Image.network(
        image,
        width: double.infinity,
        height: 220,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => _placeholder(),
      );
    }

    return Image.asset(
      image,
      width: double.infinity,
      height: 220,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => _placeholder(),
    );
  }

  Widget _placeholder() {
    return Container(
      width: double.infinity,
      height: 220,
      color: Colors.grey.shade200,
      child: const Center(
        child: Icon(Icons.directions_car, size: 64, color: Colors.black45),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Book ${widget.car.name}"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: _buildImage(),
            ),
            const SizedBox(height: 16),

            // Car Info
            Text(
              widget.car.name,
              style: GoogleFonts.roboto(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              "£${widget.car.pricePerDay}/day",
              style: GoogleFonts.roboto(fontSize: 20, color: Colors.blueAccent, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 24),

            // Start Date
            ListTile(
              title: const Text("Start Date"),
              subtitle: Text(
                _startDate != null ? _formatter.format(_startDate!) : "Select start date",
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: _selectStartDate,
            ),
            const Divider(),

            // End Date
            ListTile(
              title: const Text("End Date"),
              subtitle: Text(
                _endDate != null ? _formatter.format(_endDate!) : "Select end date",
              ),
              trailing: const Icon(Icons.calendar_month),
              onTap: _selectEndDate,
            ),
            const Divider(),

            const SizedBox(height: 16),

            // Total Price
            Center(
              child: Text(
                "Total Price: £${_totalPrice.toStringAsFixed(2)}",
                style: GoogleFonts.roboto(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 30),

            // Proceed Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (_startDate != null && _endDate != null)
                    ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BookingSummaryPage(
                              car: widget.car,
                              startDate: _startDate!,
                              endDate: _endDate!,
                              totalPrice: _totalPrice,
                            ),
                          ),
                        );
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Proceed to Summary",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
