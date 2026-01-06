import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/akun_controllers.dart';

class DialogUbahUsername extends StatelessWidget {
  final TextEditingController usernameCtrl;
  final KontrolerAkun controller = Get.find<KontrolerAkun>();

  DialogUbahUsername({super.key})
      : usernameCtrl = TextEditingController(
    text: Get.find<KontrolerAkun>().username.value,
  );

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Ubah Username'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: usernameCtrl,
            decoration: const InputDecoration(
              labelText: 'Username Baru',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Get.back(), child: const Text('Batal')),
        ElevatedButton(
          onPressed: () {
            controller.updateUsername(usernameCtrl.text);
            Get.back();
          },
          child: const Text('Simpan'),
        ),
      ],
    );
  }
}

class DialogUbahPassword extends StatelessWidget {
  final TextEditingController newPassCtrl = TextEditingController();
  final KontrolerAkun controller = Get.find<KontrolerAkun>();

  DialogUbahPassword({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Ubah Password'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: newPassCtrl,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Kata Sandi Baru',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Get.back(), child: const Text('Batal')),
        ElevatedButton(
          onPressed: () {
            controller.updatePassword(newPassCtrl.text);
            Get.back();
          },
          child: const Text('Ubah'),
        ),
      ],
    );
  }
}