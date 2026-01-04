import 'package:flutter/material.dart';
import 'package:get/get.dart';
// ABSOLUTE IMPORT
import 'package:financial/controllers/transaksi_controllers.dart';
import 'package:financial/views/widgets/drawer_kustom.dart';
import 'package:financial/views/widgets/app_bar_kustom.dart';

import 'widgets/bar_filter_transaksi.dart';
import 'widgets/tabel_transaksi.dart';
import 'widgets/kontrol_paginasi.dart';
import 'widgets/dialog_transaksi.dart';
// IMPORT HALAMAN ATUR KATEGORI
import 'widgets/atur_kategori_views.dart';

class TampilanTransaksi extends StatelessWidget {
  const TampilanTransaksi({super.key});

  @override
  Widget build(BuildContext context) {
    final KontrolerTransaksi controller = Get.put(KontrolerTransaksi());

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBarKustom(),
      drawer: DrawerKustom(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const BarFilterTransaksi(),

            // TOMBOL AKSI
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Riwayat Transaksi", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    // TOMBOL INI MEMBUKA HALAMAN MANAJEMEN KATEGORI
                    IconButton(
                      onPressed: () => Get.to(() => const AturKategoriViews()),
                      icon: const Icon(Icons.category_outlined),
                      tooltip: "Atur Kategori",
                    ),
                    const SizedBox(width: 8),
                    // TOMBOL TAMBAH TRANSAKSI
                    ElevatedButton.icon(
                      onPressed: () => Get.dialog(DialogTambahTransaksi(controller: controller)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      icon: const Icon(Icons.add, color: Colors.white, size: 18),
                      label: const Text("Transaksi", style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 16),

            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Obx(() {
                    if (controller.isLoading.value) {
                      return const Padding(
                        padding: EdgeInsets.all(40),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    if (controller.transactions.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.all(40),
                        child: Center(child: Text("Tidak ada data transaksi")),
                      );
                    }
                    return TabelTransaksi(
                      transactions: controller.transactions,
                      controller: controller,
                    );
                  }),
                  KontrolPaginasi(controller: controller),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}