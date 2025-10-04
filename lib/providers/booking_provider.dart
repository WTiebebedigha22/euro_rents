import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/models/booking.dart';
import '../data/datasources/firebase_booking_data_source.dart';

class BookingProvider extends ChangeNotifier {
  final FirebaseBookingDataSource _bookingDataSource =
      FirebaseBookingDataSource(firestore: FirebaseFirestore.instance);

  List<Booking> _bookings = [];
  List<Booking> get bookings => _bookings;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> loadUserBookings(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _bookings = await _bookingDataSource.getUserBookings(userId);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createBooking(Booking booking) async {
    await _bookingDataSource.createBooking(booking);
    _bookings.add(booking);
    notifyListeners();
  }

  Future<void> updateBookingStatus(String bookingId, String status) async {
    await _bookingDataSource.updateBookingStatus(bookingId, status);
    final index = _bookings.indexWhere((b) => b.id == bookingId);
    if (index != -1) {
      _bookings[index] = Booking(
        id: _bookings[index].id,
        userId: _bookings[index].userId,
        carId: _bookings[index].carId,
        startDate: _bookings[index].startDate,
        endDate: _bookings[index].endDate,
        totalPrice: _bookings[index].totalPrice,
        status: status,
      );
      notifyListeners();
    }
  }
}
