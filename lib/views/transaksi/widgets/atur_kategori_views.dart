import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:financial/controllers/transaksi_controllers.dart';
import 'package:financial/models/kategori_models.dart';
import '../../../../theme/app_theme.dart';

class AturKategoriViews extends StatelessWidget {
  const AturKategoriViews({super.key});

  @override
  Widget build(BuildContext context) {
    final KontrolerTransaksi controller = Get.find<KontrolerTransaksi>();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "Pengaturan Kategori",
            style: TextStyle(
              color: Theme.of(context).textTheme.titleLarge?.color,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: Theme.of(context).iconTheme.color,
            ),
            onPressed: () => Get.back(),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(60),
            child: Container(
              height: 45,
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Theme.of(context).dividerColor),
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
              child: TabBar(
                dividerColor: Colors.transparent,
                indicatorSize: TabBarIndicatorSize.tab,
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Theme.of(context).primaryColor,
                ),
                labelColor: Theme.of(context).colorScheme.onPrimary,
                unselectedLabelColor: Theme.of(
                  context,
                ).textTheme.bodyMedium?.color,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                unselectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.normal,
                ),
                tabs: const [
                  Tab(text: "Pengeluaran"),
                  Tab(text: "Pemasukan"),
                ],
              ),
            ),
          ),
        ),
        body: TabBarView(
          children: [
            _buildCategoryList(controller, 'expense'),
            _buildCategoryList(controller, 'income'),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Theme.of(context).primaryColor,
          child: Icon(
            Icons.add,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
          onPressed: () {
            Get.dialog(DialogFormKategori(controller: controller));
          },
        ),
      ),
    );
  }

  Widget _buildCategoryList(KontrolerTransaksi ctrl, String type) {
    return Obx(() {
      final filteredList = ctrl.categories
          .where((c) => c.type == type)
          .toList();

      if (filteredList.isEmpty) {
        return Center(
          child: Text(
            "Belum ada kategori",
            style: TextStyle(color: Theme.of(Get.context!).hintColor),
          ),
        );
      }

      return ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: filteredList.length,
        separatorBuilder: (context, index) => const Divider(),
        itemBuilder: (context, index) {
          final cat = filteredList[index];
          return ListTile(
            contentPadding: EdgeInsets.zero,
            leading: CircleAvatar(
              backgroundColor: type == 'expense'
                  ? AppTheme.error.withValues(alpha: 0.1)
                  : AppTheme.success.withValues(alpha: 0.1),
              child: Icon(
                type == 'expense' ? Icons.outbound : Icons.input,
                color: type == 'expense' ? AppTheme.error : AppTheme.success,
                size: 20,
              ),
            ),
            title: Text(
              cat.name,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.edit,
                    color:
                        Theme.of(
                          context,
                        ).iconTheme.color?.withValues(alpha: 0.7) ??
                        Theme.of(context).disabledColor,
                    size: 20,
                  ),
                  onPressed: () {
                    Get.dialog(
                      DialogFormKategori(controller: ctrl, category: cat),
                    );
                  },
                ),
                IconButton(
                  icon: Icon(
                    Icons.delete,
                    color: Theme.of(context).colorScheme.error,
                    size: 20,
                  ),
                  onPressed: () {
                    Get.defaultDialog(
                      title: "Hapus Kategori",
                      middleText:
                          "Yakin ingin menghapus kategori '${cat.name}'?",
                      textConfirm: "Ya, Hapus",
                      textCancel: "Batal",
                      confirmTextColor: Theme.of(context).colorScheme.onError,
                      buttonColor: Theme.of(context).colorScheme.error,
                      onConfirm: () {
                        ctrl.deleteCategory(cat.id);
                        Get.back();
                      },
                    );
                  },
                ),
              ],
            ),
          );
        },
      );
    });
  }
}

class DialogFormKategori extends StatefulWidget {
  final KontrolerTransaksi controller;
  final ModelKategori? category;

  const DialogFormKategori({
    super.key,
    required this.controller,
    this.category,
  });

  @override
  State<DialogFormKategori> createState() => _DialogFormKategoriState();
}

class _DialogFormKategoriState extends State<DialogFormKategori> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late String _type;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category?.name ?? '');
    _type = widget.category?.type ?? 'expense';
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.category == null ? 'Tambah Kategori' : 'Edit Kategori',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.titleLarge?.color,
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Nama Kategori',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (val) =>
                      val == null || val.isEmpty ? 'Wajib diisi' : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _type,
                  decoration: InputDecoration(
                    labelText: 'Tipe',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'expense',
                      child: Text('Pengeluaran'),
                    ),
                    DropdownMenuItem(value: 'income', child: Text('Pemasukan')),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => _type = val);
                  },
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: Text(
                        'Batal',
                        style: TextStyle(color: Theme.of(context).primaryColor),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          if (widget.category == null) {
                            widget.controller.addCategory(
                              ModelKategori(
                                id: '',
                                name: _nameController.text,
                                type: _type,
                              ),
                            );
                          } else {
                            widget.controller.updateCategory(
                              ModelKategori(
                                id: widget.category!.id,
                                name: _nameController.text,
                                type: _type,
                              ),
                            );
                          }
                          Get.back();
                        }
                      },
                      child: Text(
                        'Simpan',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
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
