import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/autentikasi_controllers.dart';

class TampilanDaftar extends StatelessWidget {
  final KontrolerAutentikasi authCtrl = Get.find<KontrolerAutentikasi>();
  final TextEditingController usernameCtrl = TextEditingController();
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController passwordCtrl = TextEditingController();

  TampilanDaftar({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE0E5EC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Color(0xFF2C3E50)),
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
                  'Buat Akun Baru',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Bergabunglah bersama kami',
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
                SizedBox(height: 30),
                _buildTextField(
                  label: 'Username',
                  hint: 'Masukan username unik',
                  controller: usernameCtrl,
                  icon: Icons.person_outline,
                ),
                SizedBox(height: 20),
                _buildTextField(
                  label: 'Email',
                  hint: 'Masukan email anda',
                  controller: emailCtrl,
                  icon: Icons.email_outlined,
                ),
                SizedBox(height: 20),
                _buildTextField(
                  label: 'Password',
                  hint: 'Buat password kuat',
                  controller: passwordCtrl,
                  icon: Icons.lock_outline,
                  isPassword: true,
                ),
                SizedBox(height: 32),
                Obx(
                  () => authCtrl.isLoading.value
                      ? CircularProgressIndicator()
                      : SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF34495E),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 5,
                            ),
                            onPressed: () => authCtrl.register(
                              usernameCtrl.text,
                              emailCtrl.text,
                              passwordCtrl.text,
                            ),
                            child: Text(
                              'Daftar Sekarang',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
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

  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required IconData icon,
    bool isPassword = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.grey[700],
            fontSize: 14,
          ),
        ),
        SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            obscureText: isPassword,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
              prefixIcon: Icon(icon, color: Colors.grey[500], size: 20),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  }
}
