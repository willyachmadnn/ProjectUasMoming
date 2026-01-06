import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../controllers/akun_controllers.dart';
import '../widgets/drawer_kustom.dart';
import '../widgets/app_bar_kustom.dart';
import 'widgets/dialog_akun.dart';
import 'kebijakan_privasi_views.dart';
import 'syarat_ketentuan_views.dart';

class TampilanAkun extends StatelessWidget {
  const TampilanAkun({super.key});

  @override
  Widget build(BuildContext context) {
    final KontrolerAkun controller = Get.put(KontrolerAkun());

    return Scaffold(
      appBar: AppBarKustom(judul: 'Pengaturan'),
      drawer: DrawerKustom(),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            _buildAccountCard(context, controller),
            const SizedBox(height: 16),
            _buildSectionCard(
              context,
              title: 'Tentang',
              children: [
                ListTile(
                  title: const Text('Versi Aplikasi'),
                  trailing: Text(
                    controller.appVersion.value,
                    style: TextStyle(color: Theme.of(context).hintColor),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSectionCard(
              context,
              title: 'Privasi',
              children: [
                _buildMenuItem(
                  context,
                  'Kebijakan Privasi',
                  onTap: () => Get.to(() => const KebijakanPrivasiView()),
                ),
                _buildMenuItem(
                  context,
                  'Syarat & Ketentuan',
                  onTap: () => Get.to(() => const SyaratKetentuanView()),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSectionCard(
              context,
              title: 'Data & Penyimpanan',
              children: [
                _buildMenuItem(
                  context,
                  'Ekspor Data Transaksi',
                  onTap: controller.exportData,
                ),
                const Divider(),
                ListTile(
                  title: Text(
                    'Hapus Semua Data',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onTap: controller.deleteData,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSectionCard(
              context,
              title: 'Keamanan',
              children: [
                _buildMenuItem(
                  context,
                  'Ubah Username',
                  onTap: () => Get.dialog(DialogUbahUsername()),
                ),
                _buildMenuItem(
                  context,
                  'Ubah Password',
                  onTap: () => Get.dialog(DialogUbahPassword()),
                ),
                const Divider(),
                ListTile(
                  title: Text(
                    'Hapus Akun',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onTap: controller.deleteAccount,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                ),
              ],
            ),
            const SizedBox(height: 32),
          ],
        );
      }),
    );
  }

  Widget _buildAccountCard(BuildContext context, KontrolerAkun controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Akun',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              GestureDetector(
                onTap: () => _showImagePicker(context, controller),
                child: Obx(() {
                  final String path = controller.photoUrl.value;
                  final ImageProvider? image = _getProfileImage(path);

                  return CircleAvatar(
                    radius: 30,
                    backgroundColor: Theme.of(
                      context,
                    ).disabledColor.withValues(alpha: 0.3),
                    backgroundImage: image,
                    child: image == null
                        ? Icon(
                            Icons.person,
                            size: 30,
                            color: Theme.of(
                              context,
                            ).iconTheme.color?.withValues(alpha: 0.5),
                          )
                        : null,
                  );
                }),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Obx(
                      () => Text(
                        controller.username.value,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      controller.email.value,
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).hintColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () => _showImagePicker(context, controller),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Theme.of(
                          context,
                        ).colorScheme.onPrimary,
                        minimumSize: const Size(80, 30),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        'Edit Profil',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  ImageProvider? _getProfileImage(String path) {
    if (path.isEmpty ||
        path.contains('googleusercontent.com/profile/picture/0')) {
      return null;
    }
    if (path.startsWith('http')) {
      return NetworkImage(path);
    } else {
      try {
        final file = File(path);
        if (file.existsSync()) {
          return FileImage(file);
        }
      } catch (e) {
        return null;
      }
      return null;
    }
  }

  void _showImagePicker(BuildContext context, KontrolerAkun controller) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Ganti Foto Profil',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildPickerOption(
                  context,
                  icon: Icons.photo_library,
                  label: 'Galeri',
                  onTap: () {
                    Get.back();
                    controller.pickImage(ImageSource.gallery);
                  },
                ),
                _buildPickerOption(
                  context,
                  icon: Icons.camera_alt,
                  label: 'Kamera',
                  onTap: () {
                    Get.back();
                    controller.pickImage(ImageSource.camera);
                  },
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildPickerOption(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 30, color: Theme.of(context).primaryColor),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildSectionCard(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          ...children,
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    String title, {
    required VoidCallback onTap,
  }) {
    return ListTile(
      title: Text(title, style: const TextStyle(fontSize: 14)),
      trailing: Icon(
        Icons.chevron_right,
        size: 20,
        color: Theme.of(context).hintColor,
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      dense: true,
    );
  }
}
