import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controllers/tabungan_controllers.dart';

class DialogTambahTabungan extends StatefulWidget {
  const DialogTambahTabungan({super.key});

  @override
  State<DialogTambahTabungan> createState() => _DialogTambahTabunganState();
}

class _DialogTambahTabunganState extends State<DialogTambahTabungan> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _targetController = TextEditingController();
  DateTime? _selectedDate;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(20),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tambah Target Tabungan',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _namaController,
                  decoration: InputDecoration(
                    labelText: 'Nama Target',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Wajib diisi' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _targetController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Nominal Target',
                    prefixText: 'Rp ',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Wajib diisi' : null,
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now().add(const Duration(days: 30)),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      setState(() => _selectedDate = picked);
                    }
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Theme.of(context).disabledColor,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          color: Theme.of(context).disabledColor,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          _selectedDate == null
                              ? 'Pilih Tanggal Target'
                              : DateFormat(
                                  'dd MMMM yyyy',
                                  'id_ID',
                                ).format(_selectedDate!),
                          style: TextStyle(
                            color: _selectedDate == null
                                ? Theme.of(context).disabledColor
                                : Theme.of(context).textTheme.bodyMedium?.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (_selectedDate == null)
                  Padding(
                    padding: const EdgeInsets.only(left: 12, top: 4),
                    child: Text(
                      'Wajib dipilih',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                        fontSize: 12,
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
                          if (_selectedDate == null) {
                            Get.snackbar(
                              'Peringatan',
                              'Tanggal target wajib dipilih',
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.error,
                              colorText: Theme.of(context).colorScheme.onError,
                              snackPosition: SnackPosition.BOTTOM,
                              margin: const EdgeInsets.all(20),
                            );
                            return;
                          }

                          final controller =
                              Get.isRegistered<KontrolerTabungan>()
                              ? Get.find<KontrolerTabungan>()
                              : Get.put(KontrolerTabungan());

                          String cleanAmount = _targetController.text
                              .replaceAll(RegExp(r'[^0-9]'), '');
                          if (cleanAmount.isEmpty) cleanAmount = '0';

                          controller.tambahTabungan(
                            title: _namaController.text,
                            targetAmount: double.parse(cleanAmount),
                            targetDate: _selectedDate!,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Theme.of(
                          context,
                        ).colorScheme.onPrimary,
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
      ),
    );
  }
}
