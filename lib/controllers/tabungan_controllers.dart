import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/tabungan_models.dart';

class KontrolerTabungan extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final RxList<ModelTabungan> tabunganList = <ModelTabungan>[].obs;
  final RxBool loading = true.obs;

  @override
  void onInit() {
    super.onInit();
    ambilTabungan();
  }

  void ambilTabungan() {
    _firestore.collection('tabungan').snapshots().listen((snapshot) {
      tabunganList.value = snapshot.docs
          .map((doc) => ModelTabungan.fromFirestore(doc))
          .toList();
      loading.value = false;
    });
  }

  Future<void> tambahTabungan({
    required String title,
    required double targetAmount,
    required DateTime targetDate,
  }) async {
    await _firestore.collection('tabungan').add({
      'title': title,
      'targetAmount': targetAmount,
      'currentAmount': 0,
      'targetDate': Timestamp.fromDate(targetDate),
      'createdAt': Timestamp.now(),
    });
  }
}
