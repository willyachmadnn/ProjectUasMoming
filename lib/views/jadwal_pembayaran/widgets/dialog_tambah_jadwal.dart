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
  final _notesController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String _selectedCategory = 'Tagihan'; // Default
  String _recurrence = 'none'; // Default recurrence

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
      _notesController.text = widget.schedule!.notes ?? '';
      _selectedDate = widget.schedule!.dueDate;
      _selectedCategory = widget.schedule!.category ?? 'Tagihan';
      _recurrence = widget.schedule!.recurrence;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Theme.of(context).cardColor,
      child: Container(
        width: context.width > 400 ? 400 : context.width * 0.9,
        constraints: BoxConstraints(maxHeight: context.height * 0.8),
        padding: EdgeInsets.all(24),
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
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                SizedBox(height: 24),

                // Nama Tagihan
                TextFormField(
                  controller: _nameController,
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Nama Tagihan',
                    prefixIcon: Icon(Icons.description),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  validator: (val) =>
                      val == null || val.isEmpty ? 'Wajib diisi' : null,
                ),
                SizedBox(height: 16),

                // Nominal
                TextFormField(
                  controller: _amountController,
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Estimasi Nominal',
                    prefixIcon: Icon(Icons.attach_money),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixText: 'Rp ',
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [CurrencyInputFormatter()],
                  validator: (val) {
                    if (val == null || val.isEmpty) return 'Wajib diisi';
                    final numStr = val.replaceAll(RegExp(r'[^0-9]'), '');
                    return numStr.isEmpty ? 'Invalid amount' : null;
                  },
                ),
                SizedBox(height: 16),

                // Kategori
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: InputDecoration(
                    labelText: 'Kategori',
                    prefixIcon: Icon(Icons.category),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  items: ['Tagihan', 'Cicilan', 'Langganan', 'Lainnya']
                      .map(
                        (cat) => DropdownMenuItem(value: cat, child: Text(cat)),
                      )
                      .toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedCategory = val);
                  },
                ),
                SizedBox(height: 16),

                // Ulangi (Recurrence)
                DropdownButtonFormField<String>(
                  value: _recurrence,
                  decoration: InputDecoration(
                    labelText: 'Ulangi',
                    prefixIcon: Icon(Icons.repeat),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
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
                              value: item['val'],
                              child: Text(item['label']!),
                            ),
                          )
                          .toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _recurrence = val);
                  },
                ),
                SizedBox(height: 16),

                // Jatuh Tempo
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
                      prefixIcon: Icon(Icons.calendar_today),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      DateFormat('dd MMMM yyyy', 'id_ID').format(_selectedDate),
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16),

                // Catatan
                TextFormField(
                  controller: _notesController,
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Catatan',
                    prefixIcon: Icon(Icons.note),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  maxLines: 3,
                ),
                SizedBox(height: 24),

                // Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: Text('Batal'),
                    ),
                    SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          final amountStr = _amountController.text.replaceAll(
                            RegExp(r'[^0-9]'),
                            '',
                          );
                          final schedule = ModelJadwalPembayaran(
                            id: widget.schedule?.id ?? '',
                            name: _nameController.text,
                            amount: double.parse(amountStr),
                            dueDate: _selectedDate,
                            isPaid: widget.schedule?.isPaid ?? false,
                            category: _selectedCategory,
                            notes: _notesController.text,
                            recurrence: _recurrence,
                          );

                          if (widget.schedule == null) {
                            widget.controller.addSchedule(schedule);
                          } else {
                            widget.controller.updateSchedule(schedule);
                          }
                          Get.back();
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
}
