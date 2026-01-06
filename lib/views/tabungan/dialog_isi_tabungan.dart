import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controllers/tabungan_controllers.dart';
import '../../models/tabungan_models.dart';
import '../../utils/currency_formatter.dart';

class DialogIsiTabungan extends StatefulWidget {
  final ModelTabungan? initialTabungan;

  const DialogIsiTabungan({super.key, this.initialTabungan});

  @override
  State<DialogIsiTabungan> createState() => _DialogIsiTabunganState();
}

class _DialogIsiTabunganState extends State<DialogIsiTabungan> {
  final _formKey = GlobalKey<FormState>();
  final _nominalController = TextEditingController();
  final _catatanController = TextEditingController();
  final KontrolerTabungan controller = Get.find<KontrolerTabungan>();

  String? selectedTabunganId;

  @override
  void initState() {
    super.initState();
    if (widget.initialTabungan != null) {
      selectedTabunganId = widget.initialTabungan!.id;
    } else if (controller.tabunganList.length == 1) {
      selectedTabunganId = controller.tabunganList.first.id;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Isi Tabungan',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              if (controller.tabunganList.isNotEmpty) ...[
                DropdownButtonFormField<String>(
                  initialValue: selectedTabunganId,
                  decoration: InputDecoration(
                    labelText: 'Pilih Target Tabungan',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  items: controller.tabunganList.map((tabungan) {
                    return DropdownMenuItem(
                      value: tabungan.id,
                      child: Text(
                        "${tabungan.title} (Sisa: ${NumberFormat.compactCurrency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0).format(tabungan.targetAmount - tabungan.currentAmount)})",
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 14),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedTabunganId = value;
                    });
                  },
                  validator: (value) =>
                      value == null ? 'Pilih tabungan tujuan' : null,
                ),
                const SizedBox(height: 16),
              ],

              TextFormField(
                controller: _nominalController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  CurrencyInputFormatter(),
                ],
                decoration: InputDecoration(
                  labelText: 'Nominal',
                  prefixText: 'Rp ',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) => value == null || value.isEmpty
                    ? 'Nominal wajib diisi'
                    : null,
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _catatanController,
                decoration: InputDecoration(
                  labelText: 'Catatan (Opsional)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
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
                      if (_formKey.currentState!.validate()) {
                        final tabungan = controller.tabunganList.firstWhere(
                          (t) => t.id == selectedTabunganId,
                        );

                        String cleanAmount = _nominalController.text.replaceAll(
                          RegExp(r'[^0-9]'),
                          '',
                        );
                        if (cleanAmount.isEmpty) cleanAmount = '0';

                        controller.isiTabungan(
                          tabungan,
                          double.parse(cleanAmount),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Simpan'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
