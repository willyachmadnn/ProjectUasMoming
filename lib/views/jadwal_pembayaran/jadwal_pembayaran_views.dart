import 'package:financial/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controllers/jadwal_pembayaran_controllers.dart';
import '../widgets/app_bar_kustom.dart';
import '../widgets/drawer_kustom.dart';
import 'widgets/dialog_tambah_jadwal.dart';
import '../../models/jadwal_pembayaran_models.dart';

class TampilanJadwalPembayaran extends StatelessWidget {
  const TampilanJadwalPembayaran({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(KontrolerJadwalPembayaran());
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    String safeDate(DateTime date) =>
        DateFormat('d MMMM yyyy', 'id_ID').format(date);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBarKustom(),
      drawer: DrawerKustom(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFilterBar(context, controller),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Daftar Jadwal",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                ElevatedButton.icon(
                  onPressed: () =>
                      Get.dialog(DialogTambahJadwal(controller: controller)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  icon: Icon(
                    Icons.add,
                    color: Theme.of(context).colorScheme.onPrimary,
                    size: 18,
                  ),
                  label: Text(
                    "Jadwal",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),
            Obx(() {
              if (controller.filteredSchedules.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.only(top: 50),
                  child: Center(child: Text("Tidak ada jadwal ditemukan")),
                );
              }

              return Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(
                        context,
                      ).shadowColor.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: controller.filteredSchedules.asMap().entries.map((
                    entry,
                  ) {
                    int index = entry.key;
                    var item = entry.value;
                    bool isLast =
                        index == controller.filteredSchedules.length - 1;

                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: isLast
                            ? null
                            : Border(
                                bottom: BorderSide(
                                  color: Theme.of(
                                    context,
                                  ).dividerColor.withValues(alpha: 0.5),
                                ),
                              ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                safeDate(item.dueDate),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(context).hintColor,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      (item.isPaid
                                              ? AppTheme.success
                                              : Theme.of(
                                                  context,
                                                ).colorScheme.error)
                                          .withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  item.isPaid ? 'Lunas' : 'Tertunda',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: item.isPaid
                                        ? AppTheme.success
                                        : Theme.of(context).colorScheme.error,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            item.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                currencyFormat.format(item.amount),
                                style: TextStyle(
                                  color: item.isPaid
                                      ? AppTheme.success
                                      : AppTheme.warning,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Row(
                                children: [
                                  if (!item.isPaid)
                                    IconButton(
                                      icon: const Icon(
                                        Icons.check_circle_outline,
                                        color: AppTheme.info,
                                        size: 20,
                                      ),
                                      onPressed: () => _konfirmasiBayar(
                                        context,
                                        controller,
                                        item,
                                      ),
                                      tooltip: 'Bayar',
                                    ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.edit,
                                      size: 20,
                                      color: Theme.of(context).disabledColor,
                                    ),
                                    onPressed: () => Get.dialog(
                                      DialogTambahJadwal(
                                        controller: controller,
                                        schedule: item,
                                      ),
                                    ),
                                    tooltip: 'Edit',
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.delete,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.error,
                                      size: 20,
                                    ),
                                    onPressed: () => _konfirmasiHapus(
                                      context,
                                      controller,
                                      item.id,
                                    ),
                                    tooltip: 'Hapus',
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterBar(
    BuildContext context,
    KontrolerJadwalPembayaran controller,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      height: 50,
      child: Obx(() {
        if (controller.isSearchOpen.value) {
          return Row(
            children: [
              Expanded(
                child: TextField(
                  autofocus: true,
                  onChanged: (val) => controller.searchQuery.value = val,
                  decoration: InputDecoration(
                    hintText: 'Cari jadwal...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Theme.of(context).cardColor,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: () {
                  controller.searchQuery.value = '';
                  controller.isSearchOpen.value = false;
                },
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(
                        context,
                      ).colorScheme.error.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Icon(
                    Icons.close,
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ),
            ],
          );
        }

        return Row(
          children: [
            GestureDetector(
              onTap: () => controller.isSearchOpen.value = true,
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.search,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: GestureDetector(
                onTap: () async {
                  DateTimeRange? picked = await showDateRangePicker(
                    context: context,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                  );
                  if (picked != null) {
                    controller.selectedDateRange.value = picked;
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Theme.of(context).dividerColor),
                  ),
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: AppTheme.info,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "${DateFormat('d MMMM yyyy', 'id_ID').format(controller.selectedDateRange.value.start)} - ${DateFormat('dd/MM/yyyy').format(controller.selectedDateRange.value.end)}",
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  void _konfirmasiBayar(
    BuildContext context,
    KontrolerJadwalPembayaran controller,
    ModelJadwalPembayaran item,
  ) {
    Get.defaultDialog(
      title: "Konfirmasi",
      middleText: "Bayar tagihan '${item.name}' sekarang?",
      textConfirm: "Ya, Bayar",
      textCancel: "Batal",
      confirmTextColor: Theme.of(context).colorScheme.onPrimary,
      buttonColor: Theme.of(context).primaryColor,
      radius: 12,
      onConfirm: () {
        controller.markAsPaid(item);
        Get.back();
      },
    );
  }

  void _konfirmasiHapus(
    BuildContext context,
    KontrolerJadwalPembayaran controller,
    String id,
  ) {
    Get.defaultDialog(
      title: "Hapus",
      middleText: "Yakin ingin menghapus jadwal ini?",
      textConfirm: "Hapus",
      textCancel: "Batal",
      confirmTextColor: Theme.of(context).colorScheme.onError,
      buttonColor: Theme.of(context).colorScheme.error,
      radius: 12,
      onConfirm: () {
        controller.deleteSchedule(id);
        Get.back();
      },
    );
  }
}
