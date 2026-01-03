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

  // Mark as Paid and Handle Recurrence
  Future<void> markAsPaid(String id, bool isPaid) async {
    final docRef = _schedulesRef.doc(id);
    await docRef.update({'isPaid': isPaid});

    // Logic for Recurring Payments (Cloud Function Simulation)
    if (isPaid) {
      final doc = await docRef.get();
      final data = doc.data() as Map<String, dynamic>;
      final String recurrence = data['recurrence'] ?? 'none';

      if (recurrence != 'none') {
        final DateTime currentDueDate = (data['dueDate'] as Timestamp).toDate();
        DateTime? nextDate;

        if (recurrence == 'daily') {
          nextDate = currentDueDate.add(Duration(days: 1));
        } else if (recurrence == 'weekly') {
          nextDate = currentDueDate.add(Duration(days: 7));
        } else if (recurrence == 'monthly') {
          // Add 1 month safely
          nextDate = DateTime(
            currentDueDate.year,
            currentDueDate.month + 1,
            currentDueDate.day,
            currentDueDate.hour,
            currentDueDate.minute,
          );
        }

        if (nextDate != null) {
          // Create next schedule
          final newSchedule = ModelJadwalPembayaran(
            id: '', // Auto-ID
            name: data['name'],
            amount: (data['amount'] as num).toDouble(),
            dueDate: nextDate,
            isPaid: false,
            category: data['category'],
            notes: data['notes'],
            recurrence: recurrence, // Pass the torch
          );

          await addSchedule(newSchedule);

          // Optional: Disable recurrence on the old one to prevent double-spawning if toggled
          // await docRef.update({'recurrence': 'none'});
        }
      }
    }
  }

  // Delete Schedule
  Future<void> deleteSchedule(String id) async {
    await _schedulesRef.doc(id).delete();
  }
}
