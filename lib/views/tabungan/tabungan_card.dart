import 'package:flutter/material.dart';
import '../../models/tabungan_models.dart';

class TabunganCard extends StatelessWidget {
  final ModelTabungan data;

  const TabunganCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final persen = (data.progress * 100).toStringAsFixed(0);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              data.title, // ✅ BENAR
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Rp ${data.currentAmount.toStringAsFixed(0)} / Rp ${data.targetAmount.toStringAsFixed(0)}',
            ),
            const SizedBox(height: 10),
            LinearProgressIndicator(value: data.progress),
            const SizedBox(height: 6),
            Text('$persen%'),
          ],
        ),
      ),
    );
  }
}
