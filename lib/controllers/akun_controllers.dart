import 'dart:io';
import 'package:financial/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../controllers/autentikasi_controllers.dart';
import '../views/widgets/snackbar_kustom.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../models/transaksi_models.dart';
import '../views/akun/widgets/dialog_export.dart';

class KontrolerAkun extends GetxController {
  final KontrolerAutentikasi _authCtrl = Get.find<KontrolerAutentikasi>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final RxString username = ''.obs;
  final RxString email = ''.obs;
  final RxString photoUrl = ''.obs;
  final RxString appVersion = '1.0.0'.obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadUserData();
  }

  void _loadUserData() async {
    final user = _auth.currentUser;
    if (user != null) {
      email.value = user.email ?? '';

      final prefs = await SharedPreferences.getInstance();
      final key = 'local_profile_image_${user.uid}';
      String? localImage = prefs.getString(key);

      if (localImage != null &&
          localImage.isNotEmpty &&
          File(localImage).existsSync()) {
        photoUrl.value = localImage;
      } else {
        photoUrl.value = user.photoURL ?? '';
      }
      _fetchUsernameFromFirestore(user.uid);
    }
  }

  Future<void> _fetchUsernameFromFirestore(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        username.value =
            doc.data()?['username'] ?? _auth.currentUser?.displayName ?? 'User';
      } else {
        username.value = _auth.currentUser?.displayName ?? 'User';
      }
    } catch (e) {
      username.value = _auth.currentUser?.displayName ?? 'User';
    }
  }

  Future<void> pickImage(ImageSource source) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        imageQuality: 50,
      );

      if (image == null) return;

      isLoading.value = true;
      final prefs = await SharedPreferences.getInstance();

      final key = 'local_profile_image_${user.uid}';
      await prefs.setString(key, image.path);

      photoUrl.value = image.path;
      SnackbarKustom.sukses("Berhasil", "Foto profil tersimpan di perangkat");
    } catch (e) {
      SnackbarKustom.error("Gagal", "Gagal mengambil gambar: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateDisplayName(String newName) async {
    if (newName.isNotEmpty) {
      isLoading.value = true;
      try {
        await _auth.currentUser?.updateDisplayName(newName);
        await _auth.currentUser?.reload();
        username.value = newName;
        SnackbarKustom.sukses('Berhasil', 'Profil diperbarui');
      } catch (e) {
        SnackbarKustom.error('Gagal', e.toString());
      } finally {
        isLoading.value = false;
      }
    }
  }

  Future<void> updateUsername(String newUsername) async {
    final usernameTrimmed = newUsername.trim();
    if (usernameTrimmed.isEmpty) return;

    isLoading.value = true;

    try {
      final check = await _firestore
          .collection('users')
          .where('username', isEqualTo: usernameTrimmed)
          .get();

      if (check.docs.isNotEmpty) {
        SnackbarKustom.error('Gagal', 'Username sudah digunakan');
        return;
      }

      final uid = _auth.currentUser?.uid;
      if (uid != null) {
        await _firestore.collection('users').doc(uid).set({
          'username': usernameTrimmed,
        }, SetOptions(merge: true));
        username.value = usernameTrimmed;
        _authCtrl.userName.value = usernameTrimmed;

        SnackbarKustom.sukses('Berhasil', 'Username diperbarui');
      }
    } catch (e) {
      SnackbarKustom.error('Gagal', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updatePassword(String newPassword) async {
    if (newPassword.length < 6) {
      SnackbarKustom.error('Gagal', 'Password minimal 6 karakter');
      return;
    }
    isLoading.value = true;
    try {
      await _auth.currentUser?.updatePassword(newPassword);
      SnackbarKustom.sukses('Berhasil', 'Kata sandi berhasil diubah');
    } catch (e) {
      SnackbarKustom.error('Gagal', 'Login ulang mungkin diperlukan: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> exportData() async {
    Get.dialog(const DialogExport());
  }

  PdfColor _toPdfColor(Color color) {
    return PdfColor.fromInt(color.value);
  }

  Future<void> generatePdf(DateTime selectedDate) async {
    isLoading.value = true;
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) {
        isLoading.value = false;
        return;
      }

      final startOfMonth = DateTime(selectedDate.year, selectedDate.month, 1);
      final endOfMonth = DateTime(
        selectedDate.year,
        selectedDate.month + 1,
        0,
        23,
        59,
        59,
      );

      final query = await _firestore
          .collection('transactions')
          .where('uid', isEqualTo: uid)
          .where(
        'date',
        isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth),
      )
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endOfMonth))
          .get();

      final transactions = query.docs
          .map((doc) => ModelTransaksi.fromFirestore(doc))
          .toList();

      final queryFuture = await _firestore
          .collection('transactions')
          .where('uid', isEqualTo: uid)
          .where('date', isGreaterThan: Timestamp.fromDate(endOfMonth))
          .get();

      final futureTransactions = queryFuture.docs
          .map((doc) => ModelTransaksi.fromFirestore(doc))
          .toList();

      final userDoc = await _firestore.collection('users').doc(uid).get();
      final double currentBalance = (userDoc.data()?['currentBalance'] ?? 0)
          .toDouble();

      double incomeFuture = 0;
      double expenseFuture = 0;
      for (var tx in futureTransactions) {
        if (tx.isExpense) {
          expenseFuture += tx.amount;
        } else {
          incomeFuture += tx.amount;
        }
      }

      double saldoAkhir = currentBalance - incomeFuture + expenseFuture;

      double incomeMonth = 0;
      double expenseMonth = 0;
      double totalSavings = 0;
      double totalBills = 0;
      Map<String, double> categoryMap = {};

      for (var tx in transactions) {
        if (tx.isExpense) {
          expenseMonth += tx.amount;
          categoryMap[tx.category] =
              (categoryMap[tx.category] ?? 0) + tx.amount;
        } else {
          incomeMonth += tx.amount;
        }

        if (tx.category.toLowerCase().contains('tagihan') ||
            tx.category.toLowerCase().contains('bill')) {
          totalBills += tx.amount;
        }
        if (tx.category.toLowerCase().contains('tabungan') ||
            tx.category.toLowerCase().contains('saving')) {
          totalSavings += tx.amount;
        }
      }

      double saldoAwal = saldoAkhir - (incomeMonth - expenseMonth);

      final sortedCategories = categoryMap.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      final top5 = sortedCategories.take(5).toList();

      final pdf = pw.Document();

      pw.MemoryImage? logo;
      try {
        final imageBytes = (await rootBundle.load(
          'assets/dompet.png',
        )).buffer.asUint8List();
        logo = pw.MemoryImage(imageBytes);
      } catch (_) {}

      final currencyFormat = NumberFormat.currency(
        locale: 'id_ID',
        symbol: 'Rp ',
        decimalDigits: 0,
      );

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Container(
                  padding: const pw.EdgeInsets.all(10),
                  decoration: pw.BoxDecoration(
                    color: _toPdfColor(AppTheme.primaryLight),
                    borderRadius: const pw.BorderRadius.all(
                      pw.Radius.circular(8),
                    ),
                  ),
                  child: pw.Row(
                    children: [
                      if (logo != null) pw.Image(logo, width: 40, height: 40),
                      if (logo != null) pw.SizedBox(width: 10),
                      pw.Text(
                        'Sakuku',
                        style: pw.TextStyle(
                          color: _toPdfColor(
                            AppTheme.light.colorScheme.onPrimary,
                          ),
                          fontSize: 24,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 20),
                pw.Center(
                  child: pw.Text(
                    'LAPORAN KEUANGAN BULANAN',
                    style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                      color: _toPdfColor(AppTheme.primaryDark),
                    ),
                  ),
                ),
                pw.SizedBox(height: 5),
                pw.Center(
                  child: pw.Text(
                    'Periode: ${DateFormat('MMMM yyyy', 'id_ID').format(selectedDate)}',
                    style: const pw.TextStyle(fontSize: 14),
                  ),
                ),
                pw.SizedBox(height: 20),
                pw.Text(
                  'Ringkasan Keuangan',
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                    color: _toPdfColor(AppTheme.primaryLight),
                  ),
                ),
                pw.Divider(
                  color: _toPdfColor(
                    AppTheme.textSecondaryLight.withValues(alpha: 0.2),
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    _buildPdfCard(
                      'Saldo Awal',
                      currencyFormat.format(saldoAwal),
                      _toPdfColor(AppTheme.primaryLight.withValues(alpha: 0.1)),
                    ),
                    _buildPdfCard(
                      'Total Pemasukan',
                      currencyFormat.format(incomeMonth),
                      _toPdfColor(AppTheme.success.withValues(alpha: 0.1)),
                    ),
                    _buildPdfCard(
                      'Total Pengeluaran',
                      currencyFormat.format(expenseMonth),
                      _toPdfColor(AppTheme.error.withValues(alpha: 0.1)),
                    ),
                    _buildPdfCard(
                      'Saldo Akhir',
                      currencyFormat.format(saldoAkhir),
                      _toPdfColor(AppTheme.primaryLight),
                      isDark: true,
                    ),
                  ],
                ),
                pw.SizedBox(height: 20),
                pw.Text(
                  'Rincian Transaksi (Top 5 Pengeluaran)',
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                    color: _toPdfColor(AppTheme.primaryLight),
                  ),
                ),
                pw.Divider(
                  color: _toPdfColor(
                    AppTheme.textSecondaryLight.withValues(alpha: 0.2),
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.TableHelper.fromTextArray(
                  headers: ['No', 'Kategori', 'Total'],
                  data: List.generate(top5.length, (index) {
                    final entry = top5[index];
                    return [
                      (index + 1).toString(),
                      entry.key,
                      currencyFormat.format(entry.value),
                    ];
                  }),
                  headerStyle: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    color: _toPdfColor(AppTheme.light.colorScheme.onPrimary),
                  ),
                  headerDecoration: pw.BoxDecoration(
                    color: _toPdfColor(AppTheme.primaryLight),
                  ),
                  rowDecoration: pw.BoxDecoration(
                    color: _toPdfColor(AppTheme.backgroundLight),
                  ),
                  cellAlignment: pw.Alignment.centerLeft,
                  cellAlignments: {
                    0: pw.Alignment.center,
                    2: pw.Alignment.centerRight,
                  },
                ),
                pw.SizedBox(height: 20),
                pw.Text(
                  'Tagihan Bulanan & Tabungan',
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                    color: _toPdfColor(AppTheme.primaryLight),
                  ),
                ),
                pw.Divider(
                  color: _toPdfColor(
                    AppTheme.textSecondaryLight.withValues(alpha: 0.2),
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Row(
                  children: [
                    pw.Expanded(
                      child: _buildSectionBox(
                        'Tagihan Bulanan',
                        currencyFormat.format(totalBills),
                        _toPdfColor(
                          AppTheme.primaryLight.withValues(alpha: 0.1),
                        ),
                      ),
                    ),
                    pw.SizedBox(width: 20),
                    pw.Expanded(
                      child: _buildSectionBox(
                        'Tabungan',
                        currencyFormat.format(totalSavings),
                        _toPdfColor(
                          AppTheme.primaryLight.withValues(alpha: 0.1),
                        ),
                      ),
                    ),
                  ],
                ),
                pw.Spacer(),
                pw.Center(
                  child: pw.Text(
                    'Tanggal Laporan Dicetak: ${DateFormat('d MMMM yyyy', 'id_ID').format(DateTime.now())}',
                    style: pw.TextStyle(
                      fontSize: 10,
                      color: _toPdfColor(AppTheme.textSecondaryLight),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      );

      final Uint8List bytes = await pdf.save();

      isLoading.value = false;

      await Printing.sharePdf(
        bytes: bytes,
        filename:
        'Laporan_Keuangan_${DateFormat('MMMM_yyyy', 'id_ID').format(selectedDate)}.pdf',
      );
    } catch (e) {
      isLoading.value = false;
      SnackbarKustom.error('Gagal', 'Terjadi kesalahan: $e');
    }
  }

  pw.Widget _buildPdfCard(
      String title,
      String value,
      PdfColor color, {
        bool isDark = false,
      }) {
    return pw.Expanded(
      child: pw.Container(
        margin: const pw.EdgeInsets.symmetric(horizontal: 4),
        padding: const pw.EdgeInsets.all(8),
        decoration: pw.BoxDecoration(
          color: color,
          borderRadius: pw.BorderRadius.circular(4),
        ),
        child: pw.Column(
          children: [
            pw.Text(
              title,
              style: pw.TextStyle(
                fontSize: 8,
                color: isDark ? PdfColors.white : PdfColors.black,
              ),
              textAlign: pw.TextAlign.center,
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              value,
              style: pw.TextStyle(
                fontSize: 10,
                fontWeight: pw.FontWeight.bold,
                color: isDark ? PdfColors.white : PdfColors.black,
              ),
              textAlign: pw.TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  pw.Widget _buildSectionBox(String title, String value, PdfColor color) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: color,
        borderRadius: pw.BorderRadius.circular(4),
        border: pw.Border.all(
          color: _toPdfColor(
            AppTheme.textSecondaryLight.withValues(alpha: 0.3),
          ),
        ),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              color: _toPdfColor(AppTheme.primaryDark),
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            value,
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Future<void> deleteData() async {
    Get.defaultDialog(
      title: 'Hapus Semua Data?',
      middleText: 'Tindakan ini tidak dapat dibatalkan.',
      textConfirm: 'Hapus',
      textCancel: 'Batal',
      confirmTextColor: Theme.of(Get.context!).colorScheme.onError,
      buttonColor: Theme.of(Get.context!).colorScheme.error,
      onConfirm: () async {
        Get.back();
        isLoading.value = true;
        try {
          final uid = _auth.currentUser?.uid;
          if (uid != null) {
            final batch = _firestore.batch();
            var snapshots = await _firestore
                .collection('transactions')
                .where('uid', isEqualTo: uid)
                .get();
            for (var doc in snapshots.docs) {
              batch.delete(doc.reference);
            }
            await batch.commit();
            SnackbarKustom.sukses('Berhasil', 'Semua data transaksi dihapus');
          }
        } catch (e) {
          SnackbarKustom.error('Gagal', e.toString());
        } finally {
          isLoading.value = false;
        }
      },
    );
  }

  Future<void> deleteAccount() async {
    final user = _auth.currentUser;
    if (user == null) return;

    Get.defaultDialog(
      title: 'Hapus Akun?',
      middleText: 'Akun Anda akan dihapus permanen.',
      textConfirm: 'Hapus Permanen',
      textCancel: 'Batal',
      confirmTextColor: AppTheme.light.colorScheme.onError,
      buttonColor: AppTheme.error,
      onConfirm: () async {
        Get.back();
        final prefs = await SharedPreferences.getInstance();

        await prefs.remove('local_profile_image_${user.uid}');

        _authCtrl.logout();
      },
    );
  }
}