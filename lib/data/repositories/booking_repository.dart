import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/models/booking.dart';

class BookingRepository {
  final FirebaseFirestore _firestore;

  BookingRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<String> createBooking(Booking booking) async {
  try {
    final data = booking.toMap()
      ..['createdAt'] = FieldValue.serverTimestamp();

    final docRef = await _firestore.collection('bookings').add(data);
    return docRef.id;
  } catch (e) {
    throw Exception("Failed to create booking: $e");
  }
}


  Future<List<Booking>> getUserBookings(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('bookings')
          .where('userId', isEqualTo: userId)
          .orderBy('startDate', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => Booking.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception("Failed to fetch bookings: $e");
    }
  }

  Stream<List<Booking>> streamUserBookings(String userId) {
    return _firestore
        .collection('bookings')
        .where('userId', isEqualTo: userId)
        .orderBy('startDate', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Booking.fromMap(doc.data(), doc.id)).toList());
  }

  Future<void> updateBookingStatus(String bookingId, String status) async {
    try {
      await _firestore.collection('bookings').doc(bookingId).update({
        'status': status,
      });
    } catch (e) {
      throw Exception("Failed to update booking status: $e");
    }
  }

  Future<void> deleteBooking(String bookingId) async {
    try {
      await _firestore.collection('bookings').doc(bookingId).delete();
    } catch (e) {
      throw Exception("Failed to delete booking: $e");
    }
  }

  Future<List<Booking>> getCarBookings(String carId) async {
    try {
      final snapshot = await _firestore
          .collection('bookings')
          .where('carId', isEqualTo: carId)
          .orderBy('startDate')
          .get();

      return snapshot.docs
          .map((doc) => Booking.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception("Failed to fetch car bookings: $e");
    }
  }

  Stream<List<Booking>> streamCarBookings(String carId) {
    return _firestore
        .collection('bookings')
        .where('carId', isEqualTo: carId)
        .orderBy('startDate')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Booking.fromMap(doc.data(), doc.id)).toList());
  }
}
