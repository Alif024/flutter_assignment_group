import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreSeeder {
  const FirestoreSeeder._();

  static const int _seedVersion = 2;

  static Future<void> seedIfNeeded() async {
    final firestore = FirebaseFirestore.instance;
    final seedDocRef = firestore.collection('_meta').doc('seed_state');
    final seedDoc = await seedDocRef.get();
    final currentVersion = seedDoc.data()?['version'];

    if (currentVersion == _seedVersion) {
      return;
    }

    final batch = firestore.batch();
    final now = FieldValue.serverTimestamp();

    batch.set(seedDocRef, {
      'version': _seedVersion,
      'updatedAt': now,
      'note': 'Initial seed for AssetTrack app',
    });

    batch.set(firestore.collection('users').doc('EMP-1908'), {
      'employeeId': 'EMP-1908',
      'username': 'EMP-1908',
      'password': '123456',
      'name': 'Alif Wahayee',
      'email': 'alif.wahayee@assettrack.co',
      'role': 'inventory_officer',
      'phone': '+62 812-9991-0012',
      'office': 'Head Office - Floor 3',
      'photoUrl':
          'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=300',
      'createdAt': now,
      'updatedAt': now,
    }, SetOptions(merge: true));

    batch.set(firestore.collection('asset_types').doc('laptop'), {
      'name': 'Laptop',
      'isActive': true,
      'createdAt': now,
    }, SetOptions(merge: true));
    batch.set(firestore.collection('asset_types').doc('printer'), {
      'name': 'Printer',
      'isActive': true,
      'createdAt': now,
    }, SetOptions(merge: true));
    batch.set(firestore.collection('asset_types').doc('chair'), {
      'name': 'Office Chair',
      'isActive': true,
      'createdAt': now,
    }, SetOptions(merge: true));

    batch.set(firestore.collection('locations').doc('hq-f3-r305'), {
      'name': 'Floor 3, Room 305',
      'building': 'Head Office',
      'floor': 3,
      'roomCode': '305',
      'createdAt': now,
    }, SetOptions(merge: true));

    batch.set(firestore.collection('assets').doc('AST-2024-0156'), {
      'assetCode': 'AST-2024-0156',
      'name': 'Dell Latitude 5420',
      'type': 'laptop',
      'typeId': 'laptop',
      'brand': 'Dell',
      'description':
          '14-inch business laptop with Intel Core i5, 16GB RAM, 512GB SSD.',
      'location': 'Floor 3, Room 305',
      'locationId': 'hq-f3-r305',
      'status': 'normal',
      'purchaseDate': Timestamp.fromDate(DateTime(2024, 1, 15)),
      'imageUrl':
          'https://images.unsplash.com/photo-1593642634367-d91a135587b5?w=1200',
      'assignedTo': 'EMP-1908',
      'createdAt': now,
      'updatedAt': now,
    }, SetOptions(merge: true));

    batch.set(
      firestore.collection('asset_logs').doc('LOG-2026-0001'),
      {
        'assetId': 'AST-2024-0156',
        'action': 'status_update',
        'fromStatus': 'under_repair',
        'toStatus': 'normal',
        'note': 'Returned from service and tested.',
        'actorEmployeeId': 'EMP-1908',
        'createdAt': now,
      },
      SetOptions(merge: true),
    );

    batch.set(
      firestore.collection('maintenance_tickets').doc('TKT-2026-0001'),
      {
        'assetId': 'AST-2024-0156',
        'issue': 'Battery health below expected range',
        'priority': 'medium',
        'status': 'closed',
        'openedBy': 'EMP-1908',
        'assignedTo': 'EMP-1908',
        'openedAt': Timestamp.fromDate(DateTime(2026, 2, 10)),
        'closedAt': Timestamp.fromDate(DateTime(2026, 2, 12)),
        'createdAt': now,
        'updatedAt': now,
      },
      SetOptions(merge: true),
    );

    await batch.commit();
  }
}
