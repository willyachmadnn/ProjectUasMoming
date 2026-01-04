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
import 'atur_kategori_views.dart'; // Import halaman kategori baru

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
    Get.back();
  }

  void _showConfirmationDialog() {
    Get.defaultDialog(
      title: "Konfirmasi",
      titleStyle: TextStyle(
        fontWeight: FontWeight.bold,
        color: Theme.of(context).textTheme.titleLarge?.color,
      ),
      middleText: widget.transaction == null
          ? "Apakah Anda yakin ingin menyimpan transaksi baru ini?"
          : "Apakah Anda yakin ingin menyimpan perubahan data ini?",
      middleTextStyle: TextStyle(
        color: Theme.of(context).textTheme.bodyMedium?.color,
      ),
      textConfirm: "Ya, Simpan",
      textCancel: "Batal",
      confirmTextColor: Theme.of(context).colorScheme.onPrimary,
      cancelTextColor: Theme.of(context).colorScheme.primary,
      buttonColor: Theme.of(context).primaryColor,
      backgroundColor: Theme.of(context).cardColor,
      onConfirm: _processSave,
      onCancel: () {},
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
        padding: EdgeInsets.all(24),
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
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(height: 24),

                Text('Tipe:', style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ChoiceChip(
                        label: Container(
                          alignment: Alignment.center,
                          width: double.infinity,
                          child: Text('Pengeluaran'),
                        ),
                        selected: _isExpense,
                        onSelected: (val) {
                          setState(() {
                            _isExpense = true;
                            _updateCategorySelection();
                          });
                        },
                        selectedColor: Theme.of(
                          context,
                        ).colorScheme.error.withValues(alpha: 0.2),
                        backgroundColor: Theme.of(context).cardColor,
                        labelStyle: TextStyle(
                          color: _isExpense
                              ? Theme.of(context).colorScheme.error
                              : Theme.of(context).textTheme.bodyMedium?.color,
                          fontWeight: _isExpense
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: ChoiceChip(
                        label: Container(
                          alignment: Alignment.center,
                          width: double.infinity,
                          child: Text('Pemasukan'),
                        ),
                        selected: !_isExpense,
                        onSelected: (val) {
                          setState(() {
                            _isExpense = false;
                            _updateCategorySelection();
                          });
                        },
                        selectedColor: Colors.green.withValues(alpha: 0.2),
                        backgroundColor: Theme.of(context).cardColor,
                        labelStyle: TextStyle(
                          color: !_isExpense
                              ? Colors.green
                              : Theme.of(context).textTheme.bodyMedium?.color,
                          fontWeight: !_isExpense
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),

                // UPDATE: Dropdown Kategori + Tombol Setting
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Obx(() {
                        // Memaksa rebuild saat list kategori di controller berubah
                        // trik: akses widget.controller.categories.length agar reactive
                        // ignore: unused_local_variable
                        final trigger = widget.controller.categories.length;

                        // Validasi ulang jika kategori terpilih tiba-tiba dihapus
                        if (!_filteredCategories.any(
                          (c) => c.name == _selectedCategory,
                        )) {
                          if (_filteredCategories.isNotEmpty) {
                            _selectedCategory = _filteredCategories.first.name;
                          } else {
                            _selectedCategory = 'Other';
                          }
                        }

                        return DropdownButtonFormField<String>(
                          value:
                              _filteredCategories.any(
                                (c) => c.name == _selectedCategory,
                              )
                              ? _selectedCategory
                              : null,
                          decoration: InputDecoration(
                            labelText: 'Kategori',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            prefixIcon: Icon(Icons.category_outlined),
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
                          onChanged: (val) => setState(
                            () => _selectedCategory = val ?? 'Other',
                          ),
                        );
                      }),
                    ),
                    SizedBox(width: 8),
                    Container(
                      height: 56, // Menyesuaikan tinggi input field default
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Theme.of(context).dividerColor,
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.settings,
                          color: Theme.of(context).iconTheme.color,
                        ),
                        tooltip: "Atur Kategori",
                        onPressed: () {
                          Get.to(() => AturKategoriViews());
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),

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
                      prefixIcon: Icon(Icons.calendar_today),
                    ),
                    child: Text(
                      DateFormat('d MMMM yyyy', 'id').format(_selectedDate),
                    ),
                  ),
                ),
                SizedBox(height: 16),

                TextFormField(
                  controller: _amountController,
                  decoration: InputDecoration(
                    labelText: 'Jumlah (Rp)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    CurrencyInputFormatter(),
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Jumlah harus diisi';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),

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
                SizedBox(height: 24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => Get.back(),
                      child: Text(
                        "Batal",
                        style: TextStyle(color: Theme.of(context).primaryColor),
                      ),
                    ),
                    SizedBox(width: 12),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
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
                          _showConfirmationDialog();
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
