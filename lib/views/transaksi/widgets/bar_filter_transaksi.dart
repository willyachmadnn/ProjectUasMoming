import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../controllers/transaksi_controllers.dart';
import 'dialog_transaksi.dart';

class BarFilterTransaksi extends StatelessWidget {
  final KontrolerTransaksi controller;

  const BarFilterTransaksi({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxWidth < 800;

        return Container(
          padding: EdgeInsets.only(bottom: 16),
          child: Wrap(
            spacing: 16,
            runSpacing: 16,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              // Search Bar
              SizedBox(
                width: isSmallScreen ? double.infinity : 250,
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Cari transaksi...',
                    hintStyle: TextStyle(color: Theme.of(context).hintColor),
                    prefixIcon: Icon(
                      Icons.search,
                      color: Theme.of(context).iconTheme.color,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: Theme.of(context).dividerColor,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: Theme.of(context).dividerColor,
                      ),
                    ),
                    filled: true,
                    fillColor: Theme.of(context).cardColor,
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 0,
                      horizontal: 16,
                    ),
                  ),
                  onChanged: controller.onSearchChanged,
                ),
              ),

              // Category Dropdown
              Obx(
                () => Container(
                  width: isSmallScreen ? (constraints.maxWidth / 2 - 8) : 180,
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    border: Border.all(color: Theme.of(context).dividerColor),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: controller.selectedCategory.value,
                      icon: Icon(
                        Icons.keyboard_arrow_down,
                        color: Theme.of(context).iconTheme.color,
                      ),
                      isExpanded: true,
                      dropdownColor: Theme.of(context).cardColor,
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                      items:
                          [
                            'Semua Kategori',
                            ...controller.categories.map((c) => c.name).toSet(),
                          ].map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                      onChanged: controller.onCategoryChanged,
                    ),
                  ),
                ),
              ),

              // Month Dropdown (Simplified as 'Bulan Ini' etc or actual months)
              // For now, implementing a basic Month selector logic
              Obx(
                () => Container(
                  width: isSmallScreen ? (constraints.maxWidth / 2 - 8) : 150,
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    border: Border.all(color: Theme.of(context).dividerColor),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<DateTime>(
                      value: DateTime(
                        controller.selectedMonth.value.year,
                        controller.selectedMonth.value.month,
                      ),
                      icon: Icon(
                        Icons.keyboard_arrow_down,
                        color: Theme.of(context).iconTheme.color,
                      ),
                      isExpanded: true,
                      dropdownColor: Theme.of(context).cardColor,
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                      // Generate last 12 months
                      items: List.generate(12, (index) {
                        final date = DateTime.now().subtract(
                          Duration(days: 30 * index),
                        );
                        final normalizedDate = DateTime(date.year, date.month);
                        return DropdownMenuItem<DateTime>(
                          value: normalizedDate,
                          child: Text(
                            DateFormat(
                              'MMMM yyyy',
                              'id_ID',
                            ).format(normalizedDate),
                          ),
                        );
                      }).toList(),
                      onChanged: controller.onMonthChanged,
                    ),
                  ),
                ),
              ),

              if (!isSmallScreen) Spacer(),

              // Buttons
              if (isSmallScreen) ...[
                SizedBox(width: double.infinity, height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => Get.dialog(
                          DialogTambahKategori(controller: controller),
                        ),
                        icon: Icon(Icons.add),
                        label: Text('Kategori'),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => Get.dialog(
                          DialogTambahTransaksi(controller: controller),
                        ),
                        icon: Icon(Icons.add, color: Colors.white),
                        label: Text(
                          'Transaksi',
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ] else ...[
                // Add Category Button
                OutlinedButton.icon(
                  onPressed: () =>
                      Get.dialog(DialogTambahKategori(controller: controller)),
                  icon: Icon(Icons.add),
                  label: Text('Tambah Kategori'),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),

                SizedBox(width: 16),

                // Add Transaction Button
                ElevatedButton.icon(
                  onPressed: () =>
                      Get.dialog(DialogTambahTransaksi(controller: controller)),
                  icon: Icon(Icons.add, color: Colors.white),
                  label: Text(
                    'Tambah Transaksi',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
