import 'package:cloud_firestore/cloud_firestore.dart';

class ModelTransaksi {
  final String id;
  final String uid;
  final String description;
  final double amount;
  final String category;
  final String type;
  final DateTime date;
  final bool isExpense;

  ModelTransaksi({
    required this.id,
    required this.uid,
    required this.description,
    required this.amount,
    required this.category,
    required this.type,
    required this.date,
    required this.isExpense,
  });

  factory ModelTransaksi.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ModelTransaksi(
      id: doc.id,
      uid: data['uid'] ?? '',
      description: data['description'] ?? '',
      amount: (data['amount'] ?? 0).toDouble(),
      category: data['category'] ?? 'Other',
      type: data['type'] ?? (data['isExpense'] == true ? 'expense' : 'income'),
      date: (data['date'] as Timestamp).toDate(),
      isExpense: data['isExpense'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'description': description,
      'amount': amount,
      'category': category,
      'type': type,
      'date': Timestamp.fromDate(date),
      'isExpense': isExpense,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
