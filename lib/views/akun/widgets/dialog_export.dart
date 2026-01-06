import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../controllers/akun_controllers.dart';

class DialogExport extends StatefulWidget {
  const DialogExport({super.key});

  @override
  State<DialogExport> createState() => _DialogExportState();
}

class _DialogExportState extends State<DialogExport> {
  DateTime selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Ekspor Laporan Bulanan',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: selectedDate.month,
                    items: List.generate(12, (index) {
                      return DropdownMenuItem(
                        value: index + 1,
                        child: Text(
                          DateFormat(
                            'MMMM',
                            'id_ID',
                          ).format(DateTime(2024, index + 1)),
                        ),
                      );
                    }),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          selectedDate = DateTime(selectedDate.year, val);
                        });
                      }
                    },
                    decoration: InputDecoration(
                      labelText: 'Bulan',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: selectedDate.year,
                    items: List.generate(5, (index) {
                      final year = DateTime.now().year - 2 + index;
                      return DropdownMenuItem(
                        value: year,
                        child: Text(year.toString()),
                      );
                    }),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          selectedDate = DateTime(val, selectedDate.month);
                        });
                      }
                    },
                    decoration: InputDecoration(
                      labelText: 'Tahun',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Get.back(),
                  child: const Text('Batal'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    Get.back();
                    Get.find<KontrolerAkun>().generatePdf(selectedDate);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Cetak PDF'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
