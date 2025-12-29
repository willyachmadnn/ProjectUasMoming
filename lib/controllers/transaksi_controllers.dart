import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../models/transaksi_models.dart';
import '../models/kategori_models.dart';
import '../services/transaksi_services.dart';

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

            // Client-side search
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
            Get.snackbar('Error', 'Failed to load transactions: $e');
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
      // isLoading.value = true; // Stream will handle loading state if needed, but for add we just wait
      await _service.addTransaction(transaction);
      Get.back(); // Close dialog
      Get.snackbar(
        'Success',
        'Transaction added successfully',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      // No need to manual refresh, Stream updates automatically
      // However, if we are on page 2, we might want to go to page 1 to see it?
      // For now, let's keep it simple. If on page 1, it appears.
      if (currentPage.value != 1) {
        _resetAndBind(); // Jump to first page to see new item
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to add transaction: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> updateTransaction(ModelTransaksi transaction) async {
    try {
      await _service.updateTransaction(transaction);
      Get.back(); // Close dialog
      Get.snackbar(
        'Success',
        'Transaction updated successfully',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      // Stream updates automatically
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update transaction: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
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
                Get.snackbar(
                  'Success',
                  'Transaction deleted successfully',
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
                );
                // Stream updates automatically
              },
            ),
          ],
        ),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete transaction: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> addCategory(ModelKategori category) async {
    try {
      await _service.addCategory(category);
      // No need to manual refresh as categories are streamed
      Get.snackbar(
        'Success',
        'Category added successfully',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to add category: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
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
