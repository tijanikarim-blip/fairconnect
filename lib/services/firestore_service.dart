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

  Future<List<Map<String, dynamic>>> getDueReminders() async {
    final snapshot = await _db
        .collection(AppConstants.collectionReminders)
        .where('isSent', isEqualTo: false)
        .where('remindAt', isLessThanOrEqualTo: DateTime.now())
        .get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  Future<void> markReminderSent(String reminderId) async {
    await _db
        .collection(AppConstants.collectionReminders)
        .doc(reminderId)
        .update({'isSent': true});
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

  Future<void> seedSampleData() async {
    final now = DateTime.now();
    final samples = [
      Exhibition(
        id: _uuid.v4(),
        name: 'CES 2027 - Consumer Electronics Show',
        nameAr: 'معرض الإلكترونيات الاستهلاكية 2027',
        nameFr: 'CES 2027 - Salon de l\'Électronique Grand Public',
        description: 'The world\'s most influential technology event showcasing the latest in consumer electronics, AI, robotics, and smart home innovations.',
        descriptionAr: 'أكثر الفعاليات التكنولوجية تأثيراً في العالم تعرض أحدث الإلكترونيات الاستهلاكية والذكاء الاصطناعي والروبوتات',
        descriptionFr: 'L\'événement technologique le plus influent au monde présentant les dernières innovations en électronique grand public, IA, robotique.',
        industries: ['Technology', 'Electronics', 'AI'],
        country: 'United States',
        city: 'Las Vegas',
        startDate: now.add(const Duration(days: 45)),
        endDate: now.add(const Duration(days: 48)),
        venue: 'Las Vegas Convention Center',
        images: [],
        youtubeVideoId: 'dZX6Q6FgLqg',
        registrationUrl: 'https://www.ces.tech',
        website: 'https://www.ces.tech',
        organizer: 'Consumer Technology Association',
        exhibitorsCount: 4500,
        visitorsCount: 170000,
        tags: ['technology', 'electronics', 'AI', 'robotics', 'innovation'],
        languages: ['English'],
        isPremium: true,
        isFeatured: true,
      ),
      Exhibition(
        id: _uuid.v4(),
        name: 'Mobile World Congress 2027',
        nameAr: 'المؤتمر العالمي للجوال 2027',
        nameFr: 'Mobile World Congress 2027',
        description: 'The largest mobile industry event featuring the latest smartphones, 5G/6G networks, IoT, and mobile connectivity solutions.',
        descriptionAr: 'أكبر فعالية لصناعة الجوال تعرض أحدث الهواتف الذكية وشبكات 5G/6G وإنترنت الأشياء',
        descriptionFr: 'Le plus grand événement de l\'industrie mobile présentant les derniers smartphones, réseaux 5G/6G, IoT.',
        industries: ['Technology', 'Telecommunications', 'Mobile'],
        country: 'Spain',
        city: 'Barcelona',
        startDate: now.add(const Duration(days: 60)),
        endDate: now.add(const Duration(days: 63)),
        venue: 'Fira Barcelona Gran Via',
        images: [],
        youtubeVideoId: 'WYxQ6jGXmBc',
        registrationUrl: 'https://www.mwcbarcelona.com',
        website: 'https://www.mwcbarcelona.com',
        organizer: 'GSMA',
        exhibitorsCount: 2400,
        visitorsCount: 88000,
        tags: ['mobile', '5G', 'telecom', 'IoT', 'smartphones'],
        languages: ['English', 'Spanish'],
        isPremium: true,
        isFeatured: true,
      ),
      Exhibition(
        id: _uuid.v4(),
        name: 'International Automotive Exhibition 2027',
        nameAr: 'المعرض الدولي للسيارات 2027',
        nameFr: 'Salon International de l\'Automobile 2027',
        description: 'Premier automotive expo featuring electric vehicles, autonomous driving technology, and the future of mobility.',
        descriptionAr: 'أهم معرض للسيارات يعرض السيارات الكهربائية وتقنيات القيادة الذاتية ومستقبل التنقل',
        descriptionFr: 'Premier salon automobile présentant les véhicules électriques, la conduite autonome et l\'avenir de la mobilité.',
        industries: ['Automotive', 'Technology', 'Energy'],
        country: 'Germany',
        city: 'Frankfurt',
        startDate: now.add(const Duration(days: 80)),
        endDate: now.add(const Duration(days: 85)),
        venue: 'Messe Frankfurt',
        images: [],
        youtubeVideoId: 'kY7Q5pJcBmA',
        registrationUrl: 'https://www.iaa.de',
        website: 'https://www.iaa.de',
        organizer: 'VDA',
        exhibitorsCount: 1200,
        visitorsCount: 800000,
        tags: ['automotive', 'EV', 'autonomous', 'mobility'],
        languages: ['German', 'English'],
        isPremium: true,
        isFeatured: true,
      ),
      Exhibition(
        id: _uuid.v4(),
        name: 'Arab Health 2027',
        nameAr: 'الصحة العربي 2027',
        nameFr: 'Arab Health 2027',
        description: 'The Middle East\'s largest healthcare exhibition and congress bringing together medical professionals and innovators.',
        descriptionAr: 'أكبر معرض صحي في الشرق الأوسط يجمع المتخصصين الطبيين والمبتكرين',
        descriptionFr: 'Le plus grand salon de la santé au Moyen-Orient réunissant professionnels médicaux et innovateurs.',
        industries: ['Healthcare', 'Medical'],
        country: 'UAE',
        city: 'Dubai',
        startDate: now.add(const Duration(days: 30)),
        endDate: now.add(const Duration(days: 33)),
        venue: 'Dubai World Trade Centre',
        images: [],
        youtubeVideoId: 'vTqJ3pGkDxA',
        registrationUrl: 'https://www.arabhealthonline.com',
        website: 'https://www.arabhealthonline.com',
        organizer: 'Informa Markets',
        exhibitorsCount: 4200,
        visitorsCount: 100000,
        tags: ['healthcare', 'medical', 'Dubai', 'conference'],
        languages: ['English', 'Arabic'],
        isPremium: false,
        isFeatured: true,
      ),
      Exhibition(
        id: _uuid.v4(),
        name: 'Paris Air Show 2027',
        nameAr: 'معرض باريس الجوي 2027',
        nameFr: 'Salon du Bourget 2027',
        description: 'The world\'s premier air and space show featuring cutting-edge aerospace technology, aircraft, and defense systems.',
        descriptionAr: 'أهم معرض جوي وفضائي في العالم يعرض أحدث تقنيات الطيران والفضاء والطائرات والأنظمة الدفاعية',
        descriptionFr: 'Le plus grand salon aéronautique et spatial du monde présentant les technologies de pointe, avions et systèmes de défense.',
        industries: ['Aerospace', 'Defense', 'Technology'],
        country: 'France',
        city: 'Paris',
        startDate: now.add(const Duration(days: 110)),
        endDate: now.add(const Duration(days: 116)),
        venue: 'Paris-Le Bourget Airport',
        images: [],
        youtubeVideoId: 'Fq8P3nRfBzE',
        registrationUrl: 'https://www.siae.fr',
        website: 'https://www.siae.fr',
        organizer: 'SIAE',
        exhibitorsCount: 2500,
        visitorsCount: 350000,
        tags: ['aerospace', 'aviation', 'defense', 'space'],
        languages: ['French', 'English'],
        isPremium: true,
        isFeatured: true,
      ),
      Exhibition(
        id: _uuid.v4(),
        name: 'GITEX Technology Week',
        nameAr: 'أسبوع جيتكس للتقنية',
        nameFr: 'GITEX Technology Week',
        description: 'The Middle East\'s largest technology expo showcasing digital transformation, AI, cloud computing, and startups.',
        descriptionAr: 'أكبر معرض تقني في الشرق الأوسط يعرض التحول الرقمي والذكاء الاصطناعي والحوسبة السحابية والشركات الناشئة',
        descriptionFr: 'Le plus grand salon technologique du Moyen-Orient présentant la transformation numérique, l\'IA, le cloud et les startups.',
        industries: ['Technology', 'AI', 'Startups'],
        country: 'UAE',
        city: 'Dubai',
        startDate: now.add(const Duration(days: 130)),
        endDate: now.add(const Duration(days: 135)),
        venue: 'Dubai World Trade Centre',
        images: [],
        youtubeVideoId: 'mHdQjL5sWpE',
        registrationUrl: 'https://www.gitex.com',
        website: 'https://www.gitex.com',
        organizer: 'Dubai World Trade Centre',
        exhibitorsCount: 4500,
        visitorsCount: 150000,
        tags: ['technology', 'AI', 'startups', 'digital', 'Dubai'],
        languages: ['English', 'Arabic'],
        isPremium: true,
        isFeatured: true,
      ),
      Exhibition(
        id: _uuid.v4(),
        name: 'World Food Expo 2027',
        nameAr: 'معرض الغذاء العالمي 2027',
        nameFr: 'Salon Mondial de l\'Alimentation 2027',
        description: 'International food and beverage exhibition featuring global cuisines, food technology, and sustainable agriculture.',
        descriptionAr: 'معرض دولي للأغذية والمشروبات يعرض المأكولات العالمية وتقنيات الطعام والزراعة المستدامة',
        descriptionFr: 'Salon international de l\'alimentation et des boissons présentant les cuisines du monde, la technologie alimentaire.',
        industries: ['Food & Beverage', 'Agriculture'],
        country: 'Italy',
        city: 'Milan',
        startDate: now.add(const Duration(days: 90)),
        endDate: now.add(const Duration(days: 94)),
        venue: 'Fiera Milano',
        images: [],
        youtubeVideoId: 'bLpK3qXgZfE',
        registrationUrl: 'https://www.worldfoodexpo.com',
        website: 'https://www.worldfoodexpo.com',
        organizer: 'Fiera Milano',
        exhibitorsCount: 3000,
        visitorsCount: 200000,
        tags: ['food', 'beverage', 'agriculture', 'sustainability'],
        languages: ['Italian', 'English'],
        isPremium: false,
        isFeatured: false,
      ),
      Exhibition(
        id: _uuid.v4(),
        name: 'Cairo International Book Fair',
        nameAr: 'معرض القاهرة الدولي للكتاب',
        nameFr: 'Foire Internationale du Caire du Livre',
        description: 'One of the largest book fairs in the world featuring publishers, authors, and literary events from across the globe.',
        descriptionAr: 'أحد أكبر معارض الكتب في العالم يضم ناشرين ومؤلفين وفعاليات أدبية من جميع أنحاء العالم',
        descriptionFr: 'L\'une des plus grandes foires du livre au monde réunissant éditeurs, auteurs et événements littéraires.',
        industries: ['Publishing', 'Education', 'Culture'],
        country: 'Egypt',
        city: 'Cairo',
        startDate: now.add(const Duration(days: 20)),
        endDate: now.add(const Duration(days: 38)),
        venue: 'Egypt International Exhibition Center',
        images: [],
        youtubeVideoId: null,
        registrationUrl: 'https://www.cairobookfair.org',
        website: 'https://www.cairobookfair.org',
        organizer: 'General Egyptian Book Organization',
        exhibitorsCount: 900,
        visitorsCount: 3000000,
        tags: ['books', 'publishing', 'culture', 'education'],
        languages: ['Arabic', 'English', 'French'],
        isPremium: false,
        isFeatured: false,
      ),
    ];

    final batch = _db.batch();
    for (final exhibition in samples) {
      final ref = _db.collection(AppConstants.collectionExhibitions).doc(exhibition.id);
      batch.set(ref, exhibition.toFirestore());
    }
    await batch.commit();
  }
}
