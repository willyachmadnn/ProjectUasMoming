import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../models/tabungan_models.dart';
import '../services/tabungan_services.dart';
import '../views/widgets/snackbar_kustom.dart';

class KontrolerTabungan extends GetxController {
  final LayananTabungan _service = LayananTabungan();
  final RxList<ModelTabungan> tabunganList = <ModelTabungan>[].obs;
  final RxBool loading = true.obs;
  final RxDouble totalTabungan = 0.0.obs;
  final RxDouble monthlyIncrease = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    bindTabungan();
    fetchMonthlyIncrease();
  }

  void bindTabungan() {
    loading.value = true;
    tabunganList.bindStream(_service.getTabunganStream());
    ever(tabunganList, (_) => _calculateTotal());
    _service.getTabunganStream().listen(
      (_) {
        loading.value = false;
      },
      onError: (e) {
        loading.value = false;
        print("Error stream tabungan: $e");
      },
    );
  }

  void _calculateTotal() {
    totalTabungan.value = tabunganList.fold(
      0,
      (sum, item) => sum + item.currentAmount,
    );
  }

  Future<void> fetchMonthlyIncrease() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;

      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

      final query = await FirebaseFirestore.instance
          .collection('transactions')
          .where('uid', isEqualTo: uid)
          .where('category', isEqualTo: 'Tabungan')
          .where('type', isEqualTo: 'expense')
          .where(
            'date',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth),
          )
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endOfMonth))
          .get();

      double total = 0;
      for (var doc in query.docs) {
        total += (doc.data()['amount'] ?? 0).toDouble();
      }
      monthlyIncrease.value = total;
    } catch (e) {
      print("Error fetching monthly increase: $e");
    }
  }

  Future<void> tambahTabungan({
    required String title,
    required double targetAmount,
    required DateTime targetDate,
  }) async {
    try {
      final tabunganBaru = ModelTabungan(
        id: '',
        title: title,
        targetAmount: targetAmount,
        currentAmount: 0,
        targetDate: targetDate,
        createdAt: DateTime.now(),
      );

      await _service.tambahTabungan(tabunganBaru);

      Get.back();
      SnackbarKustom.sukses('Sukses', 'Target tabungan berhasil dibuat');
    } catch (e) {
      SnackbarKustom.error('Gagal', 'Terjadi kesalahan: $e');
    }
  }

  Future<void> editTabungan({
    required String id,
    required String title,
    required double targetAmount,
    required DateTime targetDate,
    required double currentAmount,
    required DateTime createdAt,
  }) async {
    try {
      final tabunganEdit = ModelTabungan(
        id: id,
        title: title,
        targetAmount: targetAmount,
        currentAmount: currentAmount,
        targetDate: targetDate,
        createdAt: createdAt,
      );

      await _service.editTabungan(tabunganEdit);

      Get.back();
      SnackbarKustom.sukses('Sukses', 'Target tabungan berhasil diperbarui');
    } catch (e) {
      SnackbarKustom.error('Gagal', 'Terjadi kesalahan: $e');
    }
  }

  Future<void> hapusTabungan(String id) async {
    try {
      await _service.hapusTabungan(id);
      SnackbarKustom.sukses('Dihapus', 'Target tabungan telah dihapus');
    } catch (e) {
      SnackbarKustom.error('Error', 'Gagal menghapus: $e');
    }
  }

  Future<void> isiTabungan(ModelTabungan tabungan, double nominalIsi) async {
    try {
      double totalBaru = tabungan.currentAmount + nominalIsi;
      await _service.updateNominal(tabungan.id, totalBaru);
      await _service.catatTransaksiTabungan(
        description: 'Isi Tabungan: ${tabungan.title}',
        amount: nominalIsi,
      );
      await fetchMonthlyIncrease();

      Get.back();
      SnackbarKustom.sukses('Berhasil', 'Saldo tabungan bertambah');
    } catch (e) {
      SnackbarKustom.error('Gagal', 'Kesalahan saat mengisi tabungan: $e');
    }
  }
}
