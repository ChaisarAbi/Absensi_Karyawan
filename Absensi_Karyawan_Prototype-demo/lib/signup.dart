import 'package:flutter/material.dart';
import 'package:flutter_application_1/login.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DaftarPage extends StatefulWidget {
  @override
  _DaftarPageState createState() => _DaftarPageState();
}

class _DaftarPageState extends State<DaftarPage> {
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isAdmin = false;
  bool _isLoading = false;
  List<String> _selectedRoomNames = [];

  @override
  void dispose() {
    _namaController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submitForm() async {
    setState(() {
      _isLoading = true;
    });

    final nama = _namaController.text;
    final email = _emailController.text;
    final password = _passwordController.text;

    final userData = {
      'nama': nama,
      'email': email,
      'password': password,
      'isAdmin': _isAdmin,
      'selectedRoomNames': _selectedRoomNames,
    };

    try {
      await FirebaseFirestore.instance.collection('user').add(userData);
      print('Data pendaftaran berhasil disimpan');

      _clearForm();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    } catch (error) {
      print('Gagal menyimpan data pendaftaran: $error');
      // Tampilkan pesan error ke pengguna
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _clearForm() {
    _namaController.clear();
    _emailController.clear();
    _passwordController.clear();
    setState(() {
      _isAdmin = false;
      _selectedRoomNames.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<String> roomNames = [
      'Matematika',
      'Tematik',
      'Fiqih',
      'Akidah',
      'PJOK',
      'TIK',
      'SBDP',
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Form Pendaftaran'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _namaController,
              decoration: const InputDecoration(labelText: 'Nama'),
            ),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextFormField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            CheckboxListTile(
              title: const Text('Admin'),
              value: _isAdmin,
              onChanged: (value) {
                setState(() {
                  _isAdmin = value!;
                });
              },
            ),
            const SizedBox(height: 16.0),
            Text(
              'Pilih Ruangan:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: roomNames.length,
                itemBuilder: (BuildContext context, int index) {
                  final roomName = roomNames[index];

                  return CheckboxListTile(
                    title: Text(roomName),
                    value: _selectedRoomNames.contains(roomName),
                    onChanged: (value) {
                      setState(() {
                        if (value!) {
                          _selectedRoomNames.add(roomName);
                        } else {
                          _selectedRoomNames.remove(roomName);
                        }
                      });
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _isLoading ? null : _submitForm,
              child: _isLoading
                  ? CircularProgressIndicator()
                  : const Text('Daftar'),
            ),
          ],
        ),
      ),
    );
  }
}
