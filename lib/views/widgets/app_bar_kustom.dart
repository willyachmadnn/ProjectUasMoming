import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/aplikasi_controllers.dart';
import '../../controllers/autentikasi_controllers.dart';
import '../../controllers/akun_controllers.dart';

class AppBarKustom extends StatelessWidget implements PreferredSizeWidget {
  final KontrolerAplikasi appCtrl = Get.find<KontrolerAplikasi>();
  final KontrolerAutentikasi authCtrl = Get.find<KontrolerAutentikasi>();
  final KontrolerAkun akunCtrl = Get.put(KontrolerAkun());
  final String? judul;

  AppBarKustom({super.key, this.judul});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.of(context).canPop();

    return AppBar(
      title: judul != null
          ? Text(
        judul!,
        style: TextStyle(
          color: Theme.of(context).textTheme.titleLarge?.color,
          fontWeight: FontWeight.bold,
        ),
      )
          : null,
      leading: canPop
          ? IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Get.back(),
        tooltip: 'Kembali',
      )
          : Builder(
        builder: (context) => IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
          tooltip: 'Menu',
        ),
      ),
      centerTitle: false,
      actions: [
        Obx(
              () => IconButton(
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, animation) {
                return RotationTransition(turns: animation, child: child);
              },
              child: Icon(
                appCtrl.isDarkMode.value ? Icons.light_mode : Icons.dark_mode,
                key: ValueKey(appCtrl.isDarkMode.value),
              ),
            ),
            onPressed: () => appCtrl.toggleTheme(),
            tooltip: appCtrl.isDarkMode.value ? 'Mode Terang' : 'Mode Gelap',
          ),
        ),
        const SizedBox(width: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          child: Row(
            children: [
              const SizedBox(width: 8),
              Obx(() {
                final String path = akunCtrl.photoUrl.value;
                final ImageProvider? image = _getProfileImage(path);

                return GestureDetector(
                  onTap: () {
                    appCtrl.changeMenu(4);
                    Get.toNamed('/akun');
                  },
                  child: CircleAvatar(
                    radius: 16,
                    backgroundColor: Theme.of(context).dividerColor,
                    backgroundImage: image,
                    child: image == null
                        ? Icon(
                      Icons.person,
                      size: 20,
                      color: Theme.of(context).iconTheme.color,
                    )
                        : null,
                  ),
                );
              }),
            ],
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () {
            appCtrl.changeMenu(4);
            Get.toNamed('/akun');
          },
          tooltip: 'Pengaturan',
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  ImageProvider? _getProfileImage(String path) {
    if (path.isEmpty) {
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
}