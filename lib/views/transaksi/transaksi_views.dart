import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../widgets/drawer_kustom.dart';
import '../widgets/app_bar_kustom.dart';
import '../../controllers/transaksi_controllers.dart';
import 'widgets/bar_filter_transaksi.dart';
import 'widgets/tabel_transaksi.dart';
import 'widgets/kontrol_paginasi.dart';

class TampilanTransaksi extends StatelessWidget {
  const TampilanTransaksi({super.key});

  @override
  Widget build(BuildContext context) {
    // Inject Controller
    final KontrolerTransaksi controller = Get.put(KontrolerTransaksi());

    return Scaffold(
      appBar: AppBarKustom(title: 'Transaksi'),
      drawer: DrawerKustom(),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Filter Bar
                  BarFilterTransaksi(controller: controller),

                  // Table
                  Obx(() {
                    if (controller.isLoading.value) {
                      return Padding(
                        padding: EdgeInsets.all(40),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    return TabelTransaksi(
                      transactions: controller.transactions,
                      controller: controller,
                    );
                  }),

                  // Pagination
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
