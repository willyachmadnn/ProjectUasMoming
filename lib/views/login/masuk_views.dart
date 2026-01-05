import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/autentikasi_controllers.dart';

class TampilanMasuk extends StatelessWidget {
  final KontrolerAutentikasi authCtrl = Get.find<KontrolerAutentikasi>();
  final TextEditingController usernameCtrl = TextEditingController();
  final TextEditingController passwordCtrl = TextEditingController();

  TampilanMasuk({super.key}) {
    if (Get.arguments != null && Get.arguments is Map) {
      final args = Get.arguments as Map;
      if (args.containsKey('username')) {
        usernameCtrl.text = args['username'];
      }
    } else {
      final saved = authCtrl.getSavedCredentials();
      if (saved['username']?.isNotEmpty ?? false) {
        usernameCtrl.text = saved['username']!;
        passwordCtrl.text = saved['password']!;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 800) {
            return Row(
              children: [
                Expanded(child: Container()),
                Container(
                  width: 450,
                  margin: const EdgeInsets.symmetric(vertical: 40),
                  child: Center(child: _buildUnifiedFormCard(context)),
                ),
                Expanded(child: Container()),
              ],
            );
          } else {
            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
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
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.05),
            offset: const Offset(0, 10),
            blurRadius: 30,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Column(
              children: [
                Image.asset(
                  Get.isDarkMode ? 'assets/sakuku2.png' : 'assets/sakuku.png',
                  height: 60,
                  fit: BoxFit.contain,
                  errorBuilder: (ctx, err, stack) => Icon(
                    Icons.account_balance_wallet,
                    size: 60,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Selamat Datang',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.titleLarge?.color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Masa Depan Cerah Dimulai dari Catatan Kecil',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          _buildFloatingLabelTextField(
            context,
            label: 'Username',
            controller: usernameCtrl,
          ),
          const SizedBox(height: 20),

          Obx(
            () => _buildFloatingLabelTextField(
              context,
              label: 'Password',
              controller: passwordCtrl,
              isPassword: true,
              isObscure: !authCtrl.isLoginPasswordVisible.value,
              onToggleVisibility: authCtrl.toggleLoginPasswordVisibility,
            ),
          ),

          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Obx(
                () => Row(
                  children: [
                    SizedBox(
                      height: 24,
                      width: 24,
                      child: Checkbox(
                        value: authCtrl.isRememberMe.value,
                        activeColor: Theme.of(context).primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        onChanged: (val) => authCtrl.isRememberMe.value = val!,
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => authCtrl.isRememberMe.value =
                          !authCtrl.isRememberMe.value,
                      child: Text(
                        "Ingat saya",
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),

              TextButton(
                onPressed: () => Get.toNamed('/lupa_password'),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  'Lupa Password?',
                  style: TextStyle(
                    color: Color(0xFF6C63FF),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          Row(
            children: [
              Text(
                'Belum punya akun? ',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              GestureDetector(
                onTap: () => Get.toNamed('/daftar'),
                child: Text(
                  'Daftar Sekarang',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Obx(
            () => authCtrl.isLoading.value
                ? const Center(child: CircularProgressIndicator())
                : SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF34495E),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () {
                        authCtrl.login(usernameCtrl.text, passwordCtrl.text);
                      },
                      child: const Text(
                        'Masuk',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
          ),

          const SizedBox(height: 20),

          Row(
            children: [
              const Expanded(child: Divider()),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'ATAU',
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Expanded(child: Divider()),
            ],
          ),

          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.grey.shade300),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: Image.network(
                'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/768px-Google_%22G%22_logo.svg.png',
                height: 20,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.login),
              ),
              label: const Text(
                'Masuk dengan Google',
                style: TextStyle(
                  color: Color(0xFF2C3E50),
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              onPressed: () => authCtrl.loginWithGoogle(),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildFloatingLabelTextField(
    BuildContext context, {
    required String label,
    required TextEditingController controller,
    bool isPassword = false,
    bool isObscure = false,
    VoidCallback? onToggleVisibility,
  }) {
    return TextField(
      controller: controller,
      obscureText: isObscure,
      style: const TextStyle(
        fontSize: 14,
        color: Color(0xFF2C3E50),
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey[600], fontSize: 14),
        floatingLabelStyle: const TextStyle(
          color: Color(0xFF34495E),
          fontWeight: FontWeight.bold,
        ),

        prefixIcon: null,

        suffixIcon: isPassword
            ? IconButton(
                iconSize: 20,
                icon: Icon(
                  isObscure ? Icons.visibility_off : Icons.visibility,
                  color: Theme.of(context).iconTheme.color,
                ),
                onPressed: onToggleVisibility,
              )
            : null,

        filled: true,
        fillColor: Theme.of(context).cardColor,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).dividerColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Theme.of(context).primaryColor,
            width: 2,
          ),
        ),

        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
    );
  }
}
