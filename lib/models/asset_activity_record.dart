import 'package:cloud_firestore/cloud_firestore.dart';

class AssetActivityRecord {
  const AssetActivityRecord({
    required this.id,
    required this.assetId,
    required this.action,
    required this.toStatus,
    required this.createdAt,
    this.fromStatus,
    this.note,
    this.actorEmployeeId,
  });

  final String id;
  final String assetId;
  final String action;
  final String? fromStatus;
  final String toStatus;
  final String? note;
  final String? actorEmployeeId;
  final DateTime createdAt;

  factory AssetActivityRecord.fromMap(String id, Map<String, dynamic> map) {
    DateTime createdAt = DateTime.now();
    final dynamic timestamp = map['createdAt'];
    if (timestamp is Timestamp) {
      createdAt = timestamp.toDate();
    } else if (timestamp is DateTime) {
      createdAt = timestamp;
    }

    return AssetActivityRecord(
      id: id,
      assetId: (map['assetId'] as String?)?.trim() ?? '',
      action: (map['action'] as String?)?.trim() ?? 'updated',
      fromStatus: (map['fromStatus'] as String?)?.trim(),
      toStatus:
          (map['toStatus'] as String?)?.trim() ??
          (map['status'] as String?)?.trim() ??
          'normal',
      note: (map['note'] as String?)?.trim(),
      actorEmployeeId: (map['actorEmployeeId'] as String?)?.trim(),
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'assetId': assetId,
      'action': action,
      'fromStatus': fromStatus,
      'toStatus': toStatus,
      'note': note,
      'actorEmployeeId': actorEmployeeId,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
