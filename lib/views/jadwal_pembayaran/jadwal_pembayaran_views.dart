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
      appBar: AppBarKustom(),
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
                        return SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(minWidth: 800),
                            child: Column(
                              children: [
                                _buildTableHeader(context),
                                Obx(() {
                                  if (controller.filteredSchedules.isEmpty) {
                                    return Padding(
                                      padding: EdgeInsets.all(40),
                                      child: Center(
                                        child: Text(
                                          'Tidak ada jadwal pembayaran',
                                        ),
                                      ),
                                    );
                                  }
                                  return ListView.separated(
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    itemCount:
                                        controller.filteredSchedules.length,
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
                            ),
                          ),
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
                        Text('Page 1', style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color)),
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
                                style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
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

  Widget _buildFilterBar(BuildContext context, KontrolerJadwalPembayaran controller) {
    // Implement filter bar if needed, or placeholder
    return Row(
      children: [
        Expanded(
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Cari jadwal...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 16),
            ),
            onChanged: (val) {
              // Implement search logic if available in controller
            },
          ),
        ),
        SizedBox(width: 16),
        ElevatedButton.icon(
          onPressed: () => Get.dialog(DialogTambahJadwal(controller: controller)),
          icon: Icon(Icons.add),
          label: Text('Tambah Jadwal'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildTableHeader(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text('Nama Tagihan', style: TextStyle(fontWeight: FontWeight.bold))),
          Expanded(flex: 1, child: Text('Jatuh Tempo', style: TextStyle(fontWeight: FontWeight.bold))),
          Expanded(flex: 1, child: Text('Nominal', style: TextStyle(fontWeight: FontWeight.bold))),
          Expanded(flex: 1, child: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
          Expanded(flex: 1, child: Text('Aksi', style: TextStyle(fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }

  Widget _buildTableRow(BuildContext context, KontrolerJadwalPembayaran controller, ModelJadwalPembayaran item) {
    final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final dateFormat = DateFormat('dd MMM yyyy', 'id_ID');

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text(item.name)),
          Expanded(flex: 1, child: Text(dateFormat.format(item.dueDate))),
          Expanded(flex: 1, child: Text(currencyFormat.format(item.amount))),
          Expanded(
            flex: 1,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: (item.isPaid ? Colors.green : Theme.of(context).colorScheme.error).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                item.isPaid ? 'Lunas' : 'Belum Lunas',
                style: TextStyle(
                  color: item.isPaid ? Colors.green : Theme.of(context).colorScheme.error,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Row(
              children: [
                if (!item.isPaid)
                  IconButton(
                    icon: Icon(Icons.check, color: Colors.green),
                    onPressed: () => controller.markAsPaid(item),
                    tooltip: 'Tandai Lunas',
                  ),
                 IconButton(
                    icon: Icon(Icons.edit, color: Theme.of(context).iconTheme.color),
                    onPressed: () => Get.dialog(DialogTambahJadwal(controller: controller, schedule: item)),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, color: Theme.of(context).colorScheme.error),
                    onPressed: () => controller.deleteSchedule(item.id),
                  ),
              ],
            ),
          ),
        ],
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
                  color: Theme.of(context).shadowColor.withValues(alpha: 0.05),
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
                        color: (item.isPaid ? Colors.green : Theme.of(context).colorScheme.error)
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        item.isPaid ? 'Lunas' : 'Belum Lunas',
                        style: TextStyle(
                          color: item.isPaid ? Colors.green : Theme.of(context).colorScheme.error,
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
                      style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color, fontSize: 12),
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
                      style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color, fontSize: 12),
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
                      icon: Icon(Icons.edit, size: 20, color: Theme.of(context).iconTheme.color),
                      onPressed: () => Get.dialog(
                        DialogTambahJadwal(
                          controller: controller,
                          schedule: item,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, size: 20, color: Theme.of(context).colorScheme.error),
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
}
