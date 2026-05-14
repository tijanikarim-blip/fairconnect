import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../core/constants/constants.dart';
import '../models/exhibition.dart';
import '../models/app_user.dart';
import '../models/organizer_claim.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final Uuid _uuid = const Uuid();

  Stream<List<Exhibition>> getExhibitions() {
    return _db
        .collection(AppConstants.collectionExhibitions)
        .orderBy('startDate', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Exhibition.fromFirestore(doc.data(), doc.id))
            .toList());
  }

  Stream<List<Exhibition>> getFeaturedExhibitions() {
    return _db
        .collection(AppConstants.collectionExhibitions)
        .where('isFeatured', isEqualTo: true)
        .orderBy('startDate', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Exhibition.fromFirestore(doc.data(), doc.id))
            .toList());
  }

  Stream<Exhibition?> getExhibitionBySlug(String slug) {
    return _db
        .collection(AppConstants.collectionExhibitions)
        .where('slug', isEqualTo: slug)
        .limit(1)
        .snapshots()
        .map((snapshot) => snapshot.docs.isNotEmpty
            ? Exhibition.fromFirestore(snapshot.docs.first.data(), snapshot.docs.first.id)
            : null);
  }

  Stream<List<Exhibition>> searchExhibitions({
    String? industry,
    String? country,
    DateTime? fromDate,
    DateTime? toDate,
    String? queryText,
  }) {
    Query query =
        _db.collection(AppConstants.collectionExhibitions);

    if (industry != null && industry.isNotEmpty) {
      query = query.where('industries', arrayContains: industry);
    }
    if (country != null && country.isNotEmpty) {
      query = query.where('country', isEqualTo: country);
    }
    if (fromDate != null) {
      query = query.where('startDate', isGreaterThanOrEqualTo: fromDate);
    }
    if (toDate != null) {
      query = query.where('startDate', isLessThanOrEqualTo: toDate);
    }

    return query
        .orderBy('startDate', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Exhibition.fromFirestore(doc.data() as Map<String, dynamic>, doc.id))
            .toList());
  }

  Stream<Exhibition?> getExhibition(String id) {
    return _db
        .collection(AppConstants.collectionExhibitions)
        .doc(id)
        .snapshots()
        .map((doc) =>
            doc.exists ? Exhibition.fromFirestore(doc.data()!, doc.id) : null);
  }

  Future<void> addExhibition(Exhibition exhibition) {
    return _db
        .collection(AppConstants.collectionExhibitions)
        .doc(exhibition.id)
        .set(exhibition.toFirestore());
  }

  Future<void> updateExhibition(Exhibition exhibition) {
    return _db
        .collection(AppConstants.collectionExhibitions)
        .doc(exhibition.id)
        .update(exhibition.toFirestore());
  }

  Future<void> deleteExhibition(String id) {
    return _db
        .collection(AppConstants.collectionExhibitions)
        .doc(id)
        .delete();
  }

  Stream<AppUser?> getUser(String userId) {
    return _db
        .collection(AppConstants.collectionUsers)
        .doc(userId)
        .snapshots()
        .map((doc) =>
            doc.exists ? AppUser.fromFirestore(doc.data()!, doc.id) : null);
  }

  Future<void> createUser(AppUser user) {
    return _db
        .collection(AppConstants.collectionUsers)
        .doc(user.id)
        .set(user.toFirestore());
  }

  Future<void> updateUser(AppUser user) {
    return _db
        .collection(AppConstants.collectionUsers)
        .doc(user.id)
        .update(user.toFirestore());
  }

  Future<void> addFavorite(String userId, String exhibitionId) {
    return _db
        .collection(AppConstants.collectionUsers)
        .doc(userId)
        .update({
      'favoriteExhibitionIds': FieldValue.arrayUnion([exhibitionId]),
    });
  }

  Future<void> removeFavorite(String userId, String exhibitionId) {
    return _db
        .collection(AppConstants.collectionUsers)
        .doc(userId)
        .update({
      'favoriteExhibitionIds': FieldValue.arrayRemove([exhibitionId]),
    });
  }

  Future<void> setReminder(String userId, String exhibitionId,
      DateTime remindAt) {
    final reminderId = _uuid.v4();
    return _db
        .collection(AppConstants.collectionReminders)
        .doc(reminderId)
        .set({
      'id': reminderId,
      'userId': userId,
      'exhibitionId': exhibitionId,
      'remindAt': remindAt,
      'isSent': false,
      'createdAt': DateTime.now(),
    });
  }

  Future<void> removeReminder(String userId, String exhibitionId) async {
    final snapshot = await _db
        .collection(AppConstants.collectionReminders)
        .where('userId', isEqualTo: userId)
        .where('exhibitionId', isEqualTo: exhibitionId)
        .get();
    for (final doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }

  Stream<bool> hasReminder(String userId, String exhibitionId) {
    return _db
        .collection(AppConstants.collectionReminders)
        .where('userId', isEqualTo: userId)
        .where('exhibitionId', isEqualTo: exhibitionId)
        .snapshots()
        .map((snapshot) => snapshot.docs.isNotEmpty);
  }

  Future<void> addOrganizerClaim(OrganizerClaim claim) {
    return _db
        .collection(AppConstants.collectionOrganizerClaims)
        .doc(claim.id)
        .set(claim.toFirestore());
  }

  Stream<List<OrganizerClaim>> getOrganizerClaims({String? userId}) {
    Query query = _db.collection(AppConstants.collectionOrganizerClaims);
    if (userId != null) {
      query = query.where('userId', isEqualTo: userId);
    }
    return query
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => OrganizerClaim.fromFirestore(doc.data() as Map<String, dynamic>, doc.id))
            .toList());
  }

  Future<void> updateOrganizerClaimStatus(String claimId, String status) {
    return _db
        .collection(AppConstants.collectionOrganizerClaims)
        .doc(claimId)
        .update({'status': status, 'approvedAt': status == 'approved' ? DateTime.now() : null});
  }
}
