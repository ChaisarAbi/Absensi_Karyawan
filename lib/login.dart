import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/absensi.dart';
import 'package:flutter_application_1/informasi.dart';
import 'package:flutter_application_1/list.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection('user');

  bool _isLoading = false;

  Future<void> _loginAdmin(BuildContext context) async {
    setState(() {
      _isLoading = true;
    });

    final username = _usernameController.text;
    final password = _passwordController.text;

    final QuerySnapshot snapshot = await userCollection
        .where('nama', isEqualTo: username)
        .where('password', isEqualTo: password)
        .where('isAdmin', isEqualTo: true)
        .get();

    if (snapshot.docs.isNotEmpty) {
      final adminData = snapshot.docs.first.data() as Map<String, dynamic>;
      print('Login admin berhasil');
      _clearForm();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => InformasiPage(adminNama: adminData['nama']),
        ),
      );
    } else {
      _loginGuest(context);
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _loginGuest(BuildContext context) async {
    final username = _usernameController.text;
    final password = _passwordController.text;

    final QuerySnapshot snapshot = await userCollection
        .where('nama', isEqualTo: username)
        .where('password', isEqualTo: password)
        .where('isAdmin', isEqualTo: false)
        .get();

    if (snapshot.docs.isNotEmpty) {
      print('Login tamu berhasil');
      _clearForm();
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => AttendanceListPage()),
      );
    } else {
      print('Login tamu gagal');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Username atau password yang dimasukkan salah.'),
        ),
      );
    }
  }

  void _clearForm() {
    _usernameController.clear();
    _passwordController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextFormField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Username',
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 16.0),
            TextFormField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
                prefixIcon: Icon(Icons.lock),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 24.0),
            ElevatedButton(
              onPressed: _isLoading ? null : () => _loginAdmin(context),
              child: _isLoading
                  ? SizedBox(
                      width: 20.0,
                      height: 20.0,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                      ),
                    )
                  : const Text('Login'),
            ),
            const SizedBox(height: 16.0),
            TextButton(
              onPressed: () => _loginGuest(context),
              child: const Text('Login as Guest'),
            ),
          ],
        ),
      ),
    );
  }
}
