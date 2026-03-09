import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_assignment_group/models/asset_activity_record.dart';
import 'package:flutter_assignment_group/models/asset_record.dart';
import 'package:flutter_assignment_group/models/user_profile_record.dart';

class FirestoreRepository {
  FirestoreRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _assetsRef =>
      _firestore.collection('assets');

  CollectionReference<Map<String, dynamic>> get _assetLogsRef =>
      _firestore.collection('asset_logs');

  CollectionReference<Map<String, dynamic>> get _usersRef =>
      _firestore.collection('users');

  Stream<List<AssetRecord>> watchAssets() {
    return _assetsRef.snapshots().map((snapshot) {
      final items = snapshot.docs
          .map((doc) => AssetRecord.fromMap(doc.id, doc.data()))
          .toList();
      items.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      return items;
    });
  }

  Stream<AssetRecord?> watchAsset(String assetCode) {
    return _assetsRef.doc(assetCode).snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) {
        return null;
      }
      return AssetRecord.fromMap(doc.id, doc.data()!);
    });
  }

  Future<AssetRecord?> getAsset(String assetCode) async {
    final doc = await _assetsRef.doc(assetCode).get();
    if (!doc.exists || doc.data() == null) {
      return null;
    }
    return AssetRecord.fromMap(doc.id, doc.data()!);
  }

  Future<void> addAsset(
    AssetRecord asset, {
    String actorEmployeeId = 'EMP-1908',
  }) async {
    final existing = await _assetsRef.doc(asset.assetCode).get();
    if (existing.exists) {
      throw StateError('Asset ID already exists.');
    }

    final now = DateTime.now();
    final assetToSave = asset.copyWith(createdAt: now, updatedAt: now);
    await _assetsRef.doc(asset.assetCode).set(assetToSave.toMap());

    await _addActivity(
      assetId: asset.assetCode,
      action: 'added',
      toStatus: asset.status,
      note: 'Asset created',
      actorEmployeeId: actorEmployeeId,
    );
  }

  Future<void> updateAsset(
    AssetRecord asset, {
    String actorEmployeeId = 'EMP-1908',
  }) async {
    final current = await getAsset(asset.assetCode);
    final now = DateTime.now();
    final next = asset.copyWith(
      createdAt: current?.createdAt ?? now,
      updatedAt: now,
    );

    await _assetsRef
        .doc(asset.assetCode)
        .set(next.toMap(), SetOptions(merge: true));

    await _addActivity(
      assetId: asset.assetCode,
      action: 'details_updated',
      fromStatus: current?.status,
      toStatus: next.status,
      note: 'Asset details updated',
      actorEmployeeId: actorEmployeeId,
    );
  }

  Future<void> updateAssetStatus({
    required String assetCode,
    required String status,
    String note = '',
    String actorEmployeeId = 'EMP-1908',
  }) async {
    final current = await getAsset(assetCode);
    if (current == null) {
      throw StateError('Asset not found.');
    }

    await _assetsRef.doc(assetCode).update({
      'status': status,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });

    await _addActivity(
      assetId: assetCode,
      action: 'status_updated',
      fromStatus: current.status,
      toStatus: status,
      note: note.trim().isEmpty ? 'Status updated' : note.trim(),
      actorEmployeeId: actorEmployeeId,
    );
  }

  Future<void> deleteAsset(
    String assetCode, {
    String actorEmployeeId = 'EMP-1908',
  }) async {
    final current = await getAsset(assetCode);
    if (current == null) {
      return;
    }

    await _assetsRef.doc(assetCode).delete();
    await _addActivity(
      assetId: assetCode,
      action: 'deleted',
      fromStatus: current.status,
      toStatus: 'deleted',
      note: 'Asset deleted',
      actorEmployeeId: actorEmployeeId,
    );
  }

  Stream<List<AssetActivityRecord>> watchRecentActivities({int limit = 10}) {
    return _assetLogsRef.snapshots().map((snapshot) {
      final items = snapshot.docs
          .map((doc) => AssetActivityRecord.fromMap(doc.id, doc.data()))
          .toList();
      items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      if (items.length > limit) {
        return items.sublist(0, limit);
      }
      return items;
    });
  }

  Stream<List<AssetActivityRecord>> watchActivities({int limit = 100}) {
    return _assetLogsRef.snapshots().map((snapshot) {
      final items = snapshot.docs
          .map((doc) => AssetActivityRecord.fromMap(doc.id, doc.data()))
          .toList();
      items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      if (items.length > limit) {
        return items.sublist(0, limit);
      }
      return items;
    });
  }

  Stream<UserProfileRecord?> watchUserProfile(String employeeId) {
    final normalizedEmployeeId = employeeId.trim();
    if (normalizedEmployeeId.isEmpty) {
      return Stream.value(null);
    }

    late final StreamController<UserProfileRecord?> controller;
    StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? docSubscription;
    StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? querySubscription;

    UserProfileRecord? recordFromDocId;
    UserProfileRecord? recordFromEmployeeField;

    void emitLatestRecord() {
      controller.add(recordFromDocId ?? recordFromEmployeeField);
    }

    controller = StreamController<UserProfileRecord?>(
      onListen: () {
        docSubscription = _usersRef
            .doc(normalizedEmployeeId)
            .snapshots()
            .listen((doc) {
              if (doc.exists && doc.data() != null) {
                recordFromDocId = UserProfileRecord.fromMap(
                  doc.id,
                  doc.data()!,
                );
              } else {
                recordFromDocId = null;
              }
              emitLatestRecord();
            }, onError: controller.addError);

        querySubscription = _usersRef
            .where('employeeId', isEqualTo: normalizedEmployeeId)
            .limit(1)
            .snapshots()
            .listen((snapshot) {
              if (snapshot.docs.isNotEmpty) {
                final userDoc = snapshot.docs.first;
                recordFromEmployeeField = UserProfileRecord.fromMap(
                  userDoc.id,
                  userDoc.data(),
                );
              } else {
                recordFromEmployeeField = null;
              }
              emitLatestRecord();
            }, onError: controller.addError);
      },
      onCancel: () async {
        await docSubscription?.cancel();
        await querySubscription?.cancel();
      },
    );

    return controller.stream;
  }

  Future<UserProfileRecord> authenticateUser({
    required String username,
    required String password,
  }) async {
    final usernameText = username.trim();
    final passwordText = password.trim();

    if (usernameText.isEmpty) {
      throw StateError('Username is required.');
    }
    if (passwordText.isEmpty) {
      throw StateError('Password is required.');
    }

    final byUsername = await _usersRef
        .where('username', isEqualTo: usernameText)
        .limit(1)
        .get();

    String? userDocId;
    Map<String, dynamic>? userData;
    if (byUsername.docs.isNotEmpty) {
      userDocId = byUsername.docs.first.id;
      userData = byUsername.docs.first.data();
    } else {
      final byEmployeeId = await _usersRef.doc(usernameText).get();
      if (byEmployeeId.exists && byEmployeeId.data() != null) {
        userDocId = byEmployeeId.id;
        userData = byEmployeeId.data()!;
      }
    }

    if (_userDocDataMissing(userDocId, userData)) {
      final byEmployeeField = await _findUserByEmployeeId(usernameText);
      if (byEmployeeField != null) {
        userDocId = byEmployeeField.id;
        userData = byEmployeeField.data();
      }
    }

    if (_userDocDataMissing(userDocId, userData)) {
      throw StateError('Invalid username or password.');
    }

    var user = UserProfileRecord.fromMap(userDocId!, userData!);
    var expectedPassword = user.password.trim();
    final needsCanonicalDoc = userDocId != user.employeeId;
    var credentialsBackfilled = false;
    var usernameBackfilled = false;

    if (expectedPassword.isEmpty) {
      expectedPassword = '123456';
      user = user.copyWith(password: expectedPassword);
      credentialsBackfilled = true;
    }

    if (passwordText != expectedPassword) {
      throw StateError('Invalid username or password.');
    }

    if (user.username.isEmpty) {
      user = user.copyWith(username: user.employeeId);
      usernameBackfilled = true;
    }

    if (needsCanonicalDoc || credentialsBackfilled || usernameBackfilled) {
      await upsertUserProfile(user);
    }

    return user;
  }

  Future<void> upsertUserProfile(UserProfileRecord user) async {
    final now = DateTime.now();
    final doc = await _usersRef.doc(user.employeeId).get();
    final createdAt = doc.data()?['createdAt'] is Timestamp
        ? (doc.data()?['createdAt'] as Timestamp).toDate()
        : user.createdAt;

    final record = user.copyWith(createdAt: createdAt, updatedAt: now);

    await _usersRef
        .doc(user.employeeId)
        .set(record.toMap(), SetOptions(merge: true));
  }

  Future<void> ensureUserProfileExists(String employeeId) async {
    final doc = await _usersRef.doc(employeeId).get();
    if (doc.exists) {
      return;
    }

    final now = DateTime.now();
    final user = UserProfileRecord(
      employeeId: employeeId,
      username: employeeId,
      password: '123456',
      name: 'Employee $employeeId',
      email: '$employeeId@assettrack.local',
      role: 'Inventory Officer',
      phone: '-',
      office: '-',
      photoUrl: '',
      createdAt: now,
      updatedAt: now,
    );
    await upsertUserProfile(user);
  }

  Future<QueryDocumentSnapshot<Map<String, dynamic>>?> _findUserByEmployeeId(
    String employeeId,
  ) async {
    final byEmployeeField = await _usersRef
        .where('employeeId', isEqualTo: employeeId)
        .limit(1)
        .get();
    if (byEmployeeField.docs.isNotEmpty) {
      return byEmployeeField.docs.first;
    }
    return null;
  }

  bool _userDocDataMissing(String? userDocId, Map<String, dynamic>? userData) {
    return userDocId == null || userData == null;
  }

  Future<void> _addActivity({
    required String assetId,
    required String action,
    required String toStatus,
    String? fromStatus,
    String? note,
    String? actorEmployeeId,
  }) async {
    await _assetLogsRef.add({
      'assetId': assetId,
      'action': action,
      'fromStatus': fromStatus,
      'toStatus': toStatus,
      'note': note,
      'actorEmployeeId': actorEmployeeId,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
