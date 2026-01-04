import 'package:get/get.dart';
import '../../controllers/tabungan_controllers.dart';
import 'package:flutter/material.dart';
import '../widgets/drawer_kustom.dart';
import '../widgets/app_bar_kustom.dart';
import '../../models/tabungan_models.dart';
import 'tabungan_card.dart';
import 'tabungan_form.dart';
import 'isi_tabungan_form.dart';
import 'riwayat_tabungan_model.dart';



class TampilanTabungan extends StatefulWidget {
  const TampilanTabungan({super.key});

  @override
  State<TampilanTabungan> createState() => _TampilanTabunganState();
}

class _TampilanTabunganState extends State<TampilanTabungan> {
  final KontrolerTabungan tabunganC = Get.find<KontrolerTabungan>();


  final List<RiwayatTabungan> riwayatList = [];



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarKustom(title: 'Tabungan'),
      drawer: DrawerKustom(),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ===============================
          // TOTAL TABUNGAN
          // ===============================
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Obx(() {
                if (tabunganC.loading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (tabunganC.tabunganList.isEmpty) {
                  return const Text('Belum ada tabungan');
                }

                // Ambil total (contoh: dari target pertama)
                final totalTarget = tabunganC.tabunganList
                    .fold<double>(0, (sum, e) => sum + e.targetAmount);

                final totalCurrent = tabunganC.tabunganList
                    .fold<double>(0, (sum, e) => sum + e.currentAmount);

                double progress = 0;

                if (totalTarget > 0 && totalCurrent >= 0) {
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
                    Text(
                      'Rp ${totalCurrent.toInt()} / Rp ${totalTarget.toInt()}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    LinearProgressIndicator(value: progress),
                  ],
                );
              }),
            ),
          ),


          const SizedBox(height: 20),

          // ===============================
          // TARGET TABUNGAN
          // ===============================
          const Text(
            'Target Tabungan',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          Obx(() {
            if (tabunganC.loading.value) {
              return const Center(child: CircularProgressIndicator());
            }

            if (tabunganC.tabunganList.isEmpty) {
              return const Text('Belum ada target tabungan');
            }

            return Column(
              children: tabunganC.tabunganList
                  .map((e) => TabunganCard(data: e))
                  .toList(),
            );
          }),


          const SizedBox(height: 20),

          // ===============================
          // TOMBOL TAMBAH TARGET
          // ===============================
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TabunganForm(),
                ),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Tambah Target Tabungan'),
          ),

          const SizedBox(height: 12),

          // ===============================
          // TOMBOL ISI TABUNGAN
          // ===============================
          ElevatedButton.icon(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const IsiTabunganForm(),
                ),
              );

              if (result != null) {
                setState(() {
                  riwayatList.add(result);
                });
              }
            },
            icon: const Icon(Icons.savings),
            label: const Text('Isi Tabungan'),
          ),

          const SizedBox(height: 20),

          // ===============================
          // RIWAYAT TABUNGAN
          // ===============================
          const Text(
            'Riwayat Tabungan',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          if (riwayatList.isEmpty)
            const Text('Belum ada riwayat tabungan'),

          ...riwayatList.map(
                (e) => Card(
              child: ListTile(
                title: Text('Rp ${e.nominal}'),
                subtitle: Text(
                  '${e.catatan}\n${e.tanggal.toString().split(' ')[0]}',
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    setState(() {
                      riwayatList.remove(e);
                    });
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
