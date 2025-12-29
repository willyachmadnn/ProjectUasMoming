import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/transaksi_models.dart';
import '../models/tabungan_models.dart';
import '../models/jadwal_pembayaran_models.dart';

class LayananBeranda {
  final FirebaseFirestore? _dbInstance;

  LayananBeranda({FirebaseFirestore? db}) : _dbInstance = db;

  FirebaseFirestore get _db {
    if (_dbInstance != null) return _dbInstance;
    if (Firebase.apps.isEmpty) {
      throw FirebaseException(
        plugin: 'core',
        code: 'no-app',
        message: 'Firebase is not initialized',
      );
    }
    return FirebaseFirestore.instance;
  }

  String? get _userId => FirebaseAuth.instance.currentUser?.uid;

  bool get _isFirebaseReady => _dbInstance != null || Firebase.apps.isNotEmpty;

  // Helper to ensure consistency with TransaksiServices
  CollectionReference get _transactionsRef {
    // If userId is null, this would create a random doc ID if called,
    // but we guard against null userId in the methods below.
    return _db.collection('users').doc(_userId).collection('transactions');
  }

  // Stream of recent transactions
  Stream<List<ModelTransaksi>> getRecentTransactions() {
    if (!_isFirebaseReady || _userId == null) return Stream.value([]);
    try {
      return _transactionsRef
          .orderBy('date', descending: true)
          .limit(10)
          .snapshots()
          .map(
            (snapshot) => snapshot.docs
                .map((doc) => ModelTransaksi.fromFirestore(doc))
                .toList(),
          )
          .transform(
            StreamTransformer<
              List<ModelTransaksi>,
              List<ModelTransaksi>
            >.fromHandlers(
              handleError: (error, stackTrace, sink) {
                debugPrint('Error in recent transactions stream: $error');
                sink.add([]); // Emit empty list on error
              },
            ),
          );
    } catch (e) {
      debugPrint('Error getting recent transactions: $e');
      return Stream.value([]);
    }
  }

  // Stream of upcoming schedules
  Stream<List<ModelJadwalPembayaran>> getUpcomingSchedules() {
    if (!_isFirebaseReady || _userId == null) return Stream.value([]);
    try {
      return _db
          .collection('payment_schedules')
          .where('uid', isEqualTo: _userId)
          .where('isPaid', isEqualTo: false)
          .snapshots()
          .map((snapshot) {
            final schedules = snapshot.docs
                .map((doc) => ModelJadwalPembayaran.fromFirestore(doc))
                .toList();
            // Client-side sorting
            schedules.sort((a, b) => a.dueDate.compareTo(b.dueDate));
            return schedules;
          })
          .transform(
            StreamTransformer<
              List<ModelJadwalPembayaran>,
              List<ModelJadwalPembayaran>
            >.fromHandlers(
              handleError: (error, stackTrace, sink) {
                debugPrint('Error in upcoming schedules stream: $error');
                sink.add([]); // Emit empty list on error
              },
            ),
          );
    } catch (e) {
      debugPrint('Error getting upcoming schedules: $e');
      return Stream.value([]);
    }
  }

  // Stream of savings goals
  Stream<List<ModelTabungan>> getSavingsGoals() {
    if (!_isFirebaseReady || _userId == null) return Stream.value([]);
    try {
      return _db
          .collection('savings_goals')
          .where('uid', isEqualTo: _userId)
          .snapshots()
          .map(
            (snapshot) => snapshot.docs
                .map((doc) => ModelTabungan.fromFirestore(doc))
                .toList(),
          )
          .transform(
            StreamTransformer<
              List<ModelTabungan>,
              List<ModelTabungan>
            >.fromHandlers(
              handleError: (error, stackTrace, sink) {
                debugPrint('Error in savings goals stream: $error');
                sink.add([]); // Emit empty list on error
              },
            ),
          );
    } catch (e) {
      debugPrint('Error getting savings goals: $e');
      return Stream.value([]);
    }
  }

  // Financial Summary
  Stream<Map<String, double>> getFinancialSummary() {
    if (!_isFirebaseReady || _userId == null) {
      return Stream.value({'income': 0.0, 'expense': 0.0, 'balance': 0.0});
    }
    try {
      return _transactionsRef
          .snapshots()
          .map((snapshot) {
            double income = 0;
            double expense = 0;

            for (var doc in snapshot.docs) {
              final data = doc.data() as Map<String, dynamic>;
              final amount = (data['amount'] ?? 0).toDouble();
              final isExpense = data['isExpense'] ?? true;

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
          })
          .transform(
            StreamTransformer<
              Map<String, double>,
              Map<String, double>
            >.fromHandlers(
              handleError: (error, stackTrace, sink) {
                debugPrint('Error in financial summary stream: $error');
                sink.add({
                  'income': 0.0,
                  'expense': 0.0,
                  'balance': 0.0,
                }); // Emit zeros on error
              },
            ),
          );
    } catch (e) {
      debugPrint('Error getting financial summary: $e');
      return Stream.value({'income': 0.0, 'expense': 0.0, 'balance': 0.0});
    }
  }

  // 3 Months Stats
  Stream<List<Map<String, dynamic>>> getThreeMonthsStats() {
    if (!_isFirebaseReady || _userId == null) return Stream.value([]);
    try {
      return _transactionsRef
          .snapshots()
          .map((snapshot) {
            final now = DateTime.now();
            final List<DateTime> months = [
              DateTime(now.year, now.month - 2), // 2 months ago
              DateTime(now.year, now.month - 1), // Last month
              DateTime(now.year, now.month), // Current month
            ];
            Map<String, Map<String, dynamic>> stats = {};

            // Initialize stats
            for (var date in months) {
              String key =
                  "${date.year}-${date.month.toString().padLeft(2, '0')}";
              stats[key] = {
                'month': _getMonthName(date.month),
                'year': date.year,
                'income': 0.0,
                'expense': 0.0,
                'date': date,
              };
            }

            for (var doc in snapshot.docs) {
              final data = doc.data() as Map<String, dynamic>;
              final amount = (data['amount'] ?? 0).toDouble();
              final isExpense = data['isExpense'] ?? true;
              final Timestamp? timestamp = data['date'] as Timestamp?;

              if (timestamp != null) {
                DateTime date = timestamp.toDate();
                String key =
                    "${date.year}-${date.month.toString().padLeft(2, '0')}";
                if (stats.containsKey(key)) {
                  if (isExpense) {
                    stats[key]!['expense'] += amount;
                  } else {
                    stats[key]!['income'] += amount;
                  }
                }
              }
            }
            return stats.values.toList();
          })
          .transform(
            StreamTransformer<
              List<Map<String, dynamic>>,
              List<Map<String, dynamic>>
            >.fromHandlers(
              handleError: (error, stackTrace, sink) {
                debugPrint('Error in 3 months stats stream: $error');
                sink.add([]); // Emit empty list on error
              },
            ),
          );
    } catch (e) {
      debugPrint('Error getting 3 months stats: $e');
      return Stream.value([]);
    }
  }

  Stream<double> getBudgetLimit() {
    // Placeholder
    return Stream.value(10000000.0);
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }
}
