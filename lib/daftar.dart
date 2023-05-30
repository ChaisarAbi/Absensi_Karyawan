import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/list.dart';

class EmployeeAttendancePage extends StatefulWidget {
  @override
  _EmployeeAttendancePageState createState() => _EmployeeAttendancePageState();
}

class _EmployeeAttendancePageState extends State<EmployeeAttendancePage> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final CollectionReference attendanceCollection =
      FirebaseFirestore.instance.collection('absen');

  final List<String> employeeNames = [
    'John Doe',
    'Jane Smith',
    'Michael Johnson',
    'Emily Davis',
  ];

  final List<String> roomNames = [
    'Meeting Room A',
    'Meeting Room B',
    'Conference Room',
    'Training Room',
  ];

  Map<int, bool> attendanceStatus =
      {}; // Map to store attendance status for each employee
  bool isRoomListVisible = false;
  int selectedRoomIndex = 0; // Selected room index
  String selectedRoomName = 'Select Room'; // Selected room name

  void saveAttendance(int index, bool isPresent) {
    setState(() {
      attendanceStatus[index] = isPresent;
    });
  }

  void submitAttendance() {
    if (selectedRoomIndex == 0) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: const Text(
                'Please select a room before saving the attendance.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    } else {
      saveAttendanceData();
    }
  }

  void showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Success'),
          content: const Text('Data absensi berhasil disimpan.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void saveAttendanceData() {
    final selectedRoom = roomNames[selectedRoomIndex];

    for (int index = 0; index < employeeNames.length; index++) {
      final attendanceData = {
        'employeeName': employeeNames[index],
        'roomName': selectedRoom,
        'timestamp': DateTime.now(),
        'isPresent': attendanceStatus[index] ?? false,
      };

      attendanceCollection.add(attendanceData).then((value) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data absensi berhasil disimpan.'),
            duration: Duration(seconds: 2), // Durasi pesan pop-up
          ),
        );
      }).catchError((error) {
        print('Gagal menyimpan data absensi: $error');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('Terjadi kesalahan saat menyimpan data absensi.'),
            duration: Duration(seconds: 2), // Durasi pesan pop-up
          ),
        );
      });
    }

    setState(() {
      attendanceStatus.clear();
      selectedRoomIndex = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text('Employee Attendance')),
        actions: [
          IconButton(
            icon: const Icon(Icons.list),
            onPressed: () {
              // Navigate to the AttendanceListPage
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AttendanceListPage()),
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: employeeNames.length,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            title: Text(employeeNames[index]),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  onPressed: () {
                    saveAttendance(index, true);
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.resolveWith<Color>(
                      (Set<MaterialState> states) {
                        if (attendanceStatus.containsKey(index) &&
                            attendanceStatus[index]!) {
                          return Colors.green;
                        }
                        return Colors.transparent;
                      },
                    ),
                  ),
                  child: const Text('Hadir'),
                ),
                ElevatedButton(
                  onPressed: () {
                    saveAttendance(index, false);
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.resolveWith<Color>(
                      (Set<MaterialState> states) {
                        if (attendanceStatus.containsKey(index) &&
                            !attendanceStatus[index]!) {
                          return Colors.red;
                        }
                        return Colors.transparent;
                      },
                    ),
                  ),
                  child: const Text('Absen'),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: attendanceStatus.isNotEmpty ? submitAttendance : null,
        label: Text('Simpan (${attendanceStatus.length})'),
        icon: const Icon(Icons.save),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      bottomSheet: isRoomListVisible
          ? Container(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: roomNames.length,
                itemBuilder: (BuildContext context, int index) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          isRoomListVisible = false;
                          selectedRoomIndex =
                              index; // Update the selected room index
                          selectedRoomName =
                              roomNames[index]; // Update the selected room name
                        });
                      },
                      child: Text(roomNames[index]),
                    ),
                  );
                },
              ),
            )
          : const SizedBox.shrink(),
      persistentFooterButtons: [
        ElevatedButton(
          onPressed: () {
            setState(() {
              isRoomListVisible = !isRoomListVisible;
            });
          },
          child: Text(
              selectedRoomName), // Update the text to display selected room name
        ),
      ],
    );
  }
}
