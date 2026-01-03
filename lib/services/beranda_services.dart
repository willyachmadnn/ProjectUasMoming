import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/transaksi_models.dart';
import '../models/tabungan_models.dart';
import '../models/jadwal_pembayaran_models.dart';

class LayananBeranda {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Helper: Pastikan selalu ambil UID user yang login
  String get _uid => _auth.currentUser?.uid ?? '';

  // 1. Ambil 5 Transaksi Terakhir (Hanya milik User ini)
  Stream<List<ModelTransaksi>> getRecentTransactions() {
    if (_uid.isEmpty) return Stream.value([]);

    return _db
        .collection('transactions') // Updated to Root Collection
        .where('uid', isEqualTo: _uid) // Filter by UID
        .orderBy('date', descending: true)
        .limit(5)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ModelTransaksi.fromFirestore(doc))
              .toList(),
        );
  }

  // 2. Hitung Ringkasan Keuangan (Pemasukan, Pengeluaran, Saldo)
  Stream<Map<String, dynamic>> getFinancialSummary() {
    if (_uid.isEmpty) return Stream.value({});

    // Kita ambil semua transaksi user ini untuk dihitung totalnya
    return _db
        .collection('transactions') // Updated to Root Collection
        .where('uid', isEqualTo: _uid) // Filter by UID
        .snapshots()
        .map((snapshot) {
          double income = 0;
          double expense = 0;

          for (var doc in snapshot.docs) {
            final data = doc.data();
            // Cek tipe: jika income tambah ke income, jika expense tambah ke expense
            // Pastikan field 'type' atau 'isExpense' sesuai dengan Model Anda
            // Di sini saya asumsi pakai 'type' string seperti diskusi sebelumnya
            bool isExpense =
                data['type'] == 'expense' || data['isExpense'] == true;
            double amount = (data['amount'] ?? 0).toDouble();

            if (isExpense) {
              expense += amount;
            } else {
              income += amount;
            }
          }

          return {
            'income': income,
            'expense': expense,
            'balance': income - expense,
          };
        });
  }

  // 3. Ambil Jadwal Pembayaran (User ini saja)
  Stream<List<ModelJadwalPembayaran>> getUpcomingSchedules() {
    return _db
        .collection(
          'payment_schedules',
        ) // Sesuai dengan jadwal_pembayaran_services.dart
        .where('uid', isEqualTo: _uid) // Filter by UID
        .where('isPaid', isEqualTo: false) // Hanya yang belum dibayar
        .orderBy('dueDate')
        .limit(3)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ModelJadwalPembayaran.fromFirestore(doc))
              .toList(),
        );
  }

  // 4. Ambil Target Tabungan (User ini saja)
  Stream<List<ModelTabungan>> getSavingsGoals() {
    return _db
        .collection('savings_goals') // Sesuai dengan tabungan_services.dart
        .where('uid', isEqualTo: _uid) // Filter by UID
        .limit(3)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ModelTabungan.fromFirestore(doc))
              .toList(),
        );
  }

  // ... (Method lain seperti getThreeMonthsStats bisa dikosongkan dulu jika belum dipakai)
  Stream<List<Map<String, dynamic>>> getThreeMonthsStats() {
    return Stream.value([]); // Dummy return agar tidak error
  }

  Stream<double> getBudgetLimit() {
    return Stream.value(
      0.0,
    ); // Dummy, karena logic budget sudah di-handle controller
  }
}
