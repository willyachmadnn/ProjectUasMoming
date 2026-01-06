import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart';

// Import Controller
import '../../controllers/tabungan_controllers.dart';

// Import Models & Widgets
import '../widgets/drawer_kustom.dart';
import '../widgets/app_bar_kustom.dart';
import 'tabungan_card.dart';
import 'tabungan_form.dart';
import 'dialog_isi_tabungan.dart';
import 'dialog_edit_tabungan.dart';
import 'package:financial/views/dashboard/widgets/grafik_batang_tabungan.dart';

class TampilanTabungan extends StatelessWidget {
  const TampilanTabungan({super.key});

  @override
  Widget build(BuildContext context) {
    final KontrolerTabungan tabunganC = Get.put(KontrolerTabungan());

    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Scaffold(
      appBar: AppBarKustom(),
      drawer: DrawerKustom(),
      body: RefreshIndicator(
        onRefresh: () async {
          tabunganC.bindTabungan();
          tabunganC.fetchMonthlyIncrease();
        },
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(
                      context,
                    ).primaryColor.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  Text(
                    'Total Tabungan Anda',
                    style: TextStyle(
                      color: Theme.of(
                        context,
                      ).colorScheme.onPrimary.withValues(alpha: 0.7),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Obx(
                    () => Text(
                      currencyFormat.format(tabunganC.totalTabungan.value),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Obx(() {
                    final increase = tabunganC.monthlyIncrease.value;
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.onPrimary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '(+${currencyFormat.format(increase)} bulan ini)',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),

            const SizedBox(height: 30),

            const Text(
              'Daftar Tabungan Saya',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            Obx(() {
              if (tabunganC.loading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (tabunganC.tabunganList.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(30),
                  alignment: Alignment.center,
                  child: Column(
                    children: [
                      Icon(
                        Icons.savings_outlined,
                        size: 60,
                        color: Theme.of(context).disabledColor,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Belum ada target tabungan',
                        style: TextStyle(color: Theme.of(context).hintColor),
                      ),
                    ],
                  ),
                );
              }

              return Column(
                children: tabunganC.tabunganList.map((data) {
                  return TabunganCard(
                    data: data,
                    onTap: () => _showTabunganActionDialog(context, data),
                  );
                }).toList(),
              );
            }),

            const SizedBox(height: 80),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.dialog(const DialogTambahTabungan()),
        backgroundColor: Theme.of(context).primaryColor,
        child: Icon(Icons.add, color: Theme.of(context).colorScheme.onPrimary),
      ),
    );
  }

  void _showTabunganActionDialog(BuildContext context, var tabungan) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Theme.of(context).disabledColor.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text(
              tabungan.title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.info.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.add, color: AppTheme.info),
              ),
              title: const Text('Isi Tabungan'),
              onTap: () {
                Get.back();
                Get.dialog(DialogIsiTabungan(initialTabungan: tabungan));
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.edit, color: AppTheme.warning),
              ),
              title: const Text('Edit Target'),
              onTap: () {
                Get.back();
                Get.dialog(DialogEditTabungan(tabungan: tabungan));
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.delete,
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
              title: const Text('Hapus Tabungan'),
              onTap: () {
                Get.back();
                Get.defaultDialog(
                  title: 'Hapus Tabungan',
                  middleText: 'Apakah Anda yakin ingin menghapus tabungan ini?',
                  textConfirm: 'Ya, Hapus',
                  textCancel: 'Batal',
                  confirmTextColor: Theme.of(context).colorScheme.onPrimary,
                  buttonColor: Theme.of(context).colorScheme.error,
                  onConfirm: () {
                    Get.find<KontrolerTabungan>().hapusTabungan(tabungan.id);
                    Get.back();
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
