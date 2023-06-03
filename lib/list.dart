import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AttendanceListPage extends StatelessWidget {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final CollectionReference attendanceCollection =
      FirebaseFirestore.instance.collection('absen');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance List'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: attendanceCollection.snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final List<DocumentSnapshot> documents = snapshot.data!.docs;
          final Map<String, Map<String, int>> roomAttendanceMap = {};

          for (final document in documents) {
            final attendanceData = document.data() as Map<String, dynamic>;
            final roomName = attendanceData['roomName'] as String? ?? '';
            final employeeName =
                attendanceData['employeeName'] as String? ?? '';
            final status = attendanceData['status'] as String? ?? '';

            if (!roomAttendanceMap.containsKey(roomName)) {
              roomAttendanceMap[roomName] = {};
            }

            if (!roomAttendanceMap[roomName]!.containsKey(employeeName)) {
              roomAttendanceMap[roomName]![employeeName] = 0;
            }

            if (status == 'Izin' || status == 'Hadir' || status == 'Absen') {
              roomAttendanceMap[roomName]![employeeName] =
                  (roomAttendanceMap[roomName]![employeeName] ?? 0) + 1;
            }
          }

          // Mengurutkan daftar nama karyawan sesuai dengan abjad
          final sortedEmployeeNames = roomAttendanceMap.values
              .expand((attendanceDataMap) => attendanceDataMap.keys)
              .toSet()
              .toList()
            ..sort();

          return ListView.builder(
            itemCount: sortedEmployeeNames.length,
            itemBuilder: (BuildContext context, int index) {
              final employeeName = sortedEmployeeNames[index];
              final roomNames = roomAttendanceMap.keys
                  .where((roomName) =>
                      roomAttendanceMap[roomName]!.containsKey(employeeName))
                  .toList();

              return ListTile(
                title: Text(
                  employeeName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                subtitle: Text('Ruangan: ${roomNames.join(', ')}'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AttendanceDetailPage(
                        employeeName,
                        roomAttendanceMap,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class AttendanceDetailPage extends StatefulWidget {
  final String employeeName;
  final Map<String, Map<String, int>> roomAttendanceMap;

  AttendanceDetailPage(this.employeeName, this.roomAttendanceMap);

  @override
  _AttendanceDetailPageState createState() => _AttendanceDetailPageState();
}

class _AttendanceDetailPageState extends State<AttendanceDetailPage> {
  final Map<String, int> absenceCountMap = {};
  final Map<String, int> izinCountMap = {};
  final Map<String, int> hadirCountMap = {};
  DateTime? selectedDate;

  @override
  void initState() {
    super.initState();
    calculateAbsenceAndIzinCount();
  }

  @override
  void dispose() {
    // Batalkan timer atau hentikan pemantauan animasi di sini
    super.dispose();
  }

  void _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        calculateAbsenceAndIzinCount(); // Tambahkan pemanggilan fungsi ini setelah mengubah tanggal
      });
    }
  }

  void calculateAbsenceAndIzinCount() async {
    for (final roomName in widget.roomAttendanceMap.keys) {
      try {
        // Menghapus loop for dan mengganti dengan pemanggilan fungsi calculateAbsenceAndIzinCount() di luar loop
        final absenceCount =
            await getTotalAbsence(roomName, widget.employeeName, selectedDate);
        final izinCount =
            await getTotalIzin(roomName, widget.employeeName, selectedDate);
        final hadirCount =
            await getTotalHadir(roomName, widget.employeeName, selectedDate);

        // Periksa apakah objek State masih terpasang sebelum pemanggilan setState()
        if (mounted) {
          setState(() {
            absenceCountMap[roomName] = absenceCount;
            izinCountMap[roomName] = izinCount;
            hadirCountMap[roomName] = hadirCount;
          });
        }
      } catch (error) {
        print('Error calculating absence and izin count: $error');
      }
    }
  }

  Future<int> getTotalAbsence(
      String roomName, String employeeName, DateTime? selectedDate) async {
    int absenceCount = 0;

    try {
      Query query = FirebaseFirestore.instance
          .collection('absen')
          .where('roomName', isEqualTo: roomName)
          .where('employeeName', isEqualTo: employeeName)
          .where('status', isEqualTo: 'Absen');

      if (selectedDate != null) {
        final startOfDay =
            DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
        final endOfDay = startOfDay.add(Duration(days: 1));

        query = query.where('timestamp',
            isGreaterThanOrEqualTo: startOfDay, isLessThan: endOfDay);
      }

      final QuerySnapshot snapshot = await query.get();

      absenceCount = snapshot.docs.length;
    } catch (error) {
      print('Error getting absence data: $error');
    }

    return absenceCount;
  }

  Future<int> getTotalHadir(
      String roomName, String employeeName, DateTime? selectedDate) async {
    int hadirCount = 0;

    try {
      Query query = FirebaseFirestore.instance
          .collection('absen')
          .where('roomName', isEqualTo: roomName)
          .where('employeeName', isEqualTo: employeeName)
          .where('status', isEqualTo: 'Hadir');
      if (selectedDate != null) {
        final startOfDay =
            DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
        final endOfDay = startOfDay.add(Duration(days: 1));

        query = query.where('timestamp',
            isGreaterThanOrEqualTo: startOfDay, isLessThan: endOfDay);
      }

      final QuerySnapshot snapshot = await query.get();

      hadirCount = snapshot.docs.length;
    } catch (error) {
      print('Error getting absence data: $error');
    }

    return hadirCount;
  }

  Future<int> getTotalIzin(
      String roomName, String employeeName, DateTime? selectedDate) async {
    int izinCount = 0;

    try {
      Query query = FirebaseFirestore.instance
          .collection('absen')
          .where('roomName', isEqualTo: roomName)
          .where('employeeName', isEqualTo: employeeName)
          .where('status', isEqualTo: 'Izin');
      if (selectedDate != null) {
        final startOfDay =
            DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
        final endOfDay = startOfDay.add(Duration(days: 1));

        query = query.where('timestamp',
            isGreaterThanOrEqualTo: startOfDay, isLessThan: endOfDay);
      }

      final QuerySnapshot snapshot = await query.get();

      izinCount = snapshot.docs.length;
    } catch (error) {
      print('Error getting izin data: $error');
    }

    return izinCount;
  }

  @override
  Widget build(BuildContext context) {
    final List<String> roomNames = widget.roomAttendanceMap.keys.toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Presensi - ${widget.employeeName}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: _selectDate,
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: roomNames.length,
        itemBuilder: (BuildContext context, int index) {
          final roomName = roomNames[index];
          final attendanceCount =
              widget.roomAttendanceMap[roomName]![widget.employeeName] ?? 0;
          final absenceCount = absenceCountMap[roomName] ?? 0;
          final izinCount = izinCountMap[roomName] ?? 0;
          final hadirCount = hadirCountMap[roomName] ?? 0;

          return ListTile(
            title: Text(roomName),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Total Kehadiran: $hadirCount'),
                Text('Total Ketidakhadiran: $absenceCount'),
                Text('Total Izin: $izinCount'),
              ],
            ),
          );
        },
      ),
    );
  }
}
