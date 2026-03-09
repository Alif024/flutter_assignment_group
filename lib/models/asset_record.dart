import 'package:cloud_firestore/cloud_firestore.dart';

class AssetRecord {
  const AssetRecord({
    required this.assetCode,
    required this.name,
    required this.type,
    required this.brand,
    required this.description,
    required this.location,
    required this.status,
    required this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
    this.purchaseDate,
    this.assignedTo,
  });

  final String assetCode;
  final String name;
  final String type;
  final String brand;
  final String description;
  final String location;
  final String status;
  final String imageUrl;
  final DateTime? purchaseDate;
  final String? assignedTo;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory AssetRecord.fromMap(String id, Map<String, dynamic> map) {
    DateTime readDate(dynamic value) {
      if (value is Timestamp) {
        return value.toDate();
      }
      if (value is DateTime) {
        return value;
      }
      return DateTime.now();
    }

    DateTime? readNullableDate(dynamic value) {
      if (value is Timestamp) {
        return value.toDate();
      }
      if (value is DateTime) {
        return value;
      }
      return null;
    }

    return AssetRecord(
      assetCode: (map['assetCode'] as String?)?.trim().isNotEmpty == true
          ? (map['assetCode'] as String).trim()
          : id,
      name: (map['name'] as String?)?.trim() ?? '',
      type:
          (map['type'] as String?)?.trim() ??
          (map['typeId'] as String?)?.trim() ??
          '',
      brand: (map['brand'] as String?)?.trim() ?? '',
      description: (map['description'] as String?)?.trim() ?? '',
      location:
          (map['location'] as String?)?.trim() ??
          (map['locationId'] as String?)?.trim() ??
          '',
      status: (map['status'] as String?)?.trim() ?? 'normal',
      imageUrl: (map['imageUrl'] as String?)?.trim() ?? '',
      purchaseDate: readNullableDate(map['purchaseDate']),
      assignedTo: (map['assignedTo'] as String?)?.trim(),
      createdAt: readDate(map['createdAt']),
      updatedAt: readDate(map['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'assetCode': assetCode,
      'name': name,
      'type': type,
      'typeId': type,
      'brand': brand,
      'description': description,
      'location': location,
      'locationId': location,
      'status': status,
      'imageUrl': imageUrl,
      'assignedTo': assignedTo,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };

    if (purchaseDate != null) {
      map['purchaseDate'] = Timestamp.fromDate(purchaseDate!);
    }

    return map;
  }

  AssetRecord copyWith({
    String? assetCode,
    String? name,
    String? type,
    String? brand,
    String? description,
    String? location,
    String? status,
    String? imageUrl,
    DateTime? purchaseDate,
    String? assignedTo,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AssetRecord(
      assetCode: assetCode ?? this.assetCode,
      name: name ?? this.name,
      type: type ?? this.type,
      brand: brand ?? this.brand,
      description: description ?? this.description,
      location: location ?? this.location,
      status: status ?? this.status,
      imageUrl: imageUrl ?? this.imageUrl,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      assignedTo: assignedTo ?? this.assignedTo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
