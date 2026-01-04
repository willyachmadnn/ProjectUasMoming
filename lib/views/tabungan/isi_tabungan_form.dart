import 'package:flutter/material.dart';
import 'riwayat_tabungan_model.dart';

class IsiTabunganForm extends StatefulWidget {
  const IsiTabunganForm({super.key});

  @override
  State<IsiTabunganForm> createState() => _IsiTabunganFormState();
}

class _IsiTabunganFormState extends State<IsiTabunganForm> {
  final _formKey = GlobalKey<FormState>();
  final nominalController = TextEditingController();
  final catatanController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Isi Tabungan')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: nominalController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Nominal',
                  prefixText: 'Rp ',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                value == null || value.isEmpty ? 'Nominal wajib diisi' : null,
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: catatanController,
                decoration: const InputDecoration(
                  labelText: 'Catatan',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final data = RiwayatTabungan(
                      nominal: int.parse(nominalController.text),
                      catatan: catatanController.text,
                      tanggal: DateTime.now(),
                    );

                    Navigator.pop(context, data);
                  }
                },
                child: const Text('Simpan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
