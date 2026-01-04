import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/aplikasi_controllers.dart';
import '../../controllers/autentikasi_controllers.dart';

class DrawerKustom extends StatelessWidget {
  final KontrolerAplikasi appCtrl = Get.find();

  DrawerKustom({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Drawer(
      backgroundColor: theme.canvasColor,
      child: Column(
        children: [
          // Header Menu (Logo)
          Container(
            height: 180,
            width: double.infinity,
            color: theme.primaryColor.withValues(alpha: 0.1),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/sakuku.png',
                      height: 80,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => Icon(
                        Icons.account_balance_wallet,
                        size: 60,
                        color: theme.primaryColor,
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      '"DOMPET PRIBADI DIGITAL"',
                      style: TextStyle(
                        color: theme.textTheme.titleLarge?.color,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
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
                    _buildMenuItem(context, 0, 'Beranda', Icons.dashboard),
                    _buildMenuItem(context, 1, 'Transaksi', Icons.payment),
                    _buildMenuItem(
                      context,
                      2,
                      'Jadwal Pembayaran',
                      Icons.calendar_today,
                    ),
                    _buildMenuItem(context, 3, 'Tabungan', Icons.savings),
                  ],
                ),
              ),
            ),
          ),

          // Logout Menu Item (Bottom)
          Divider(color: theme.dividerColor),
          ItemMenuKeluar(),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    int index,
    String title,
    IconData icon,
  ) {
    final theme = Theme.of(context);
    bool isActive = appCtrl.activeMenuIndex.value == index;

    return ListTile(
      leading: Icon(
        icon,
        color: isActive
            ? theme.primaryColor
            : theme.iconTheme.color?.withValues(alpha: 0.7),
      ),
      selected: isActive,
      selectedTileColor: theme.primaryColor.withValues(alpha: 0.1),
      title: Text(
        title,
        style: TextStyle(
          color: isActive
              ? theme.primaryColor
              : theme.textTheme.bodyLarge?.color,
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
      leading: Icon(Icons.exit_to_app, color: Colors.red),
      title: Text('Keluar', style: TextStyle(color: Colors.red)),
      onTap: () => authCtrl.logout(),
    );
  }
}
