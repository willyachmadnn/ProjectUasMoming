import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../models/jadwal_pembayaran_models.dart';

class KartuJadwalPembayaran extends StatelessWidget {
  final List<ModelJadwalPembayaran> schedules;

  const KartuJadwalPembayaran({super.key, required this.schedules});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    final dateFormat = DateFormat('dd MMMM yyyy', 'id_ID');

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return Container(
      height: 190,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                    itemCount: schedules.length,
                    itemBuilder: (context, index) {
                      final schedule = schedules[index];

                      final isOverdue = schedule.dueDate.isBefore(today);

                      Color textColor;

                      if (schedule.isPaid) {
                        textColor =
                            Theme.of(context).textTheme.bodyMedium?.color ??
                            Theme.of(context).primaryColor;
                      } else if (isOverdue) {
                        textColor = Theme.of(context).colorScheme.error;
                      } else {
                        textColor =
                            Theme.of(context).textTheme.bodyMedium?.color ??
                            Theme.of(context).primaryColor;
                      }

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    schedule.name,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: textColor,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    dateFormat.format(schedule.dueDate),
                                    style: TextStyle(
                                      color: textColor.withValues(alpha: 0.7),
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            Text(
                              currencyFormat.format(schedule.amount),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: textColor,
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
