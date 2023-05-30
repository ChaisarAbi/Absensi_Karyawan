import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

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

          final List<DocumentSnapshot> documents = snapshot.data?.docs ?? [];
          final Map<String, Map<String, int>> roomAttendanceMap = {};

          for (final document in documents) {
            final attendanceData = document.data() as Map<String, dynamic>;
            final roomName = attendanceData['roomName'] ?? 'Unknown';
            final employeeName = attendanceData['employeeName'] ?? 'Unknown';
            final isPresent = attendanceData['isPresent'] ?? false;

            if (!roomAttendanceMap.containsKey(roomName)) {
              roomAttendanceMap[roomName] = {};
            }

            if (!roomAttendanceMap[roomName]!.containsKey(employeeName)) {
              roomAttendanceMap[roomName]![employeeName] = 0;
            }

            if (isPresent) {
              roomAttendanceMap[roomName]![employeeName] =
                  (roomAttendanceMap[roomName]![employeeName] ?? 0) + 1;
            }
          }

          return ListView.builder(
            itemCount: roomAttendanceMap.length,
            itemBuilder: (BuildContext context, int index) {
              final roomName = roomAttendanceMap.keys.elementAt(index);
              final attendanceDataMap = roomAttendanceMap[roomName]!;

              return ListTile(
                title: Text('$roomName'),
                onTap: () {
                  // Navigate to AttendanceDetailPage and pass attendance data map
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          AttendanceDetailPage(roomName, attendanceDataMap),
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
  final String roomName;
  final Map<String, int> attendanceDataMap;

  AttendanceDetailPage(this.roomName, this.attendanceDataMap);

  @override
  _AttendanceDetailPageState createState() => _AttendanceDetailPageState();
}

class _AttendanceDetailPageState extends State<AttendanceDetailPage> {
  final Map<String, int> absenceCountMap = {};

  @override
  void initState() {
    super.initState();
    calculateAbsenceCount();
  }

  void calculateAbsenceCount() async {
    for (final employeeName in widget.attendanceDataMap.keys) {
      final absenceCount =
          await getTotalAbsence(widget.roomName, employeeName);
      setState(() {
        absenceCountMap[employeeName] = absenceCount;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    List<String> employeeNames = widget.attendanceDataMap.keys.toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Attendance Detail - ${widget.roomName}'),
      ),
      body: ListView.builder(
        itemCount: employeeNames.length,
        itemBuilder: (BuildContext context, int index) {
          final employeeName = employeeNames[index];
          final attendanceCount = widget.attendanceDataMap[employeeName] ?? 0;
          final absenceCount = absenceCountMap[employeeName] ?? 0;

          return ListTile(
            title: Text(employeeName),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Total Kehadiran: $attendanceCount'),
                Text('Total Ketidakhadiran: $absenceCount'),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<int> getTotalAbsence(String roomName, String employeeName) async {
    int absenceCount = 0;

    try {
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('absen')
          .where('roomName', isEqualTo: roomName)
          .where('employeeName', isEqualTo: employeeName)
          .where('isPresent', isEqualTo: false)
          .get();

      absenceCount = snapshot.docs.length;
    } catch (error) {
      print('Error getting absence data: $error');
    }

    return absenceCount;
  }
}
