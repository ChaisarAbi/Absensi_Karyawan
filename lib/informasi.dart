import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/absensi.dart';
import 'package:flutter_application_1/login.dart';

class InformasiPage extends StatelessWidget {
  final String adminNama;

  const InformasiPage({super.key, required this.adminNama, Object? adminData});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('user')
          .where('nama', isEqualTo: adminNama)
          .get()
          .then((snapshot) => snapshot.docs.first),
      builder:
          (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Informasi'),
            ),
            body: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Informasi'),
            ),
            body: Center(
              child: Text('Error: ${snapshot.error}'),
            ),
          );
        }

        final adminData = snapshot.data?.data() as Map<String, dynamic>?;

        if (adminData == null) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Informasi'),
            ),
            body: Center(
              child: Text('Data admin not found'),
            ),
          );
        }

        final adminEmail = adminData['email'];
        final selectedRoomNames = adminData['selectedRoomNames'] ?? [];

        return Scaffold(
          appBar: AppBar(
            title: const Text('Informasi'),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Selamat datang, $adminNama!',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Informasi akun:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text('Nama: $adminNama'),
                Text('Email: $adminEmail'),
                const SizedBox(height: 16),
                const Text(
                  'Ruangan yang dapat diakses:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: selectedRoomNames.map<Widget>((roomName) {
                    return Text('- $roomName');
                  }).toList(),
                ),
              ],
            ),
          ),
          drawer: Drawer(
            child: Container(
              color: Colors.grey[200],
              child: ListView(
                padding: EdgeInsets.zero,
                children: <Widget>[
                  Container(
                    height: 150,
                    child: const DrawerHeader(
                      decoration: BoxDecoration(
                        color: Colors.blue,
                      ),
                      child: Center(
                        child: Text(
                          'Menu',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                          ),
                        ),
                      ),
                    ),
                  ),
                  ListTile(
                    title: const Text('Informasi'),
                    leading: const Icon(Icons.info),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  const Divider(
                    color: Colors.black,
                  ),
                  ListTile(
                    title: const Text('Absensi'),
                    leading: const Icon(Icons.calendar_today),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => EmployeeAttendancePage()));
                    },
                  ),
                  const Divider(
                    color: Colors.black,
                  ),
                  ListTile(
                    title: const Text('Logout'),
                    leading: const Icon(Icons.logout),
                    onTap: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LoginPage(),
                        ),
                        (route) => false,
                      );
                    },
                  ),
                  const Divider(
                    color: Colors.black,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
