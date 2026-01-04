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

// ==============================================================================
// Dialog Tambah / Edit Transaksi
// ==============================================================================
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
      // Format amount for display
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
      // Initialize with first category if available based on default type (Expense)
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

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                  widget.transaction == null
                      ? 'Tambah Transaksi Baru'
                      : 'Edit Transaksi',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 24),

                // Description
                TextFormField(
                  controller: _descriptionController,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    labelText: 'Deskripsi',
                    border: OutlineInputBorder(),
                  ),
                  validator: (val) =>
                      val == null || val.isEmpty ? 'Required' : null,
                ),
                SizedBox(height: 16),

                // Amount
                TextFormField(
                  controller: _amountController,
                  decoration: InputDecoration(
                    labelText: 'Jumlah (Rp)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [CurrencyInputFormatter()],
                  validator: (val) {
                    if (val == null || val.isEmpty) return 'Invalid amount';
                    final numStr = val.replaceAll(RegExp(r'[^0-9]'), '');
                    return numStr.isEmpty ? 'Invalid amount' : null;
                  },
                ),
                SizedBox(height: 16),

                // Type Switch
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tipe:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        return Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            ChoiceChip(
                              label: Container(
                                constraints: BoxConstraints(
                                  maxWidth: constraints.maxWidth * 0.4,
                                ),
                                child: Text(
                                  'Pengeluaran',
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              selected: _isExpense,
                              onSelected: (val) {
                                setState(() {
                                  _isExpense = true;
                                  _updateCategorySelection();
                                });
                              },
                              selectedColor: Colors.red[100],
                              labelStyle: TextStyle(
                                color: _isExpense
                                    ? Colors.red
                                    : Theme.of(context).textTheme.bodyMedium?.color,
                              ),
                            ),
                            ChoiceChip(
                              label: Container(
                                constraints: BoxConstraints(
                                  maxWidth: constraints.maxWidth * 0.4,
                                ),
                                child: Text(
                                  'Pemasukan',
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              selected: !_isExpense,
                              onSelected: (val) {
                                setState(() {
                                  _isExpense = false;
                                  _updateCategorySelection();
                                });
                              },
                              selectedColor: Colors.green[100],
                              labelStyle: TextStyle(
                                color: !_isExpense
                                    ? Colors.green
                                    : Theme.of(context).textTheme.bodyMedium?.color,
                              ),
                            ),
                          ],
                        );
                      }
                    ),
                  ],
                ),
                SizedBox(height: 16),

                // Category Dropdown
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        // ignore: deprecated_member_use
                        value:
                            _filteredCategories.any(
                              (c) => c.name == _selectedCategory,
                            )
                            ? _selectedCategory
                            : null,
                        decoration: InputDecoration(
                          labelText: 'Kategori',
                          border: OutlineInputBorder(),
                        ),
                        items: _filteredCategories
                            .map((c) => c.name)
                            .toSet()
                            .map((name) {
                              return DropdownMenuItem(
                                value: name,
                                child: Text(name),
                              );
                            })
                            .toList(),
                        onChanged: (val) =>
                            setState(() => _selectedCategory = val ?? 'Other'),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),

                // Date Picker
                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                      locale: const Locale('id', 'ID'),
                    );
                    if (picked != null) setState(() => _selectedDate = picked);
                  },
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Tanggal',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    child: Text(
                      DateFormat('d MMMM yyyy', 'id').format(_selectedDate),
                    ),
                  ),
                ),
                SizedBox(height: 24),

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
                          // Parse amount from formatted string
                          final amountStr = _amountController.text.replaceAll(
                            RegExp(r'[^0-9]'),
                            '',
                          );
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
                        }
                      },
                      child: Text('Simpan'),
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

// ==============================================================================
// Dialog Tambah Kategori
// ==============================================================================
class DialogTambahKategori extends StatefulWidget {
  final KontrolerTransaksi controller;

  const DialogTambahKategori({super.key, required this.controller});

  @override
  State<DialogTambahKategori> createState() => _DialogTambahKategoriState();
}

class _DialogTambahKategoriState extends State<DialogTambahKategori> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  String _type = 'expense';

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: context.width > 400 ? 400 : context.width * 0.9,
        padding: EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tambah Kategori Baru',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 24),

                TextFormField(
                  controller: _nameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    labelText: 'Nama Kategori',
                    border: OutlineInputBorder(),
                  ),
                  validator: (val) =>
                      val == null || val.isEmpty ? 'Required' : null,
                ),
                SizedBox(height: 16),

                DropdownButtonFormField<String>(
                  initialValue: _type,
                  decoration: InputDecoration(
                    labelText: 'Tipe',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    DropdownMenuItem(
                      value: 'expense',
                      child: Text('Pengeluaran'),
                    ),
                    DropdownMenuItem(value: 'income', child: Text('Pemasukan')),
                  ],
                  onChanged: (val) => setState(() => _type = val!),
                ),
                SizedBox(height: 24),

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
                          final cat = ModelKategori(
                            id: '',
                            name: _nameController.text,
                            type: _type,
                          );
                          widget.controller.addCategory(cat);
                          Get.back();
                        }
                      },
                      child: Text('Simpan'),
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
