import 'package:cloud_firestore/cloud_firestore.dart';

class StaffModel {
  const StaffModel({
    required this.id,
    required this.orgId,
    required this.fullName,
    required this.department,
    required this.position,
    required this.phone,
    required this.email,
    required this.employeeNo,
    required this.branch,
    required this.staffCode,
    required this.createdAt,
    this.dateOfBirth,
    this.dateEmployed,
    this.cardValidUntil,
    this.photoUrl,
  });

  final String id;
  final String orgId;
  final String fullName;
  final String department;
  final String position;
  final String phone;
  final String email;
  final String employeeNo;
  final String branch;
  final String staffCode; // auto-generated e.g. NC-SLS-0007
  final DateTime createdAt;
  final DateTime? dateOfBirth;
  final DateTime? dateEmployed;
  final DateTime? cardValidUntil;
  final String? photoUrl;

  factory StaffModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return StaffModel(
      id: doc.id,
      orgId: d['orgId'] as String? ?? '',
      fullName: d['fullName'] as String? ?? '',
      department: d['department'] as String? ?? 'General',
      position: d['position'] as String? ?? '',
      phone: d['phone'] as String? ?? '',
      email: d['email'] as String? ?? '',
      employeeNo: d['employeeNo'] as String? ?? '',
      branch: d['branch'] as String? ?? '',
      staffCode: d['staffCode'] as String? ?? '',
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      dateOfBirth: (d['dateOfBirth'] as Timestamp?)?.toDate(),
      dateEmployed: (d['dateEmployed'] as Timestamp?)?.toDate(),
      cardValidUntil: (d['cardValidUntil'] as Timestamp?)?.toDate(),
      photoUrl: d['photoUrl'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'orgId': orgId,
        'fullName': fullName,
        'department': department,
        'position': position,
        'phone': phone,
        'email': email,
        'employeeNo': employeeNo,
        'branch': branch,
        'staffCode': staffCode,
        'createdAt': Timestamp.fromDate(createdAt),
        if (dateOfBirth != null)
          'dateOfBirth': Timestamp.fromDate(dateOfBirth!),
        if (dateEmployed != null)
          'dateEmployed': Timestamp.fromDate(dateEmployed!),
        if (cardValidUntil != null)
          'cardValidUntil': Timestamp.fromDate(cardValidUntil!),
        if (photoUrl != null) 'photoUrl': photoUrl,
      };
}
