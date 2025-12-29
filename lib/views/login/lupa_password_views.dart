import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/autentikasi_controllers.dart';

class TampilanLupaPassword extends StatelessWidget {
  final KontrolerAutentikasi authCtrl = Get.find<KontrolerAutentikasi>();
  final TextEditingController emailCtrl = TextEditingController();

  TampilanLupaPassword({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE0E5EC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: Container(
            constraints: BoxConstraints(maxWidth: 450),
            padding: EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: Color(0xFFE0E5EC),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.8),
                  offset: Offset(-6, -6),
                  blurRadius: 16,
                ),
                BoxShadow(
                  color: Color(0xFFA3B1C6).withValues(alpha: 0.5),
                  offset: Offset(6, 6),
                  blurRadius: 16,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Lupa Password',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 30),
                
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Pesan',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Masukan email Anda dan tunggu kode etik akan dikirimkan.',
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
                SizedBox(height: 24),

                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Masukan Email',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                      fontSize: 14,
                    ),
                  ),
                ),
                SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: TextField(
                    controller: emailCtrl,
                    decoration: InputDecoration(
                      hintText: 'Email',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                ),
                
                SizedBox(height: 32),

                Obx(() => authCtrl.isLoading.value
                  ? CircularProgressIndicator()
                  : SizedBox(
                      width: 200,
                      height: 45,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF34495E),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          authCtrl.resetPassword(emailCtrl.text);
                        },
                        child: Text(
                          'Kirim',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
