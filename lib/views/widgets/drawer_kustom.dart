import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/aplikasi_controllers.dart';
import '../../controllers/autentikasi_controllers.dart';

class DrawerKustom extends StatelessWidget {
  final KontrolerAplikasi appCtrl = Get.find();

  DrawerKustom({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.black, // Hitam untuk sidebar navigasi
      child: Column(
        children: [
          // Header Menu (Logo)
          Container(
            height: 180,
            width: double.infinity,
            color: Colors.black,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Image.asset(
                  'assets/sakuku.png',
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) =>
                      Text('SAKUKU', style: TextStyle(color: Colors.white)),
                ),
              ),
            ),
          ),

          // Menu Items
          Expanded(
            child: SingleChildScrollView(
              child: Obx(
                () => Column(
                  children: [
                    _buildMenuItem(0, 'Beranda', Icons.dashboard),
                    _buildMenuItem(1, 'Transaksi', Icons.payment),
                    _buildMenuItem(
                      2,
                      'Jadwal Pembayaran',
                      Icons.calendar_today,
                    ),
                    _buildMenuItem(3, 'Tabungan', Icons.savings),
                  ],
                ),
              ),
            ),
          ),

          // Logout Menu Item (Bottom)
          Divider(color: Colors.grey[800]),
          ItemMenuKeluar(),
        ],
      ),
    );
  }

  Widget _buildMenuItem(int index, String title, IconData icon) {
    bool isActive = appCtrl.activeMenuIndex.value == index;
    return ListTile(
      leading: Icon(icon, color: isActive ? Colors.white : Colors.grey[400]),
      selected: isActive,
      selectedTileColor: Colors.grey[800],
      title: Text(
        title,
        style: TextStyle(
          color: isActive ? Colors.white : Colors.grey[400],
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      onTap: () {
        appCtrl.changeMenu(index);
        Get.back(); // Close drawer

        // Navigation logic
        switch (index) {
          case 0:
            if (Get.currentRoute != '/dashboard') Get.offNamed('/dashboard');
            break;
          case 1:
            if (Get.currentRoute != '/transaksi') Get.offNamed('/transaksi');
            break;
          case 2:
            if (Get.currentRoute != '/jadwal') {
              Get.offNamed('/jadwal');
            }
            break;
          case 3:
            if (Get.currentRoute != '/tabungan') Get.offNamed('/tabungan');
            break;
          case 4:
            if (Get.currentRoute != '/akun') Get.offNamed('/akun');
            break;
        }
      },
    );
  }
}

class ItemMenuKeluar extends StatelessWidget {
  final KontrolerAutentikasi authCtrl = Get.find<KontrolerAutentikasi>();

  ItemMenuKeluar({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(Icons.exit_to_app, color: Colors.white),
      title: Text('Keluar', style: TextStyle(color: Colors.white)),
      onTap: () => authCtrl.logout(),
    );
  }
}
