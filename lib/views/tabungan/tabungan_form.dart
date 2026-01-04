import 'package:flutter/material.dart';

class TabunganForm extends StatefulWidget {
  const TabunganForm({super.key});

  @override
  State<TabunganForm> createState() => _TabunganFormState();
}

class _TabunganFormState extends State<TabunganForm> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController namaController = TextEditingController();
  final TextEditingController targetController = TextEditingController();

  DateTime? selectedDate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Target Tabungan'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // NAMA TARGET
              TextFormField(
                controller: namaController,
                decoration: const InputDecoration(
                  labelText: 'Nama Target',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama target wajib diisi';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // NOMINAL TARGET
              TextFormField(
                controller: targetController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Nominal Target',
                  prefixText: 'Rp ',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nominal wajib diisi';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // DEADLINE
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Deadline'),
                subtitle: Text(
                  selectedDate == null
                      ? 'Pilih tanggal'
                      : selectedDate.toString().split(' ')[0],
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );

                  if (picked != null) {
                    setState(() {
                      selectedDate = picked;
                    });
                  }
                },
              ),

              const SizedBox(height: 24),

              // TOMBOL SIMPAN
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate() &&
                      selectedDate != null) {
                    Navigator.pop(context);
                  }
                },
                child: const Text('Simpan Target'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
