import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/booking.dart';

class FirebaseBookingDataSource {
  final FirebaseFirestore firestore;

  FirebaseBookingDataSource({required this.firestore});

  Future<void> createBooking(Booking booking) async {
    await firestore.collection('bookings').doc(booking.id).set(booking.toMap());
  }

  Future<Booking?> getBooking(String id) async {
    final doc = await firestore.collection('bookings').doc(id).get();
    if (!doc.exists) return null;
    return Booking.fromMap(doc.data()!, doc.id);
  }

  Future<List<Booking>> getUserBookings(String userId) async {
    final snapshot = await firestore.collection('bookings').where('userId', isEqualTo: userId).get();
    return snapshot.docs.map((doc) => Booking.fromMap(doc.data(), doc.id)).toList();
  }

  Stream<List<Booking>> streamCarBookings(String carId) {
    return firestore.collection('bookings').where('carId', isEqualTo: carId).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Booking.fromMap(doc.data(), doc.id)).toList();
    });
  }

  Future<void> updateBookingStatus(String bookingId, String status) async {
    await firestore.collection('bookings').doc(bookingId).update({'status': status});
  }
}
