import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/transaksi_models.dart';
import '../models/tabungan_models.dart';
import '../models/jadwal_pembayaran_models.dart';

class LayananBeranda {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String get _uid => _auth.currentUser?.uid ?? '';

  Stream<List<ModelTransaksi>> getRecentTransactions() {
    if (_uid.isEmpty) return Stream.value([]);

    return _db
        .collection('transactions')
        .where('uid', isEqualTo: _uid)
        .orderBy('date', descending: true)
        .limit(5)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ModelTransaksi.fromFirestore(doc))
              .toList(),
        );
  }

  Stream<List<ModelTransaksi>> getAllTransactions() {
    if (_uid.isEmpty) return Stream.value([]);

    return _db
        .collection('transactions')
        .where('uid', isEqualTo: _uid)
        .orderBy('date', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ModelTransaksi.fromFirestore(doc))
              .toList(),
        );
  }

  Stream<Map<String, dynamic>> getFinancialSummary() {
    return getAllTransactions().map((transactions) {
       double income = 0;
       double expense = 0;

       for (var tx in transactions) {
         if (tx.isExpense) {
           expense += tx.amount;
         } else {
           income += tx.amount;
         }
       }

       return {
         'income': income,
         'expense': expense,
         'balance': income - expense,
       };
    });
  }

  Stream<List<ModelJadwalPembayaran>> getUpcomingSchedules() {
    return _db
        .collection(
          'payment_schedules',
        )
        .where('uid', isEqualTo: _uid)
        .where('isPaid', isEqualTo: false)
        .orderBy('dueDate')
        .limit(3)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ModelJadwalPembayaran.fromFirestore(doc))
              .toList(),
        );
  }

  Stream<List<ModelTabungan>> getSavingsGoals() {
    return _db
        .collection('savings_goals')
        .where('uid', isEqualTo: _uid)
        .limit(3)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ModelTabungan.fromFirestore(doc))
              .toList(),
        );
  }

  Stream<List<Map<String, dynamic>>> getThreeMonthsStats() {
    return Stream.value([]);
  }

  Stream<double> getBudgetLimit() {
    return Stream.value(
      0.0,
    );
  }
}
