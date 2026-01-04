import 'package:flutter/material.dart';
import '../widgets/drawer_kustom.dart';
import '../widgets/app_bar_kustom.dart';

class TampilanAkun extends StatelessWidget {
  const TampilanAkun({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarKustom(),
      drawer: DrawerKustom(),
      body: Center(child: Text('Halaman Pengaturan segera rilis')),
    );
  }
}
