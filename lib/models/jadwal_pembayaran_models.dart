import 'package:cloud_firestore/cloud_firestore.dart';

class ModelJadwalPembayaran {
  final String id;
  final String name;
  final double amount;
  final DateTime dueDate;
  final bool isPaid;
  final String? category;
  final String? notes;
  final String recurrence;

  ModelJadwalPembayaran({
    required this.id,
    required this.name,
    required this.amount,
    required this.dueDate,
    this.isPaid = false,
    this.category,
    this.notes,
    this.recurrence = 'none',
  });

  factory ModelJadwalPembayaran.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ModelJadwalPembayaran(
      id: doc.id,
      name: data['name'] ?? '',
      amount: (data['amount'] ?? 0).toDouble(),
      dueDate: (data['dueDate'] as Timestamp).toDate(),
      isPaid: data['isPaid'] ?? false,
      category: data['category'],
      notes: data['notes'],
      recurrence: data['recurrence'] ?? 'none',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'amount': amount,
      'dueDate': Timestamp.fromDate(dueDate),
      'isPaid': isPaid,
      'category': category,
      'notes': notes,
      'recurrence': recurrence,
    };
  }

  ModelJadwalPembayaran copyWith({
    String? id,
    String? name,
    double? amount,
    DateTime? dueDate,
    bool? isPaid,
    String? category,
    String? notes,
    String? recurrence,
  }) {
    return ModelJadwalPembayaran(
      id: id ?? this.id,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      dueDate: dueDate ?? this.dueDate,
      isPaid: isPaid ?? this.isPaid,
      category: category ?? this.category,
      notes: notes ?? this.notes,
      recurrence: recurrence ?? this.recurrence,
    );
  }
}
