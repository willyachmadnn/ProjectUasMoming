import 'package:cloud_firestore/cloud_firestore.dart';

class ModelKategori {
  final String id;
  final String name;
  final String type; // 'income' or 'expense'

  ModelKategori({
    required this.id,
    required this.name,
    required this.type,
  });

  factory ModelKategori.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ModelKategori(
      id: doc.id,
      name: data['name'] ?? '',
      type: data['type'] ?? 'expense',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type,
    };
  }
}
