import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../models/jadwal_pembayaran_models.dart';

class KartuJadwalPembayaran extends StatelessWidget {
  final List<ModelJadwalPembayaran> schedules;

  const KartuJadwalPembayaran({super.key, required this.schedules});

  @override
  Widget build(BuildContext context) {
    // Format Mata Uang
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    // Format Tanggal Lengkap (Indonesia)
    final dateFormat = DateFormat('dd MMMM yyyy', 'id_ID');

    // Tanggal Hari Ini (untuk cek telat bayar)
    final now = DateTime.now();
    // Normalisasi 'now' agar jam/menit tidak mempengaruhi perbandingan tanggal
    final today = DateTime(now.year, now.month, now.day);

    return Container(
      // Tinggi dibatasi agar hanya muat sekitar 2 item + header.
      // Sisanya akan bisa di-scroll di dalam widget ini.
      height: 190,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Jadwal Pembayaran',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              GestureDetector(
                onTap: () => Get.toNamed('/jadwal'),
                child: Text(
                  'Lihat Semua',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),

          // Body List (Scrollable)
          Expanded(
            child: schedules.isEmpty
                ? Center(
                    child: Text(
                      "Tidak ada jadwal",
                      style: TextStyle(
                        color: Theme.of(context).hintColor,
                        fontSize: 12,
                      ),
                    ),
                  )
                : ListView.builder(
                    // physics: BouncingScrollPhysics(), // Opsional: Efek mental saat scroll
                    itemCount: schedules.length,
                    itemBuilder: (context, index) {
                      final schedule = schedules[index];

                      // --- LOGIKA WARNA ---
                      // Cek apakah tanggal jadwal sudah lewat dari hari ini
                      // (DueDate < Today)
                      final isOverdue = schedule.dueDate.isBefore(today);

                      Color textColor;

                      if (schedule.isPaid) {
                        // Jika sudah bayar -> Hijau/Primary (mengikuti konvensi sukses/selesai)
                        // atau biarkan default text color, tapi dikasih indikator
                        // Disini kita pakai warna body text biasa atau hint untuk paid
                        textColor =
                            Theme.of(context).textTheme.bodyMedium?.color ??
                            Colors.black;
                      } else if (isOverdue) {
                        // Jika belum bayar DAN lewat tanggal -> Merah
                        textColor = Theme.of(context).colorScheme.error;
                      } else {
                        // Belum bayar tapi belum lewat (Upcoming) -> Default Text Color
                        textColor =
                            Theme.of(context).textTheme.bodyMedium?.color ??
                            Colors.black;
                      }

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Kolom Kiri: Nama & Tanggal
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    schedule.name,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: textColor, // Terapkan warna
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    dateFormat.format(schedule.dueDate),
                                    style: TextStyle(
                                      // Warna tanggal sedikit lebih transparan
                                      color: textColor.withValues(alpha: 0.7),
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Kolom Kanan: Nominal
                            Text(
                              currencyFormat.format(schedule.amount),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: textColor, // Terapkan warna
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
