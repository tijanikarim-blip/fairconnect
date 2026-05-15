class AppUser {
  final String id;
  final String email;
  final String? displayName;
  final String? phoneNumber;
  final String preferredLanguage;
  final bool isPremium;
  final DateTime? premiumExpiry;
  final List<String> favoriteExhibitionIds;
  final DateTime createdAt;
  final bool isAdmin;

  AppUser({
    required this.id,
    required this.email,
    this.displayName,
    this.phoneNumber,
    this.preferredLanguage = 'en',
    this.isPremium = false,
    this.premiumExpiry,
    this.favoriteExhibitionIds = const [],
    DateTime? createdAt,
    this.isAdmin = false,
  }) : createdAt = createdAt ?? DateTime.now();

  factory AppUser.fromFirestore(Map<String, dynamic> data, String id) {
    return AppUser(
      id: id,
      email: data['email'] ?? '',
      displayName: data['displayName'],
      phoneNumber: data['phoneNumber'],
      preferredLanguage: data['preferredLanguage'] ?? 'en',
      isPremium: data['isPremium'] ?? false,
      premiumExpiry: data['premiumExpiry'] != null
          ? (data['premiumExpiry'] as dynamic).toDate()
          : null,
      favoriteExhibitionIds:
          List<String>.from(data['favoriteExhibitionIds'] ?? []),
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as dynamic).toDate()
          : DateTime.now(),
      isAdmin: data['isAdmin'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'displayName': displayName,
      'phoneNumber': phoneNumber,
      'preferredLanguage': preferredLanguage,
      'isPremium': isPremium,
      'premiumExpiry': premiumExpiry,
      'favoriteExhibitionIds': favoriteExhibitionIds,
      'createdAt': createdAt,
      'isAdmin': isAdmin,
    };
  }

  bool get isPremiumValid =>
      isPremium && premiumExpiry != null && premiumExpiry!.isAfter(DateTime.now());

  AppUser copyWith({
    String? displayName,
    String? phoneNumber,
    String? preferredLanguage,
    bool? isPremium,
    DateTime? premiumExpiry,
    List<String>? favoriteExhibitionIds,
    bool? isAdmin,
  }) {
    return AppUser(
      id: id,
      email: email,
      displayName: displayName ?? this.displayName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      isPremium: isPremium ?? this.isPremium,
      premiumExpiry: premiumExpiry ?? this.premiumExpiry,
      favoriteExhibitionIds:
          favoriteExhibitionIds ?? this.favoriteExhibitionIds,
      createdAt: createdAt,
      isAdmin: isAdmin ?? this.isAdmin,
    );
  }
}
