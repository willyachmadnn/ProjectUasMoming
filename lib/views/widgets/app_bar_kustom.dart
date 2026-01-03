import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/aplikasi_controllers.dart';
import '../../controllers/autentikasi_controllers.dart';

class AppBarKustom extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final KontrolerAplikasi appCtrl = Get.find<KontrolerAplikasi>();
  final KontrolerAutentikasi authCtrl = Get.find<KontrolerAutentikasi>();

  AppBarKustom({super.key, required this.title});

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      // Explicitly define leading to ensure Drawer works reliably
      leading: Builder(
        builder: (context) => IconButton(
          icon: Icon(Icons.menu),
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
          tooltip: 'Menu',
        ),
      ),
      title: Text(title),
      centerTitle: false, // Align title to the left
      actions: [
        // 1. Theme Toggle
        Obx(
          () => IconButton(
            icon: AnimatedSwitcher(
              duration: Duration(milliseconds: 300),
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
        SizedBox(width: 8),

        // 2. Profile Component (Static)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          child: Row(
            children: [
              Obx(
                () => Text(
                  authCtrl.userName.value,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
              SizedBox(width: 8),
              CircleAvatar(
                radius: 16,
                backgroundColor: Colors.grey[300],
                child: Icon(Icons.person, size: 20, color: Colors.grey[700]),
              ),
            ],
          ),
        ),
        SizedBox(width: 8),

        // 3. Settings Icon
        IconButton(
          icon: Icon(Icons.settings),
          onPressed: () {
            appCtrl.changeMenu(4); // Set active menu to Settings (index 4)
            Get.toNamed('/akun');
          },
          tooltip: 'Pengaturan',
        ),
        SizedBox(width: 8),
      ],
    );
  }
}
