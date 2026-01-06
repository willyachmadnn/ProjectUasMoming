import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/tabungan_models.dart';

class TabunganCard extends StatelessWidget {
  final ModelTabungan data;
  final VoidCallback? onTap;

  const TabunganCard({super.key, required this.data, this.onTap});

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.compactCurrency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    final progressVal = data.progress.isNaN ? 0.0 : data.progress;
    final percentage = (progressVal * 100).toInt();

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.savings_outlined,
                      color: Theme.of(context).primaryColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      data.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Terkumpul: ${currency.format(data.currentAmount)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                    ),
                  ),
                  Text(
                    '$percentage%',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progressVal,
                  minHeight: 8,
                  backgroundColor: Theme.of(context).dividerColor,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'Target: ${currency.format(data.targetAmount)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.color?.withValues(alpha: 0.5),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
