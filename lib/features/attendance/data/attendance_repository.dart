import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/attendance.dart';

abstract class AttendanceRepository {
  Stream<List<Attendance>> watch();

  Stream<List<Attendance>> watchByMonth(DateTime month);

  Future<void> submit(Uint8List photo);

  Future<Uint8List> photo(String id);
}

class FirestoreAttendanceRepository implements AttendanceRepository {
  FirestoreAttendanceRepository(this.db, this.uid);

  final FirebaseFirestore db;
  final String uid;

  CollectionReference<Map<String, dynamic>> get records =>
      db.collection('students').doc(uid).collection('attendance');

  @override
  Stream<List<Attendance>> watch() => records
      .orderBy('createdAt', descending: true)
      .limit(60)
      .snapshots()
      .map((snapshot) => snapshot.docs.map(Attendance.fromDoc).toList());

  @override
  Stream<List<Attendance>> watchByMonth(DateTime month) {
    final startOfMonth = DateTime.utc(
      month.year,
      month.month,
      1,
    ).subtract(const Duration(hours: 7));

    final startOfNextMonth = DateTime.utc(
      month.year,
      month.month + 1,
      1,
    ).subtract(const Duration(hours: 7));

    return records
        .where(
          'createdAt',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth),
        )
        .where('createdAt', isLessThan: Timestamp.fromDate(startOfNextMonth))
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(Attendance.fromDoc).toList());
  }

  @override
  Future<void> submit(Uint8List photo) async {
    if (photo.isEmpty || photo.length > 102400) {
      throw StateError(
        'Foto harus berukuran maksimal 100 KB. Ambil ulang foto.',
      );
    }

    final batch = db.batch();
    final record = records.doc();

    batch.set(record, {'createdAt': FieldValue.serverTimestamp()});

    batch.set(record.collection('evidence').doc('photo'), {
      'bytes': Blob(photo),
    });

    final guard = db
        .collection('students')
        .doc(uid)
        .collection('guards')
        .doc('daily');

    batch.set(guard, {
      'lastAt': FieldValue.serverTimestamp(),
      'recordId': record.id,
    });

    await batch.commit();
  }

  @override
  Future<Uint8List> photo(String id) async {
    final doc = await records.doc(id).collection('evidence').doc('photo').get();

    return (doc.data()!['bytes'] as Blob).bytes;
  }
}
