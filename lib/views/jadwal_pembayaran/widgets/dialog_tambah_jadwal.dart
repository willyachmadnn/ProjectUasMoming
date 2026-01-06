import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../controllers/jadwal_pembayaran_controllers.dart';
import '../../../models/jadwal_pembayaran_models.dart';
import '../../../utils/currency_formatter.dart';

class DialogTambahJadwal extends StatefulWidget {
  final KontrolerJadwalPembayaran controller;
  final ModelJadwalPembayaran? schedule;

  const DialogTambahJadwal({
    super.key,
    required this.controller,
    this.schedule,
  });

  @override
  State<DialogTambahJadwal> createState() => _DialogTambahJadwalState();
}

class _DialogTambahJadwalState extends State<DialogTambahJadwal> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String _selectedCategory = 'Lainnya';
  String _recurrence = 'none';

  final List<String> _listKategori = [
    'Cicilan',
    'Langganan',
    'Utilitas',
    'Komunikasi',
    'Pendidikan',
    'Lainnya',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.schedule != null) {
      _nameController.text = widget.schedule!.name;
      final formatter = NumberFormat.currency(
        locale: 'id',
        symbol: '',
        decimalDigits: 0,
      );
      _amountController.text = formatter.format(widget.schedule!.amount);
      _selectedDate = widget.schedule!.dueDate;
      _recurrence = widget.schedule!.recurrence;

      String cat = widget.schedule!.category ?? 'Lainnya';
      if (_listKategori.contains(cat)) {
        _selectedCategory = cat;
      } else {
        _selectedCategory = 'Lainnya';
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: context.width > 400 ? 400 : context.width * 0.9,
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.schedule == null
                      ? 'Tambah Jadwal Baru'
                      : 'Edit Jadwal',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: InputDecoration(
                    labelText: 'Kategori',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: _listKategori
                      .map(
                        (cat) => DropdownMenuItem(value: cat, child: Text(cat)),
                      )
                      .toList(),
                  onChanged: (val) => setState(() => _selectedCategory = val!),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _recurrence,
                  decoration: InputDecoration(
                    labelText: 'Ulangi',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items:
                      [
                            {'val': 'none', 'label': 'Tidak Berulang'},
                            {'val': 'daily', 'label': 'Harian'},
                            {'val': 'weekly', 'label': 'Mingguan'},
                            {'val': 'monthly', 'label': 'Bulanan'},
                          ]
                          .map(
                            (item) => DropdownMenuItem(
                              value: item['val'] as String,
                              child: Text(item['label'] as String),
                            ),
                          )
                          .toList(),
                  onChanged: (val) => setState(() => _recurrence = val!),
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                    );
                    if (picked != null) setState(() => _selectedDate = picked);
                  },
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Jatuh Tempo',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      DateFormat('dd MMMM yyyy', 'id_ID').format(_selectedDate),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Nama Tagihan',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (val) =>
                      val == null || val.isEmpty ? 'Wajib diisi' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _amountController,
                  decoration: InputDecoration(
                    labelText: 'Estimasi Nominal',
                    prefixText: 'Rp ',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    CurrencyInputFormatter(),
                  ],
                  validator: (val) =>
                      val == null || val.isEmpty ? 'Wajib diisi' : null,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: Text(
                        "Batal",
                        style: TextStyle(color: Theme.of(context).primaryColor),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Theme.of(
                          context,
                        ).colorScheme.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          if (widget.schedule != null) {
                            _konfirmasiSimpan();
                          } else {
                            _eksekusiSimpan();
                          }
                        }
                      },
                      child: Text(
                        widget.schedule == null ? 'Simpan' : 'Update',
                      ),
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

  void _konfirmasiSimpan() {
    Get.defaultDialog(
      title: "Konfirmasi",
      middleText: "Simpan perubahan jadwal?",
      textConfirm: "Ya",
      textCancel: "Batal",
      confirmTextColor: Theme.of(context).colorScheme.onPrimary,
      buttonColor: Theme.of(context).primaryColor,
      radius: 12,
      onConfirm: () {
        Get.back();
        _eksekusiSimpan();
      },
    );
  }

  void _eksekusiSimpan() {
    final amount = double.parse(
      _amountController.text.replaceAll(RegExp(r'[^0-9]'), ''),
    );
    final schedule = ModelJadwalPembayaran(
      id: widget.schedule?.id ?? '',
      name: _nameController.text,
      amount: amount,
      dueDate: _selectedDate,
      isPaid: widget.schedule?.isPaid ?? false,
      category: _selectedCategory,
      recurrence: _recurrence,
    );

    if (widget.schedule == null) {
      widget.controller.addSchedule(schedule);
    } else {
      widget.controller.updateSchedule(schedule);
    }
    Get.back();
  }
}
