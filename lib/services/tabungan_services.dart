import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/tabungan_models.dart';

class LayananTabungan {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _uid => _auth.currentUser?.uid;

  CollectionReference get _tabunganRef {
    if (_uid == null) {
      return _firestore.collection('tabungan_guest');
    }
    return _firestore.collection('users').doc(_uid).collection('tabungan');
  }

  Stream<List<ModelTabungan>> getTabunganStream() {
    return _tabunganRef.orderBy('createdAt', descending: true).snapshots().map((
      snapshot,
    ) {
      return snapshot.docs
          .map((doc) => ModelTabungan.fromFirestore(doc))
          .toList();
    });
  }

  Future<void> tambahTabungan(ModelTabungan tabungan) async {
    await _tabunganRef.add(tabungan.toJson());
  }

  Future<void> editTabungan(ModelTabungan tabungan) async {
    await _tabunganRef.doc(tabungan.id).update(tabungan.toJson());
  }

  Future<void> hapusTabungan(String id) async {
    await _tabunganRef.doc(id).delete();
  }

  Future<void> updateNominal(String id, double nominalBaru) async {
    await _tabunganRef.doc(id).update({'currentAmount': nominalBaru});
  }

  Future<void> catatTransaksiTabungan({
    required String description,
    required double amount,
  }) async {
    if (_uid == null) return;

    await _firestore.collection('transactions').add({
      'uid': _uid,
      'description': description,
      'amount': amount,
      'category': 'Tabungan',
      'type': 'expense',
      'isExpense': true,
      'date': Timestamp.now(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
