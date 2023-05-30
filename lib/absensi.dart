import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/informasi.dart';
import 'package:flutter_application_1/list.dart';
import 'package:flutter_application_1/login.dart';

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

  Map<int, String> attendanceStatus =
      {}; // Map to store attendance status for each employee
  bool isRoomListVisible = false;
  int selectedRoomIndex = 0; // Selected room index
  String selectedRoomName = 'Select Room'; // Selected room name

  void saveAttendance(int index, String status) {
    setState(() {
      attendanceStatus[index] = status;
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
      final selectedRoom = roomNames[selectedRoomIndex - 1];
      List<Future<DocumentReference>> futures = [];

      for (int index = 0; index < employeeNames.length; index++) {
        final attendanceData = {
          'employeeName': employeeNames[index],
          'roomName': selectedRoom,
          'timestamp': DateTime.now(),
          'status': attendanceStatus[index] ?? 'Absen',
        };

        futures.add(attendanceCollection.add(attendanceData));
      }

      Future.wait(futures).then((_) {
        print('Attendance data has been saved.');
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Success'),
              content: const Text('Attendance data has been saved.'),
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
      }).catchError((error) {
        print('Failed to save attendance data: $error');
      }).whenComplete(() {
        setState(() {
          selectedRoomIndex = 0;
          selectedRoomName = 'Select Room';
          attendanceStatus.clear();
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Employee Attendance'),
        centerTitle: true,
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
      drawer: Drawer(
        child: Container(
          color: Colors.grey[200],
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              Container(
                height: 150,
                child: DrawerHeader(
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
                leading: Icon(Icons.info),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => InformasiPage(
                                adminEmail: '',
                              )));
                },
              ),
              ListTile(
                title: const Text('Absensi'),
                leading: Icon(Icons.calendar_today),
                onTap: () {
// Close the drawer and stay on the same page
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Logout'),
                leading: Icon(Icons.logout),
                onTap: () {
// Navigate back to the Login page
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LoginPage(),
                    ),
                    (route) => false,
                  );
                },
              ),
            ],
          ),
        ),
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
                    saveAttendance(index, 'Hadir');
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.resolveWith<Color>(
                      (Set<MaterialState> states) {
                        if (attendanceStatus.containsKey(index) &&
                            attendanceStatus[index] == 'Hadir') {
                          return Colors.green;
                        }
                        return Colors.transparent;
                      },
                    ),
                  ),
                  child: const Text(
                    'Hadir',
                    style: TextStyle(fontSize: 14),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    saveAttendance(index, 'Absen');
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.resolveWith<Color>(
                      (Set<MaterialState> states) {
                        if (attendanceStatus.containsKey(index) &&
                            attendanceStatus[index] == 'Absen') {
                          return Colors.red;
                        }
                        return Colors.transparent;
                      },
                    ),
                  ),
                  child: const Text(
                    'Absen',
                    style: TextStyle(fontSize: 14),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    saveAttendance(index, 'Izin');
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.resolveWith<Color>(
                      (Set<MaterialState> states) {
                        if (attendanceStatus.containsKey(index) &&
                            attendanceStatus[index] == 'Izin') {
                          return Colors.yellow;
                        }
                        return Colors.transparent;
                      },
                    ),
                  ),
                  child: const Text(
                    'Izin',
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: Container(
        margin: EdgeInsets.only(bottom: 20, right: 20),
        child: FloatingActionButton.extended(
          onPressed: attendanceStatus.isNotEmpty ? submitAttendance : null,
          label: Text('Simpan (${attendanceStatus.length})'),
          icon: const Icon(Icons.save),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
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
                              index + 1; // Increment the index by 1
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
            selectedRoomName,
            style: TextStyle(fontSize: 16),
          ), // Update the text to display selected room name
        ),
      ],
    );
  }
}
