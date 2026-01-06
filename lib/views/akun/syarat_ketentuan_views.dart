import 'package:flutter/material.dart';
import '../widgets/app_bar_kustom.dart';

class SyaratKetentuanView extends StatelessWidget {
  const SyaratKetentuanView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarKustom(judul: 'Syarat & Ketentuan'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Syarat & Ketentuan',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              'Dengan menggunakan aplikasi ini, Anda menyetujui syarat dan ketentuan berikut:\n\n'
              '1. Penggunaan Layanan\n'
              'Anda bertanggung jawab atas aktivitas yang terjadi di akun Anda. Jangan bagikan kata sandi Anda kepada orang lain.\n\n'
              '2. Hak Kekayaan Intelektual\n'
              'Semua konten dalam aplikasi ini adalah milik kami atau pemberi lisensi kami.\n\n'
              '3. Perubahan Layanan\n'
              'Kami berhak mengubah atau menghentikan layanan sewaktu-waktu tanpa pemberitahuan sebelumnya.\n\n'
              '4. Batasan Tanggung Jawab\n'
              'Kami tidak bertanggung jawab atas kerugian langsung atau tidak langsung yang timbul dari penggunaan aplikasi ini.',
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}
