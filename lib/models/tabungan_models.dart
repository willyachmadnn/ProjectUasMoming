import 'package:cloud_firestore/cloud_firestore.dart';

class ModelTabungan {
  final String id;
  final String title;
  final double targetAmount;
  final double currentAmount;
  final DateTime targetDate;

  ModelTabungan({
    required this.id,
    required this.title,
    required this.targetAmount,
    required this.currentAmount,
    required this.targetDate,
  });

  factory ModelTabungan.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ModelTabungan(
      id: doc.id,
      title: data['title'] ?? '',
      targetAmount: (data['targetAmount'] ?? 0).toDouble(),
      currentAmount: (data['currentAmount'] ?? 0).toDouble(),
      targetDate: (data['targetDate'] as Timestamp).toDate(),
    );
  }

  double get progress => currentAmount / targetAmount;
  int get daysRemaining => targetDate.difference(DateTime.now()).inDays;
}
