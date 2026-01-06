import 'package:flutter/material.dart';
import '../widgets/app_bar_kustom.dart';

class KebijakanPrivasiView extends StatelessWidget {
  const KebijakanPrivasiView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarKustom(judul: 'Kebijakan Privasi'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Kebijakan Privasi',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              'Kami menghargai privasi Anda. Dokumen ini menjelaskan bagaimana kami mengumpulkan, menggunakan, dan melindungi informasi pribadi Anda.\n\n'
              '1. Pengumpulan Data\n'
              'Kami mengumpulkan informasi yang Anda berikan secara langsung, seperti nama pengguna dan alamat email saat pendaftaran.\n\n'
              '2. Penggunaan Data\n'
              'Data Anda digunakan untuk menyediakan layanan, memproses transaksi, dan meningkatkan pengalaman pengguna.\n\n'
              '3. Keamanan Data\n'
              'Kami menerapkan langkah-langkah keamanan untuk melindungi data Anda dari akses yang tidak sah.\n\n',
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}
