import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/absensi.dart';
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

  Future<void> _loginAdmin() async {
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
      // Login admin berhasil
      print('Login admin berhasil');
      _clearForm();
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => EmployeeAttendancePage()),
      );
    } else {
      // Login admin gagal, cek sebagai login tamu
      _loginGuest();
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _loginGuest() async {
    final username = _usernameController.text;
    final password = _passwordController.text;

    final QuerySnapshot snapshot = await userCollection
        .where('nama', isEqualTo: username)
        .where('password', isEqualTo: password)
        .where('isAdmin', isEqualTo: false)
        .get();

    if (snapshot.docs.isNotEmpty) {
      // Login tamu berhasil
      print('Login tamu berhasil');
      _clearForm();
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => AttendanceListPage()),
      );
    } else {
      // Login tamu gagal
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
          children: [
            TextFormField(
              controller: _usernameController,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            TextFormField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            ElevatedButton(
              onPressed: _isLoading ? null : _loginAdmin,
              child: _isLoading
                  ? CircularProgressIndicator()
                  : const Text('Login'),
            ),
            ElevatedButton(
              onPressed: _loginGuest,
              child: const Text('Login as Guest'),
            ),
          ],
        ),
      ),
    );
  }
}


