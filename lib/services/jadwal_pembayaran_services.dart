import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/jadwal_pembayaran_models.dart';

class LayananJadwalPembayaran {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? get _userId => FirebaseAuth.instance.currentUser?.uid;

  CollectionReference get _schedulesRef =>
      _firestore.collection('payment_schedules');

  // Get Schedules Stream (ordered by due date)
  Stream<List<ModelJadwalPembayaran>> getSchedules() {
    if (_userId == null) return const Stream.empty();
    
    return _schedulesRef
        .where('uid', isEqualTo: _userId)
        .orderBy('dueDate', descending: false)
        .snapshots()
        .map((
      snapshot,
    ) {
      return snapshot.docs
          .map((doc) => ModelJadwalPembayaran.fromFirestore(doc))
          .toList();
    });
  }

  // Add Schedule
  Future<void> addSchedule(ModelJadwalPembayaran schedule) async {
    if (_userId == null) throw Exception('User not logged in');
    final data = schedule.toJson();
    data['uid'] = _userId;
    await _schedulesRef.add(data);
  }

  // Update Schedule
  Future<void> updateSchedule(ModelJadwalPembayaran schedule) async {
    if (_userId == null) throw Exception('User not logged in');
    final data = schedule.toJson();
    data['uid'] = _userId;
    await _schedulesRef.doc(schedule.id).update(data);
  }

  // Mark as Paid
  Future<void> markAsPaid(String id, bool isPaid) async {
    await _schedulesRef.doc(id).update({'isPaid': isPaid});
  }

  // Delete Schedule
  Future<void> deleteSchedule(String id) async {
    await _schedulesRef.doc(id).delete();
  }
}
