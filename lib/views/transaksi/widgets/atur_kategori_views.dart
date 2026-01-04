import 'package:flutter/material.dart';
import 'package:get/get.dart';
// MENGGUNAKAN ABSOLUTE IMPORT AGAR AMAN DARI ERROR PATH
import 'package:financial/controllers/transaksi_controllers.dart';
import 'package:financial/models/kategori_models.dart';

class AturKategoriViews extends StatelessWidget {
  const AturKategoriViews({super.key});

  @override
  Widget build(BuildContext context) {
    // Inject Controller
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
                    color: Theme.of(context).shadowColor.withOpacity(0.05),
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
                labelColor: Colors.white,
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
          backgroundColor: const Color(0xFF2563EB),
          child: const Icon(Icons.add, color: Colors.white),
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
            style: TextStyle(color: Colors.grey[400]),
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
                  ? Colors.red.withOpacity(0.1)
                  : Colors.green.withOpacity(0.1),
              child: Icon(
                type == 'expense' ? Icons.outbound : Icons.input,
                color: type == 'expense' ? Colors.red : Colors.green,
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
                  icon: const Icon(
                    Icons.edit,
                    color: Colors.blueGrey,
                    size: 20,
                  ),
                  onPressed: () {
                    Get.dialog(
                      DialogFormKategori(controller: ctrl, category: cat),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(
                    Icons.delete,
                    color: Colors.redAccent,
                    size: 20,
                  ),
                  onPressed: () {
                    Get.defaultDialog(
                      title: "Hapus Kategori",
                      middleText:
                          "Yakin ingin menghapus kategori '${cat.name}'?",
                      textConfirm: "Ya, Hapus",
                      textCancel: "Batal",
                      confirmTextColor: Colors.white,
                      buttonColor: Colors.red,
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
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.category != null;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: context.width > 400 ? 400 : context.width * 0.9,
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isEdit ? 'Edit Kategori' : 'Tambah Kategori',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),

              TextFormField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
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
                onChanged: isEdit
                    ? null
                    : (val) => setState(() => _type = val!),
              ),

              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    style: TextButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => Get.back(),
                    child: const Text('Batal'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        if (isEdit) {
                          final updatedCat = ModelKategori(
                            id: widget.category!.id,
                            name: _nameController.text,
                            type: _type,
                          );
                          widget.controller.updateCategory(updatedCat);
                        } else {
                          final newCat = ModelKategori(
                            id: '',
                            name: _nameController.text,
                            type: _type,
                          );
                          widget.controller.addCategory(newCat);
                        }
                        Get.back();
                      }
                    },
                    child: Text(isEdit ? 'Update' : 'Simpan'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
