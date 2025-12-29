import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../models/jadwal_pembayaran_models.dart';

class KartuJadwalPembayaran extends StatelessWidget {
  final List<ModelJadwalPembayaran> schedules;

  const KartuJadwalPembayaran({super.key, required this.schedules});

  @override
  Widget build(BuildContext context) {
    // Show only top 3
    final displaySchedules = schedules.take(3).toList();

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Jadwal Pembayaran Terdekat',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              TextButton(
                onPressed: () => Get.toNamed('/jadwal'),
                child: Text('Lihat Semua'),
              ),
            ],
          ),
          SizedBox(height: 16),
          if (displaySchedules.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Text(
                  'Tidak ada jadwal pembayaran',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            )
          else
            ...displaySchedules.map(
              (schedule) => _buildScheduleItem(context, schedule),
            ),
        ],
      ),
    );
  }

  Widget _buildScheduleItem(
    BuildContext context,
    ModelJadwalPembayaran schedule,
  ) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    final dateFormat = DateFormat('dd MMM yyyy', 'id_ID');

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.calendar_today,
              color: Theme.of(context).primaryColor,
              size: 20,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  schedule.name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                Text(
                  dateFormat.format(schedule.dueDate),
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            currencyFormat.format(schedule.amount),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
        ],
      ),
    );
  }
}
