import 'package:flutter/material.dart';
import 'package:get/get.dart';

// Import Controller
import '../../controllers/tabungan_controllers.dart';

// Import Models & Widgets
import '../widgets/drawer_kustom.dart';
import '../widgets/app_bar_kustom.dart';
import 'tabungan_card.dart';
import 'tabungan_form.dart';
import 'isi_tabungan_form.dart';
import '../../controllers/transaksi_controllers.dart';
import '../../models/transaksi_models.dart';

import 'riwayat_tabungan_model.dart';

class TampilanTabungan extends StatefulWidget {
  const TampilanTabungan({super.key});

  @override
  State<TampilanTabungan> createState() => _TampilanTabunganState();
}

class _TampilanTabunganState extends State<TampilanTabungan> {
  final RxList<RiwayatTabungan> riwayatList = <RiwayatTabungan>[].obs;

  @override
  Widget build(BuildContext context) {
    final KontrolerTabungan tabunganC = Get.put(KontrolerTabungan());

    return Scaffold(
      appBar: AppBarKustom(),
      drawer: DrawerKustom(),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Obx(() {
                if (tabunganC.loading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (tabunganC.tabunganList.isEmpty) {
                  return const Center(child: Text('Belum ada tabungan aktif'));
                }

                final totalTarget = tabunganC.tabunganList.fold<double>(
                  0,
                  (sum, e) => sum + e.targetAmount,
                );

                final totalCurrent = tabunganC.tabunganList.fold<double>(
                  0,
                  (sum, e) => sum + e.currentAmount,
                );

                double progress = 0;
                if (totalTarget > 0) {
                  progress = totalCurrent / totalTarget;
                  progress = progress.clamp(0.0, 1.0);
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Total Tabungan',
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Terkumpul: Rp ${totalCurrent.toInt()}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        Text(
                          'Target: Rp ${totalTarget.toInt()}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).textTheme.bodySmall?.color,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Theme.of(context).dividerColor,
                      color: Theme.of(context).colorScheme.primary,
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "${(progress * 100).toStringAsFixed(1)}%",
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                );
              }),
            ),
          ),

          const SizedBox(height: 20),

          const Text(
            'Daftar Target',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),

          Obx(() {
            if (tabunganC.loading.value) {
              return const Center(child: CircularProgressIndicator());
            }

            if (tabunganC.tabunganList.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: Border.all(color: Theme.of(context).dividerColor),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(child: Text('Belum ada target dibuat')),
              );
            }

            return Column(
              children: tabunganC.tabunganList
                  .map((e) => TabunganCard(data: e))
                  .toList(),
            );
          }),

          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  ),
                  onPressed: () {
                    // Perbaikan Navigasi dengan GetX
                    Get.to(() => const TabunganForm());
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Target Baru'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    foregroundColor: Theme.of(context).colorScheme.onSecondary,
                  ),
                  onPressed: () async {
                    final result = await Get.to(() => const IsiTabunganForm());

                    if (result != null && result is RiwayatTabungan) {
                      riwayatList.add(result);
                      final transaksiController =
                          Get.find<KontrolerTransaksi>();
                      final transaksi = ModelTransaksi(
                        id: '',
                        uid: '',
                        description:
                            'Menabung: ${result.nominal}',
                        amount: result.nominal.toDouble(),
                        category: 'Tabungan',
                        type: 'expense',
                        date: result.tanggal,
                        isExpense: true,
                      );

                      await transaksiController.addTransaction(transaksi);
                    }
                  },
                  icon: const Icon(Icons.savings),
                  label: const Text('Nabung'),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),
          const Text(
            'Riwayat Transaksi',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Obx(() {
            if (riwayatList.isEmpty) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(child: Text('Belum ada riwayat transaksi')),
              );
            }

            return Column(
              children: riwayatList.reversed.map((e) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.1),
                      child: Icon(
                        Icons.arrow_upward,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    title: Text(
                      'Rp ${e.nominal.toInt()}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      '${e.catatan}\n${e.tanggal.toString().split(' ')[0]}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                    ),
                    isThreeLine: true,
                    trailing: IconButton(
                      icon: Icon(
                        Icons.delete,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      onPressed: () {
                        riwayatList.remove(e);
                      },
                    ),
                  ),
                );
              }).toList(),
            );
          }),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}
