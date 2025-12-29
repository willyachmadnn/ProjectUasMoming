import 'package:flutter/material.dart';
import '../widgets/drawer_kustom.dart';
import '../widgets/app_bar_kustom.dart';

class TampilanTabungan extends StatelessWidget {
  const TampilanTabungan({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarKustom(title: 'Tabungan'),
      drawer: DrawerKustom(),
      body: Center(child: Text('Halaman Tabungan')),
    );
  }
}
