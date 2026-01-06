import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controllers/tabungan_controllers.dart';
import '../../models/tabungan_models.dart';
import '../../utils/currency_formatter.dart';

class DialogEditTabungan extends StatefulWidget {
  final ModelTabungan tabungan;

  const DialogEditTabungan({super.key, required this.tabungan});

  @override
  State<DialogEditTabungan> createState() => _DialogEditTabunganState();
}

class _DialogEditTabunganState extends State<DialogEditTabungan> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _namaController;
  late TextEditingController _targetController;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _namaController = TextEditingController(text: widget.tabungan.title);

    final formattedTarget = NumberFormat.currency(
      locale: 'id_ID',
      symbol: '',
      decimalDigits: 0,
    ).format(widget.tabungan.targetAmount);

    _targetController = TextEditingController(text: formattedTarget);
    _selectedDate = widget.tabungan.targetDate;
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
                'Edit Target Tabungan',
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
                  prefixIcon: const Icon(Icons.title),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _targetController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  CurrencyInputFormatter(),
                ],
                decoration: InputDecoration(
                  labelText: 'Nominal Target',
                  prefixText: 'Rp ',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.attach_money),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate:
                        _selectedDate ??
                        DateTime.now().add(const Duration(days: 30)),
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
                    border: Border.all(color: Theme.of(context).disabledColor),
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
                                'dd MMM yyyy',
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
                      if (_formKey.currentState!.validate() &&
                          _selectedDate != null) {
                        final controller = Get.find<KontrolerTabungan>();
                        String cleanAmount = _targetController.text.replaceAll(
                          RegExp(r'[^0-9]'),
                          '',
                        );
                        if (cleanAmount.isEmpty) cleanAmount = '0';

                        controller.editTabungan(
                          id: widget.tabungan.id,
                          title: _namaController.text,
                          targetAmount: double.parse(cleanAmount),
                          targetDate: _selectedDate!,
                          currentAmount: widget.tabungan.currentAmount,
                          createdAt: widget.tabungan.createdAt,
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
