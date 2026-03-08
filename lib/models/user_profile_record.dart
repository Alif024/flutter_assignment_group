import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfileRecord {
  const UserProfileRecord({
    required this.employeeId,
    required this.username,
    required this.password,
    required this.name,
    required this.email,
    required this.role,
    required this.phone,
    required this.office,
    required this.photoUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  final String employeeId;
  final String username;
  final String password;
  final String name;
  final String email;
  final String role;
  final String phone;
  final String office;
  final String photoUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory UserProfileRecord.fromMap(String id, Map<String, dynamic> map) {
    DateTime readDate(dynamic value) {
      if (value is Timestamp) {
        return value.toDate();
      }
      if (value is DateTime) {
        return value;
      }
      return DateTime.now();
    }

    return UserProfileRecord(
      employeeId: (map['employeeId'] as String?)?.trim().isNotEmpty == true
          ? (map['employeeId'] as String).trim()
          : id,
      username: (map['username'] as String?)?.trim() ?? '',
      password: (map['password'] as String?)?.trim() ?? '',
      name: (map['name'] as String?)?.trim() ?? 'Unknown User',
      email: (map['email'] as String?)?.trim() ?? '',
      role: (map['role'] as String?)?.trim() ?? 'Inventory Officer',
      phone: (map['phone'] as String?)?.trim() ?? '-',
      office: (map['office'] as String?)?.trim() ?? '-',
      photoUrl: (map['photoUrl'] as String?)?.trim() ?? '',
      createdAt: readDate(map['createdAt']),
      updatedAt: readDate(map['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'employeeId': employeeId,
      'username': username,
      'password': password,
      'name': name,
      'email': email,
      'role': role,
      'phone': phone,
      'office': office,
      'photoUrl': photoUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  UserProfileRecord copyWith({
    String? employeeId,
    String? username,
    String? password,
    String? name,
    String? email,
    String? role,
    String? phone,
    String? office,
    String? photoUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfileRecord(
      employeeId: employeeId ?? this.employeeId,
      username: username ?? this.username,
      password: password ?? this.password,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      phone: phone ?? this.phone,
      office: office ?? this.office,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
