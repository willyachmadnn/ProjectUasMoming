import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../controllers/jadwal_pembayaran_controllers.dart';
import '../../../models/jadwal_pembayaran_models.dart';

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

  @override
  void initState() {
    super.initState();
    if (widget.schedule != null) {
      _nameController.text = widget.schedule!.name;
      _amountController.text = widget.schedule!.amount.toStringAsFixed(0);
      _notesController.text = widget.schedule!.notes ?? '';
      _selectedDate = widget.schedule!.dueDate;
      _selectedCategory = widget.schedule!.category ?? 'Tagihan';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Theme.of(context).cardColor,
      child: Container(
        width: 400,
        padding: EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.schedule == null ? 'Tambah Jadwal Baru' : 'Edit Jadwal',
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
                validator: (val) => val == null || double.tryParse(val) == null
                    ? 'Invalid amount'
                    : null,
              ),
              SizedBox(height: 16),

              // Kategori
              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                decoration: InputDecoration(
                  labelText: 'Kategori',
                  prefixIcon: Icon(Icons.category),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                items:
                    ['Tagihan', 'Langganan', 'Cicilan', 'Asuransi', 'Lainnya']
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                onChanged: (val) => setState(() => _selectedCategory = val!),
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
              SizedBox(height: 24),

              // Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(onPressed: () => Get.back(), child: Text('Batal')),
                  SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        final schedule = ModelJadwalPembayaran(
                          id: widget.schedule?.id ?? '',
                          name: _nameController.text,
                          amount: double.parse(_amountController.text),
                          dueDate: _selectedDate,
                          isPaid: widget.schedule?.isPaid ?? false,
                          category: _selectedCategory,
                          notes: _notesController.text,
                        );

                        if (widget.schedule == null) {
                          widget.controller.addSchedule(schedule);
                        } else {
                          widget.controller.updateSchedule(schedule);
                        }
                        Get.back();
                      }
                    },
                    child: Text(widget.schedule == null ? 'Simpan' : 'Update'),
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
