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

    return Scaffold(
      appBar: AppBarKustom(title: 'Jadwal Pembayaran'),
      drawer: DrawerKustom(),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header / Description if needed (omitted based on image, title is in AppBar/Top)

            // Filter Bar & Action
            _buildFilterBar(context, controller),

            SizedBox(height: 24),

            // Main Content Card
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section Title
                  Padding(
                    padding: EdgeInsets.all(20),
                    child: Text(
                      'Jadwal Bulan Ini',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                  ),
                  Divider(
                    height: 1,
                    color: Theme.of(
                      context,
                    ).dividerColor.withValues(alpha: 0.1),
                  ),

                  // Table Content
                  LayoutBuilder(
                    builder: (context, constraints) {
                      if (constraints.maxWidth < 600) {
                        return _buildMobileList(context, controller);
                      } else {
                        return Column(
                          children: [
                            _buildTableHeader(context),
                            Obx(() {
                              if (controller.filteredSchedules.isEmpty) {
                                return Padding(
                                  padding: EdgeInsets.all(40),
                                  child: Center(
                                    child: Text('Tidak ada jadwal pembayaran'),
                                  ),
                                );
                              }
                              return ListView.separated(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: controller.filteredSchedules.length,
                                separatorBuilder: (ctx, i) => Divider(
                                  height: 1,
                                  color: Theme.of(
                                    context,
                                  ).dividerColor.withValues(alpha: 0.1),
                                ),
                                itemBuilder: (ctx, i) => _buildTableRow(
                                  context,
                                  controller,
                                  controller.filteredSchedules[i],
                                ),
                              );
                            }),
                          ],
                        );
                      }
                    },
                  ),

                  // Pagination (Static for now as per image example "Page 1")
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Page 1', style: TextStyle(color: Colors.grey)),
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(Icons.chevron_left),
                              onPressed: () {},
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '1',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.chevron_right),
                              onPressed: () {},
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileList(
    BuildContext context,
    KontrolerJadwalPembayaran controller,
  ) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    final dateFormat = DateFormat('dd MMM yyyy', 'id_ID');

    return Obx(() {
      if (controller.filteredSchedules.isEmpty) {
        return Padding(
          padding: EdgeInsets.all(40),
          child: Center(child: Text('Tidak ada jadwal pembayaran')),
        );
      }
      return ListView.separated(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: controller.filteredSchedules.length,
        separatorBuilder: (ctx, i) => SizedBox(height: 12),
        itemBuilder: (ctx, i) {
          final item = controller.filteredSchedules[i];
          return Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        item.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: (item.isPaid ? Colors.green : Colors.red)
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        item.isPaid ? 'Lunas' : 'Belum Lunas',
                        style: TextStyle(
                          color: item.isPaid ? Colors.green : Colors.red,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Jatuh Tempo:',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    Text(
                      dateFormat.format(item.dueDate),
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Nominal:',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    Text(
                      currencyFormat.format(item.amount),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (!item.isPaid)
                      TextButton.icon(
                        icon: Icon(
                          Icons.check_box_outlined,
                          size: 16,
                          color: Theme.of(context).primaryColor,
                        ),
                        label: Text('Bayar'),
                        onPressed: () => controller.markAsPaid(item),
                      ),
                    IconButton(
                      icon: Icon(Icons.edit, size: 20, color: Colors.grey),
                      onPressed: () => Get.dialog(
                        DialogTambahJadwal(
                          controller: controller,
                          schedule: item,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, size: 20, color: Colors.red),
                      onPressed: () => controller.deleteSchedule(item.id),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      );
    });
  }

  Widget _buildFilterBar(
    BuildContext context,
    KontrolerJadwalPembayaran controller,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isSmall = constraints.maxWidth < 800;

        List<Widget> children = [
          // Search
          Expanded(
            flex: isSmall ? 0 : 2,
            child: SizedBox(
              width: isSmall ? double.infinity : null,
              child: TextField(
                onChanged: (val) => controller.searchQuery.value = val,
                decoration: InputDecoration(
                  hintText: 'Cari jadwal...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Theme.of(context).cardColor,
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 0,
                    horizontal: 16,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 16, height: isSmall ? 16 : 0),

          // Status Filter
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
            ),
            child: Obx(
              () => DropdownButton<String>(
                value: controller.statusFilter.value,
                underline: SizedBox(),
                items: ['Semua', 'Lunas', 'Belum Lunas']
                    .map(
                      (e) =>
                          DropdownMenuItem(value: e, child: Text('Status: $e')),
                    )
                    .toList(),
                onChanged: (val) => controller.statusFilter.value = val!,
              ),
            ),
          ),
          SizedBox(width: 16, height: isSmall ? 16 : 0),

          // Month Filter
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
            ),
            child: Obx(
              () => DropdownButton<DateTime>(
                value: DateTime(
                  controller.monthFilter.value.year,
                  controller.monthFilter.value.month,
                ),
                underline: SizedBox(),
                // Generate list from 1 year ago to 2 years in future
                items: List.generate(36, (i) {
                  final date = DateTime(
                    DateTime.now().year - 1,
                    DateTime.now().month + i,
                  );
                  return DropdownMenuItem(
                    value: date,
                    child: Text(DateFormat('MMMM yyyy', 'id_ID').format(date)),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) controller.monthFilter.value = val;
                },
              ),
            ),
          ),

          if (!isSmall) Spacer(),
          SizedBox(width: 16, height: isSmall ? 16 : 0),

          // Add Button
          ElevatedButton.icon(
            onPressed: () =>
                Get.dialog(DialogTambahJadwal(controller: controller)),
            icon: Icon(Icons.add),
            label: Text('Tambah Jadwal Baru'),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ];

        if (isSmall) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: children,
          );
        } else {
          return Row(children: children);
        }
      },
    );
  }

  Widget _buildTableHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      color: Theme.of(context).brightness == Brightness.dark
          ? Colors.white.withValues(alpha: 0.05)
          : Colors.grey[100],
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              'Nama Tagihan',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Jatuh Tempo',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Estimasi Nominal',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Status',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(
            width: 80,
            child: Text(
              'Aksi',
              style: TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableRow(
    BuildContext context,
    KontrolerJadwalPembayaran controller,
    ModelJadwalPembayaran item,
  ) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              item.name,
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(flex: 2, child: Text(dateFormat.format(item.dueDate))),
          Expanded(flex: 2, child: Text(currencyFormat.format(item.amount))),
          Expanded(
            flex: 2,
            child: Text(
              item.isPaid ? 'Lunas' : 'Belum Lunas',
              style: TextStyle(
                color: item.isPaid ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(
            width: 80,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (!item.isPaid)
                  IconButton(
                    icon: Icon(
                      Icons.check_box_outlined,
                      color: Theme.of(context).primaryColor,
                    ),
                    tooltip: 'Tandai Lunas',
                    onPressed: () => controller.markAsPaid(item),
                  )
                else
                  Icon(Icons.check_circle, color: Colors.green),

                PopupMenuButton<String>(
                  icon: Icon(Icons.more_horiz),
                  onSelected: (val) {
                    if (val == 'edit') {
                      Get.dialog(
                        DialogTambahJadwal(
                          controller: controller,
                          schedule: item,
                        ),
                      );
                    } else if (val == 'delete') {
                      controller.deleteSchedule(item.id);
                    }
                  },
                  itemBuilder: (ctx) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 16),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 16, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Hapus', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
