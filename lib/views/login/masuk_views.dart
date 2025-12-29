import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/autentikasi_controllers.dart';

class TampilanMasuk extends StatelessWidget {
  final KontrolerAutentikasi authCtrl = Get.find<KontrolerAutentikasi>();
  final TextEditingController usernameCtrl = TextEditingController();
  final TextEditingController passwordCtrl = TextEditingController();

  TampilanMasuk({super.key}) {
    // Auto-fill username if passed from registration
    if (Get.arguments != null && Get.arguments is Map) {
      final args = Get.arguments as Map;
      if (args.containsKey('username')) {
        usernameCtrl.text = args['username'];
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE0E5EC), // Soft gray background like image
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: Container(
            constraints: BoxConstraints(maxWidth: 450),
            padding: EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: Color(0xFFE0E5EC), // Neumorphic base color
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
                // Logo & Title
                Container(
                  height: 200,
                  width: double.infinity,
                  child: Image.asset(
                    'assets/sakuku.png',
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => Icon(
                      Icons.account_balance_wallet,
                      size: 90,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                ),
                SizedBox(height: 8),
                // Text(
                //   'Sakuku',
                //   style: TextStyle(
                //     fontSize: 28,
                //     fontWeight: FontWeight.bold,
                //     color: Color(0xFF2C3E50),
                //   ),
                // ),
                // SizedBox(height: 24),
                Text(
                  'Selamat Datang',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Masa Depan Cerah Dimulai dari Catatan Kecil',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
                SizedBox(height: 24),

                // Forms
                _buildTextField(
                  label: 'Username',
                  hint: 'Masukan username anda',
                  controller: usernameCtrl,
                  icon: Icons.person_outline,
                ),
                SizedBox(height: 20),
                _buildTextField(
                  label: 'Password',
                  hint: 'Masukan password',
                  controller: passwordCtrl,
                  icon: Icons.lock_outline,
                  isPassword: true,
                ),

                SizedBox(height: 16),

                // Links
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => Get.toNamed('/daftar'),
                      child: RichText(
                        text: TextSpan(
                          text: 'Belum punya akun? ',
                          style: TextStyle(color: Colors.black54, fontSize: 12),
                          children: [
                            TextSpan(
                              text: 'Daftar',
                              style: TextStyle(
                                color: Color(0xFF2C3E50),
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => Get.toNamed('/lupa_password'),
                      child: Text(
                        'Lupa password?',
                        style: TextStyle(
                          color: Color(0xFF2C3E50),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 32),

                // Login Button
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
                            onPressed: () {
                              authCtrl.login(
                                usernameCtrl.text,
                                passwordCtrl.text,
                              );
                            },
                            child: Text(
                              'Masuk',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                        ),
                ),

                SizedBox(height: 20),
                Divider(),
                SizedBox(height: 20),

                // Google Sign In
                Obx(
                  () => authCtrl.isLoading.value
                      ? SizedBox.shrink()
                      : OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            side: BorderSide(color: Colors.grey),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: Image.network(
                            'https://upload.wikimedia.org/wikipedia/commons/5/53/Google_%22G%22_Logo.svg',
                            height: 24,
                            errorBuilder: (ctx, err, stack) =>
                                Icon(Icons.g_mobiledata),
                          ),
                          label: Text(
                            'Masuk dengan Google',
                            style: TextStyle(color: Colors.black87),
                          ),
                          onPressed: () => authCtrl.loginWithGoogle(),
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
