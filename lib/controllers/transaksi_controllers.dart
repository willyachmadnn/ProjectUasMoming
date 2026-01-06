import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../models/transaksi_models.dart';
import '../models/kategori_models.dart';
import '../services/transaksi_services.dart';
import '../views/widgets/snackbar_kustom.dart';
import '../theme/app_theme.dart';

class KontrolerTransaksi extends GetxController {
  final LayananTransaksi _service = LayananTransaksi();

  var transactions = <ModelTransaksi>[].obs;
  var categories = <ModelKategori>[].obs;
  var isLoading = false.obs;

  var searchQuery = ''.obs;
  var selectedCategory = 'Semua Kategori'.obs;

  var selectedDateRange = DateTimeRange(
    start: DateTime.now().subtract(const Duration(days: 30)),
    end: DateTime.now(),
  ).obs;

  var isSearchOpen = false.obs;

  var currentPage = 1.obs;
  final int limit = 10;
  final List<DocumentSnapshot> _paginationStack = [];
  List<DocumentSnapshot> _currentRawDocs = [];

  StreamSubscription? _transactionSubscription;
  StreamSubscription? _authSubscription;

  @override
  void onInit() {
    super.onInit();
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null) {
        fetchCategories();
        _resetAndBind();
      } else {
        transactions.clear();
        categories.clear();
        isLoading.value = false;
      }
    });

    debounce(
      searchQuery,
          (_) => _resetAndBind(),
      time: const Duration(milliseconds: 500),
    );
  }

  @override
  void onClose() {
    _transactionSubscription?.cancel();
    _authSubscription?.cancel();
    super.onClose();
  }

  void toggleSearch() {
    isSearchOpen.value = !isSearchOpen.value;
    if (!isSearchOpen.value) {
      searchQuery.value = '';
      _resetAndBind();
    }
  }

  void onSearchChanged(String val) {
    searchQuery.value = val;
  }

  void updateDateRange(DateTimeRange newRange) {
    selectedDateRange.value = newRange;
    _resetAndBind();
  }

  void onCategoryChanged(String? val) {
    if (val != null) {
      selectedCategory.value = val;
      _resetAndBind();
    }
  }

  void fetchCategories() {
    if (FirebaseAuth.instance.currentUser == null) return;

    _service.getCategories().listen((data) {
      categories.value = data;
    });
  }

  void _bindTransactionsStream({DocumentSnapshot? startAfter}) {
    if (FirebaseAuth.instance.currentUser == null) {
      isLoading.value = false;
      return;
    }

    isLoading.value = true;
    _transactionSubscription?.cancel();

    if (startAfter == null) {
      _paginationStack.clear();
      currentPage.value = 1;
    }

    String? categoryFilter;
    if (selectedCategory.value != 'Semua Kategori') {
      categoryFilter = selectedCategory.value;
    }

    _transactionSubscription = _service
        .getTransactionsStream(
      limit: limit,
      startAfter: startAfter,
      category: categoryFilter,
    )
        .listen(
          (snapshot) {
        _currentRawDocs = snapshot.docs;

        List<ModelTransaksi> newTransactions = snapshot.docs.map((doc) {
          return ModelTransaksi.fromFirestore(doc);
        }).toList();

        newTransactions = newTransactions.where((t) {
          return t.date.isAfter(
            selectedDateRange.value.start.subtract(
              const Duration(seconds: 1),
            ),
          ) &&
              t.date.isBefore(
                selectedDateRange.value.end.add(const Duration(days: 1)),
              );
        }).toList();

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

  Future<void> addTransaction(ModelTransaksi transaction) async {
    try {
      await _service.addTransaction(transaction);

      selectedDateRange.value = DateTimeRange(
        start: transaction.date.subtract(const Duration(days: 1)),
        end: transaction.date.add(const Duration(days: 1)),
      );

      selectedCategory.value = 'Semua Kategori';
      _resetAndBind();

      Get.back();
      SnackbarKustom.sukses('Sukses', 'Transaksi berhasil ditambahkan');
    } catch (e) {
      SnackbarKustom.error('Error', 'Gagal menambahkan transaksi: $e');
    }
  }

  Future<void> updateTransaction(ModelTransaksi transaction) async {
    try {
      await _service.updateTransaction(transaction);
      Get.back();
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
          title: const Text('Konfirmasi Hapus'),
          content: const Text(
            'Apakah Anda yakin ingin menghapus transaksi ini?',
          ),
          actions: [
            TextButton(child: const Text('Batal'), onPressed: () => Get.back()),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
              child: Text(
                'Hapus',
                style: TextStyle(color: AppTheme.light.colorScheme.onError),
              ),
              onPressed: () async {
                Get.back();
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
      SnackbarKustom.sukses('Sukses', 'Kategori berhasil ditambahkan');
    } catch (e) {
      SnackbarKustom.error('Error', 'Gagal menambahkan kategori: $e');
    }
  }

  Future<void> updateCategory(ModelKategori category) async {
    try {
      await _service.updateCategory(category);
      SnackbarKustom.sukses('Sukses', 'Kategori berhasil diperbarui');
    } catch (e) {
      SnackbarKustom.error('Error', 'Gagal memperbarui kategori: $e');
    }
  }

  Future<void> deleteCategory(String id) async {
    try {
      await _service.deleteCategory(id);
      SnackbarKustom.sukses('Sukses', 'Kategori berhasil dihapus');
    } catch (e) {
      SnackbarKustom.error('Error', 'Gagal menghapus kategori: $e');
    }
  }

  void nextPage() {
    if (_currentRawDocs.isNotEmpty) {
      _paginationStack.add(_currentRawDocs.last);
      currentPage.value++;
      _bindTransactionsStream(startAfter: _paginationStack.last);
    }
  }

  void prevPage() {
    if (currentPage.value > 1) {
      if (_paginationStack.isNotEmpty) {
        _paginationStack.removeLast();
      }
      currentPage.value--;

      DocumentSnapshot? startAfter = _paginationStack.isEmpty
          ? null
          : _paginationStack.last;

      _bindTransactionsStream(startAfter: startAfter);
    }
  }
}