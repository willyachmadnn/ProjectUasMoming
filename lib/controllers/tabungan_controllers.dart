import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/tabungan_models.dart';
import '../services/tabungan_services.dart';
import '../views/widgets/snackbar_kustom.dart';

class KontrolerTabungan extends GetxController {
  final LayananTabungan _service = LayananTabungan();
  final RxList<ModelTabungan> tabunganList = <ModelTabungan>[].obs;
  final RxBool loading = true.obs;

  @override
  void onInit() {
    super.onInit();
    bindTabungan();
  }

  void bindTabungan() {
    loading.value = true;
    tabunganList.bindStream(_service.getTabunganStream());
    _service.getTabunganStream().listen((_) {
      loading.value = false;
    }, onError: (e) {
      loading.value = false;
      print("Error stream tabungan: $e");
    });
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
      Get.back();
      SnackbarKustom.sukses('Berhasil', 'Saldo tabungan bertambah');
    } catch (e) {
      SnackbarKustom.error('Gagal', 'Kesalahan saat mengisi tabungan: $e');
    }
  }
}