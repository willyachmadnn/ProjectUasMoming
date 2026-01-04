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
      backgroundColor: Color(0xFFF5F6FA), // Abu-abu sangat muda
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 800) {
            // Desktop Layout: Row (Split Screen)
            return Row(
              children: [
                Expanded(child: Container()), // Spacer Kiri
                Container(
                  width: 450,
                  margin: EdgeInsets.symmetric(vertical: 40),
                  child: Center(child: _buildUnifiedFormCard(context)),
                ),
                Expanded(child: Container()), // Spacer Kanan
              ],
            );
          } else {
            // Mobile Layout: Center + SingleChildScrollView
            return Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(24),
                child: _buildUnifiedFormCard(context),
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildUnifiedFormCard(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(32), // Reduced padding
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: Offset(0, 10),
            blurRadius: 30,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // Kartu hanya setinggi konten
        children: [
          // 1. Logo & Branding (Menyatu dalam kartu)
          Image.asset(
            Get.isDarkMode ? 'assets/sakuku2.png' : 'assets/sakuku.png',
            height: 60, // Reduced height
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => Icon(
              Icons.account_balance_wallet,
              size: 60,
              color: Theme.of(context).primaryColor,
            ),
          ),
          SizedBox(height: 12), // Reduced spacing
          Text(
            'Sakuku',
            style: TextStyle(
              fontSize: 24, // Reduced font size
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.titleLarge?.color,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Masa Depan Cerah Dimulai dari Catatan Kecil',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ), // Reduced font size
          ),
          SizedBox(height: 24), // Reduced spacing
          // 2. Form Input
          _buildTextField(
            context,
            label: 'Username',
            hint: 'Masukan username anda',
            controller: usernameCtrl,
            icon: Icons.person_outline,
          ),
          SizedBox(height: 16), // Reduced spacing

          Obx(
            () => _buildTextField(
              context,
              label: 'Password',
              hint: 'Masukan password',
              controller: passwordCtrl,
              icon: Icons.lock_outline,
              isPassword: true,
              isObscure: !authCtrl.isLoginPasswordVisible.value,
              onToggleVisibility: authCtrl.toggleLoginPasswordVisibility,
            ),
          ),
          SizedBox(height: 12), // Reduced spacing
          // 3. Links (Lupa Password & Daftar)
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              GestureDetector(
                onTap: () => Get.toNamed('/daftar'),
                child: RichText(
                  text: TextSpan(
                    text: 'Belum punya akun? ',
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 11,
                    ), // Reduced font size
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
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size(0, 0),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'Lupa password?',
                  style: TextStyle(
                    color: Color(0xFF2C3E50),
                    fontSize: 11, // Reduced font size
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 24), // Reduced spacing
          // 4. Action Buttons
          Obx(
            () => authCtrl.isLoading.value
                ? CircularProgressIndicator()
                : Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 45, // Reduced height
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF34495E),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
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
                              fontSize: 14, // Reduced font size
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 16), // Reduced spacing
                      Row(
                        children: [
                          Expanded(child: Divider()),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'ATAU',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 11, // Reduced font size
                              ),
                            ),
                          ),
                          Expanded(child: Divider()),
                        ],
                      ),
                      SizedBox(height: 16), // Reduced spacing
                      SizedBox(
                        width: double.infinity,
                        height: 45, // Reduced height
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.grey.shade300),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: Image.network(
                            'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/768px-Google_%22G%22_logo.svg.png',
                            height: 20, // Reduced icon size
                            errorBuilder: (context, error, stackTrace) =>
                                Icon(Icons.login),
                          ),
                          label: Text(
                            'Masuk dengan Google',
                            style: TextStyle(
                              color: Color(0xFF2C3E50),
                              fontWeight: FontWeight.bold,
                              fontSize: 13, // Reduced font size
                            ),
                          ),
                          onPressed: () => authCtrl.loginWithGoogle(),
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    BuildContext context, {
    required String label,
    required String hint,
    required TextEditingController controller,
    required IconData icon,
    bool isPassword = false,
    bool isObscure = false,
    VoidCallback? onToggleVisibility,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13, // Reduced font size
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        SizedBox(height: 6), // Reduced spacing
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Theme.of(context).dividerColor),
          ),
          child: TextField(
            controller: controller,
            obscureText: isObscure,
            style: TextStyle(
              fontSize: 14, // Explicit font size
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
            decoration: InputDecoration(
              isDense: true, // Compacting vertical space
              hintText: hint,
              hintStyle: TextStyle(
                fontSize: 13, // Reduced font size
                color: Theme.of(
                  context,
                ).textTheme.bodyMedium?.color?.withValues(alpha: 0.5),
              ),
              prefixIcon: Icon(
                icon,
                size: 20,
                color: Theme.of(context).iconTheme.color,
              ), // Reduced icon size
              prefixIconConstraints: BoxConstraints(
                minWidth: 40,
              ), // Tighter icon spacing
              suffixIcon: isPassword
                  ? IconButton(
                      iconSize: 20, // Reduced icon size
                      icon: Icon(
                        isObscure ? Icons.visibility_off : Icons.visibility,
                        color: Theme.of(context).iconTheme.color,
                      ),
                      onPressed: onToggleVisibility,
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16, // Reduced horizontal padding
                vertical: 14, // Reduced vertical padding
              ),
            ),
          ),
        ),
      ],
    );
  }
}
