import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../../../controllers/transaksi_controllers.dart';
import '../../../models/transaksi_models.dart';
import '../../../models/kategori_models.dart';
import '../../../utils/currency_formatter.dart';
import 'atur_kategori_views.dart';

class DialogTambahTransaksi extends StatefulWidget {
  final KontrolerTransaksi controller;
  final ModelTransaksi? transaction;

  const DialogTambahTransaksi({
    super.key,
    required this.controller,
    this.transaction,
  });

  @override
  State<DialogTambahTransaksi> createState() => _DialogTambahTransaksiState();
}

class _DialogTambahTransaksiState extends State<DialogTambahTransaksi> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  String _selectedCategory = 'Other';
  bool _isExpense = true;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('id', null);
    if (widget.transaction != null) {
      _descriptionController.text = widget.transaction!.description;
      final formatter = NumberFormat.currency(
        locale: 'id',
        symbol: '',
        decimalDigits: 0,
      );
      _amountController.text = formatter.format(widget.transaction!.amount);
      _selectedCategory = widget.transaction!.category;
      _isExpense = widget.transaction!.isExpense;
      _selectedDate = widget.transaction!.date;
    } else {
      _updateCategorySelection();
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _updateCategorySelection() {
    final filtered = _filteredCategories;
    if (filtered.isNotEmpty) {
      if (!filtered.any((c) => c.name == _selectedCategory)) {
        _selectedCategory = filtered.first.name;
      }
    } else {
      _selectedCategory = 'Other';
    }
  }

  List<ModelKategori> get _filteredCategories {
    final type = _isExpense ? 'expense' : 'income';
    return widget.controller.categories.where((c) => c.type == type).toList();
  }

  void _processSave() {
    final amountStr = _amountController.text.replaceAll(RegExp(r'[^0-9]'), '');
    final amount = double.parse(amountStr);

    final tx = ModelTransaksi(
      id: widget.transaction?.id ?? '',
      uid:
          widget.transaction?.uid ??
          FirebaseAuth.instance.currentUser?.uid ??
          '',
      description: _descriptionController.text,
      amount: amount,
      isExpense: _isExpense,
      type: _isExpense ? 'expense' : 'income',
      date: _selectedDate,
      category: _selectedCategory,
    );

    if (widget.transaction == null) {
      widget.controller.addTransaction(tx);
    } else {
      widget.controller.updateTransaction(tx);
    }
    Get.back();
    if (widget.transaction != null) Get.back();
  }

  void _showUpdateConfirmationDialog() {
    Get.defaultDialog(
      title: "Konfirmasi Update",
      radius: 12,
      titleStyle: const TextStyle(fontWeight: FontWeight.bold),
      middleText: "Apakah Anda yakin ingin menyimpan perubahan data ini?",
      textConfirm: "Ya, Simpan",
      textCancel: "Batal",
      confirmTextColor: Theme.of(context).colorScheme.onPrimary,
      buttonColor: Theme.of(context).primaryColor,
      onConfirm: _processSave,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      backgroundColor: Theme.of(context).cardColor,
      child: Container(
        width: context.width > 400 ? 400 : context.width * 0.9,
        constraints: BoxConstraints(maxHeight: context.height * 0.9),
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    widget.transaction == null
                        ? 'Tambah Transaksi Baru'
                        : 'Edit Transaksi',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Tipe:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ChoiceChip(
                        label: const SizedBox(
                          width: double.infinity,
                          child: Text(
                            'Pengeluaran',
                            textAlign: TextAlign.center,
                          ),
                        ),
                        selected: _isExpense,
                        onSelected: (val) {
                          setState(() {
                            _isExpense = true;
                            _updateCategorySelection();
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ChoiceChip(
                        label: const SizedBox(
                          width: double.infinity,
                          child: Text('Pemasukan', textAlign: TextAlign.center),
                        ),
                        selected: !_isExpense,
                        onSelected: (val) {
                          setState(() {
                            _isExpense = false;
                            _updateCategorySelection();
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Obx(() {
                        if (!_filteredCategories.any(
                          (c) => c.name == _selectedCategory,
                        )) {
                          _selectedCategory = _filteredCategories.isNotEmpty
                              ? _filteredCategories.first.name
                              : 'Other';
                        }
                        return DropdownButtonFormField<String>(
                          initialValue: _selectedCategory,
                          decoration: InputDecoration(
                            labelText: 'Kategori',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ), // PERBAIKAN: Rounded border
                          items: _filteredCategories.map((c) {
                            return DropdownMenuItem(
                              value: c.name,
                              child: Text(c.name),
                            );
                          }).toList(),
                          onChanged: (val) =>
                              setState(() => _selectedCategory = val!),
                        );
                      }),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.settings),
                      onPressed: () => Get.to(() => const AturKategoriViews()),
                    ),
                  ],
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
                      labelText: 'Tanggal',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.calendar_today),
                    ),
                    child: Text(
                      DateFormat('d MMMM yyyy', 'id').format(_selectedDate),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _amountController,
                  decoration: InputDecoration(
                    labelText: 'Jumlah',
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
                  validator: (value) => (value == null || value.isEmpty)
                      ? 'Jumlah harus diisi'
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Keterangan',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      style: TextButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => Get.back(),
                      child: const Text("Batal"),
                    ),
                    const SizedBox(width: 12),
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
                          if (widget.transaction == null) {
                            _processSave();
                          } else {
                            _showUpdateConfirmationDialog();
                          }
                        }
                      },
                      child: Text(
                        widget.transaction == null ? 'Simpan' : 'Update',
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
