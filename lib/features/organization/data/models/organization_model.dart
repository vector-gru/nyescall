import 'package:cloud_firestore/cloud_firestore.dart';

class DepartmentModel {
  const DepartmentModel({required this.name, required this.code});
  final String name;
  final String code;

  factory DepartmentModel.fromMap(Map<String, dynamic> m) =>
      DepartmentModel(name: m['name'] as String, code: m['code'] as String);
  Map<String, dynamic> toMap() => {'name': name, 'code': code};
}

class TeamMemberModel {
  const TeamMemberModel({
    required this.email,
    required this.role,
    this.uid,
    this.displayName,
  });
  final String email;
  final String role;
  final String? uid;
  final String? displayName;

  factory TeamMemberModel.fromMap(Map<String, dynamic> m) => TeamMemberModel(
        email: m['email'] as String,
        role: m['role'] as String? ?? 'agent',
        uid: m['uid'] as String?,
        displayName: m['displayName'] as String?,
      );
  Map<String, dynamic> toMap() => {
        'email': email,
        'role': role,
        if (uid != null) 'uid': uid,
        if (displayName != null) 'displayName': displayName,
      };
}

class OrganizationModel {
  const OrganizationModel({
    required this.id,
    required this.ownerId,
    required this.type,
    required this.name,
    required this.code,
    required this.phone,
    required this.email,
    this.address = '',
    this.workingHours = '',
    this.servicesOffered = '',
    this.logoUrl,
    this.departments = const [],
    this.teamMembers = const [],
  });

  final String id;
  final String ownerId;
  final String type;
  final String name;
  final String code;
  final String phone;
  final String email;
  final String address;
  final String workingHours;
  final String servicesOffered;
  final String? logoUrl;
  final List<DepartmentModel> departments;
  final List<TeamMemberModel> teamMembers;

  factory OrganizationModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return OrganizationModel(
      id: doc.id,
      ownerId: d['ownerId'] as String? ?? '',
      type: d['type'] as String? ?? 'Company / Business',
      name: d['name'] as String? ?? '',
      code: d['code'] as String? ?? '',
      phone: d['phone'] as String? ?? '',
      email: d['email'] as String? ?? '',
      address: d['address'] as String? ?? '',
      workingHours: d['workingHours'] as String? ?? '',
      servicesOffered: d['servicesOffered'] as String? ?? '',
      logoUrl: d['logoUrl'] as String?,
      departments: ((d['departments'] as List?)
              ?.map((e) => DepartmentModel.fromMap(e as Map<String, dynamic>))
              .toList()) ??
          [],
      teamMembers: ((d['teamMembers'] as List?)
              ?.map((e) => TeamMemberModel.fromMap(e as Map<String, dynamic>))
              .toList()) ??
          [],
    );
  }

  Map<String, dynamic> toFirestore() => {
        'ownerId': ownerId,
        'type': type,
        'name': name,
        'code': code,
        'phone': phone,
        'email': email,
        'address': address,
        'workingHours': workingHours,
        'servicesOffered': servicesOffered,
        if (logoUrl != null) 'logoUrl': logoUrl,
        'departments': departments.map((d) => d.toMap()).toList(),
        'teamMembers': teamMembers.map((m) => m.toMap()).toList(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

  OrganizationModel copyWith({
    String? type,
    String? name,
    String? code,
    String? phone,
    String? email,
    String? address,
    String? workingHours,
    String? servicesOffered,
    String? logoUrl,
    List<DepartmentModel>? departments,
    List<TeamMemberModel>? teamMembers,
  }) =>
      OrganizationModel(
        id: id,
        ownerId: ownerId,
        type: type ?? this.type,
        name: name ?? this.name,
        code: code ?? this.code,
        phone: phone ?? this.phone,
        email: email ?? this.email,
        address: address ?? this.address,
        workingHours: workingHours ?? this.workingHours,
        servicesOffered: servicesOffered ?? this.servicesOffered,
        logoUrl: logoUrl ?? this.logoUrl,
        departments: departments ?? this.departments,
        teamMembers: teamMembers ?? this.teamMembers,
      );
}
