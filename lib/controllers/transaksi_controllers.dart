import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../models/transaksi_models.dart';
import '../models/kategori_models.dart';
import '../services/transaksi_services.dart';
import '../views/widgets/snackbar_kustom.dart';

class KontrolerTransaksi extends GetxController {
  final LayananTransaksi _service = LayananTransaksi();

  // State
  var transactions = <ModelTransaksi>[].obs;
  var categories = <ModelKategori>[].obs;
  var isLoading = false.obs;

  // Filters
  var searchQuery = ''.obs;
  var selectedCategory = 'Semua Kategori'.obs;
  var selectedMonth = DateTime.now().obs;

  // Pagination
  var currentPage = 1.obs;
  final int limit = 10;
  final List<DocumentSnapshot> _paginationStack = [];

  // Keep track of raw docs for pagination anchor
  List<DocumentSnapshot> _currentRawDocs = [];

  // Stream Subscription
  StreamSubscription? _transactionSubscription;

  @override
  void onInit() {
    super.onInit();
    // _service.seedDefaultCategories(); // Removed as per user request
    fetchCategories();
    _bindTransactionsStream();

    debounce(
      searchQuery,
      (_) => _resetAndBind(),
      time: Duration(milliseconds: 500),
    );
  }

  @override
  void onClose() {
    _transactionSubscription?.cancel();
    super.onClose();
  }

  // ... (rest of the file content needs to be updated too if it references old types)

  void fetchCategories() {
    _service.getCategories().listen((data) {
      categories.value = data;
    });
  }

  void _bindTransactionsStream({DocumentSnapshot? startAfter}) {
    isLoading.value = true;
    _transactionSubscription?.cancel();

    // Reset pagination stack if starting fresh
    if (startAfter == null) {
      _paginationStack.clear();
      currentPage.value = 1;
    }

    _transactionSubscription = _service
        .getTransactionsStream(
          limit: limit,
          startAfter: startAfter,
          category: selectedCategory.value,
          month: selectedMonth.value,
        )
        .listen(
          (snapshot) {
            _currentRawDocs = snapshot.docs;

            List<ModelTransaksi> newTransactions = snapshot.docs.map((doc) {
              return ModelTransaksi.fromFirestore(doc);
            }).toList();

            // Client-side search (filter existing list)
            if (searchQuery.value.isNotEmpty) {
              newTransactions = newTransactions
                  .where(
                    (t) => t.description.toLowerCase().contains(
                      searchQuery.value.toLowerCase(),
                    ),
                  )
                  .toList();
            }

            transactions.assignAll(newTransactions);
            isLoading.value = false;
          },
          onError: (e) {
            SnackbarKustom.error('Error', 'Failed to load transactions: $e');
            isLoading.value = false;
          },
        );
  }

  void _resetAndBind() {
    currentPage.value = 1;
    _paginationStack.clear();
    _bindTransactionsStream(startAfter: null);
  }

  void onSearchChanged(String val) {
    searchQuery.value = val;
  }

  void onCategoryChanged(String? val) {
    if (val != null) {
      selectedCategory.value = val;
      _resetAndBind();
    }
  }

  void onMonthChanged(DateTime? val) {
    if (val != null) {
      selectedMonth.value = val;
      _resetAndBind();
    }
  }

  // CRUD Operations
  Future<void> addTransaction(ModelTransaksi transaction) async {
    try {
      await _service.addTransaction(transaction);

      // --- UX IMPROVEMENT: Reset Filters to Show New Data ---
      // 1. Force date filter to the transaction's month
      selectedMonth.value = transaction.date;

      // 2. Reset category filter to ensure visibility
      selectedCategory.value = 'Semua Kategori';

      // 3. Refresh stream
      _bindTransactionsStream(); 
      // -----------------------------------------------------

      Get.back(); // Close dialog
      SnackbarKustom.sukses('Sukses', 'Transaksi berhasil ditambahkan');
    } catch (e) {
      SnackbarKustom.error('Error', 'Gagal menambahkan transaksi: $e');
    }
  }

  Future<void> updateTransaction(ModelTransaksi transaction) async {
    try {
      await _service.updateTransaction(transaction);
      Get.back(); // Close dialog
      SnackbarKustom.sukses('Sukses', 'Transaksi berhasil diperbarui');
      _resetAndBind();
    } catch (e) {
      SnackbarKustom.error('Error', 'Gagal memperbarui transaksi: $e');
    }
  }

  Future<void> deleteTransaction(String id) async {
    try {
      Get.dialog(
        AlertDialog(
          title: Text('Konfirmasi Hapus'),
          content: Text('Apakah Anda yakin ingin menghapus transaksi ini?'),
          actions: [
            TextButton(child: Text('Batal'), onPressed: () => Get.back()),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text('Hapus', style: TextStyle(color: Colors.white)),
              onPressed: () async {
                Get.back(); // Close confirmation dialog
                await _service.deleteTransaction(id);
                SnackbarKustom.sukses('Sukses', 'Transaksi berhasil dihapus');
                _resetAndBind();
              },
            ),
          ],
        ),
      );
    } catch (e) {
      SnackbarKustom.error('Error', 'Gagal menghapus transaksi: $e');
    }
  }

  Future<void> addCategory(ModelKategori category) async {
    try {
      await _service.addCategory(category);
      // No need to manual refresh as categories are streamed
      SnackbarKustom.sukses('Sukses', 'Kategori berhasil ditambahkan');
    } catch (e) {
      SnackbarKustom.error('Error', 'Gagal menambahkan kategori: $e');
    }
  }

  // Navigation
  void nextPage() {
    if (_currentRawDocs.isNotEmpty) {
      // Push the last document of the current page to the stack
      // This document becomes the 'startAfter' cursor for the next page
      _paginationStack.add(_currentRawDocs.last);
      currentPage.value++;
      _bindTransactionsStream(startAfter: _paginationStack.last);
    }
  }

  void prevPage() {
    if (currentPage.value > 1) {
      // Remove the last cursor to go back one step
      if (_paginationStack.isNotEmpty) {
        _paginationStack.removeLast();
      }

      currentPage.value--;

      // If stack is empty, we are back at page 1 (startAfter: null)
      // If stack has items, the new last item is the cursor for the current page
      DocumentSnapshot? startAfter = _paginationStack.isEmpty
          ? null
          : _paginationStack.last;

      _bindTransactionsStream(startAfter: startAfter);
    }
  }
}
