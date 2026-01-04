import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../controllers/transaksi_controllers.dart'; // Sesuaikan path import controller

class BarFilterTransaksi extends StatelessWidget {
  const BarFilterTransaksi({super.key});

  @override
  Widget build(BuildContext context) {
    // Ambil controller yang sudah di-put di view induk
    final controller = Get.find<KontrolerTransaksi>();
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      height: 50, // Tinggi fix agar rapi
      child: Obx(() {
        // --- MODE 1: PENCARIAN AKTIF ---
        if (controller.isSearchOpen.value) {
          return Row(
            children: [
              Expanded(
                child: TextField(
                  autofocus: true,
                  onChanged: controller.onSearchChanged,
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Cari transaksi...',
                    hintStyle: TextStyle(color: Theme.of(context).hintColor),
                    prefixIcon: Icon(
                      Icons.search,
                      color: Theme.of(context).iconTheme.color,
                    ),
                    filled: true,
                    fillColor: Theme.of(context).cardColor,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 0,
                      horizontal: 20,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // Tombol Close (X)
              GestureDetector(
                onTap: () => controller.toggleSearch(),
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

        // --- MODE 2: DEFAULT HEADER (Search Icon - Kalender - Kategori) ---
        return Row(
          children: [
            // 1. TOMBOL SEARCH (KIRI)
            GestureDetector(
              onTap: () => controller.toggleSearch(),
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(12),
                  // Efek border tipis agar terlihat seperti tombol
                  border: Border.all(color: Theme.of(context).dividerColor),
                ),
                child: Icon(
                  Icons.search,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),

            const SizedBox(width: 10),

            // 2. KALENDER (TENGAH - Expanded)
            Expanded(
              flex: 3,
              child: GestureDetector(
                onTap: () async {
                  // Munculkan Date Range Picker bawaan Flutter
                  DateTimeRange? picked = await showDateRangePicker(
                    context: context,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                    initialDateRange: controller.selectedDateRange.value,
                    builder: (context, child) {
                      return Theme(
                        data: Theme.of(context), // Gunakan tema aplikasi
                        child: child!,
                      );
                    },
                  );
                  if (picked != null) {
                    controller.updateDateRange(picked);
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
                      Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: Theme.of(context).hintColor,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          // Format: 01/01/2026 - 31/01/2026
                          "${dateFormat.format(controller.selectedDateRange.value.start)} - ${dateFormat.format(controller.selectedDateRange.value.end)}",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(width: 10),

            // 3. KATEGORI (KANAN - Expanded)
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Theme.of(context).dividerColor),
                ),
                alignment: Alignment.center,
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: controller.selectedCategory.value,
                    isExpanded: true,
                    icon: Icon(
                      Icons.keyboard_arrow_down,
                      color: Theme.of(context).iconTheme.color,
                    ),
                    dropdownColor: Theme.of(context).cardColor,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                    items:
                        [
                          'Semua Kategori',
                          ...controller.categories.map((c) => c.name).toSet(),
                        ].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value, overflow: TextOverflow.ellipsis),
                          );
                        }).toList(),
                    onChanged: (val) {
                      if (val != null) controller.onCategoryChanged(val);
                    },
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
