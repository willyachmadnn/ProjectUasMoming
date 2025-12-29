import 'package:cloud_firestore/cloud_firestore.dart';

class ModelTransaksi {
  final String id;
  final String description;
  final double amount;
  final String category;
  final DateTime date;
  final bool isExpense;

  ModelTransaksi({
    required this.id,
    required this.description,
    required this.amount,
    required this.category,
    required this.date,
    required this.isExpense,
  });

  factory ModelTransaksi.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ModelTransaksi(
      id: doc.id,
      description: data['description'] ?? '',
      amount: (data['amount'] ?? 0).toDouble(),
      category: data['category'] ?? 'Other',
      date: (data['date'] as Timestamp).toDate(),
      isExpense: data['isExpense'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'description': description,
      'amount': amount,
      'category': category,
      'date': Timestamp.fromDate(date),
      'isExpense': isExpense,
    };
  }
}
