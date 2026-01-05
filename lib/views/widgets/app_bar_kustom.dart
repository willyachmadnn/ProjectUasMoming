import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/aplikasi_controllers.dart';
import '../../controllers/autentikasi_controllers.dart';

class AppBarKustom extends StatelessWidget implements PreferredSizeWidget {
  final KontrolerAplikasi appCtrl = Get.find<KontrolerAplikasi>();
  final KontrolerAutentikasi authCtrl = Get.find<KontrolerAutentikasi>();

  AppBarKustom({super.key});

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: Builder(
        builder: (context) => IconButton(
          icon: Icon(Icons.menu),
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
                backgroundColor: Theme.of(context).dividerColor,
                child: Icon(Icons.person, size: 20, color: Theme.of(context).iconTheme.color),
              ),
            ],
          ),
        ),
        SizedBox(width: 8),

        IconButton(
          icon: Icon(Icons.settings),
          onPressed: () {
            appCtrl.changeMenu(4);
            Get.toNamed('/akun');
          },
          tooltip: 'Pengaturan',
        ),
        SizedBox(width: 8),
      ],
    );
  }
}
