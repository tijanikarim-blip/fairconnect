class Exhibition {
  final String id;
  final String name;
  final String nameAr;
  final String nameFr;
  final String slug;
  final String description;
  final String descriptionAr;
  final String descriptionFr;
  final List<String> industries;
  final String country;
  final String city;
  final DateTime startDate;
  final DateTime endDate;
  final String venue;
  final List<String> images;
  final String? youtubeVideoId;
  final String registrationUrl;
  final String? website;
  final String organizer;
  final int? exhibitorsCount;
  final int? visitorsCount;
  final List<String> tags;
  final List<String> languages;
  final DateTime? lastVerifiedAt;
  final bool isPremium;
  final bool isFeatured;
  final DateTime createdAt;

  Exhibition({
    required this.id,
    required this.name,
    this.nameAr = '',
    this.nameFr = '',
    String? slug,
    this.description = '',
    this.descriptionAr = '',
    this.descriptionFr = '',
    List<String>? industries,
    required this.country,
    required this.city,
    required this.startDate,
    required this.endDate,
    required this.venue,
    List<String>? images,
    this.youtubeVideoId,
    required this.registrationUrl,
    required this.organizer,
    this.website,
    this.exhibitorsCount,
    this.visitorsCount,
    List<String>? tags,
    List<String>? languages,
    this.lastVerifiedAt,
    this.isPremium = false,
    this.isFeatured = false,
    DateTime? createdAt,
  })  : slug = slug ?? _generateSlug(name),
        industries = industries ?? [],
        images = images ?? [],
        tags = tags ?? [],
        languages = languages ?? [],
        createdAt = createdAt ?? DateTime.now();

  static String _generateSlug(String name) {
    return name
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s-]'), '')
        .replaceAll(RegExp(r'\s+'), '-')
        .replaceAll(RegExp(r'-+'), '-')
        .trim();
  }

  factory Exhibition.fromFirestore(Map<String, dynamic> data, String id) {
    return Exhibition(
      id: id,
      name: data['name'] ?? '',
      nameAr: data['nameAr'] ?? '',
      nameFr: data['nameFr'] ?? '',
      slug: data['slug'] ?? '',
      description: data['description'] ?? '',
      descriptionAr: data['descriptionAr'] ?? '',
      descriptionFr: data['descriptionFr'] ?? '',
      industries: _toList(data['industries'] ?? data['industry']),
      country: data['country'] ?? '',
      city: data['city'] ?? '',
      startDate: (data['startDate'] as dynamic).toDate(),
      endDate: (data['endDate'] as dynamic).toDate(),
      venue: data['venue'] ?? '',
      images: _toList(
          data['images'] ?? (data['imageUrl'] != null ? [data['imageUrl']] : [])),
      youtubeVideoId: data['youtubeVideoId'] ?? data['youtube_video_url'],
      registrationUrl: data['registrationUrl'] ?? data['registration_url'] ?? '',
      organizer: data['organizer'] ?? '',
      website: data['website'] ?? data['official_website'],
      exhibitorsCount: data['exhibitors_count'] ?? data['exhibitorsCount'],
      visitorsCount: data['visitors_count'] ?? data['visitorsCount'],
      tags: _toList(data['tags']),
      languages: _toList(data['languages']),
      lastVerifiedAt: data['last_verified_at'] != null
          ? (data['last_verified_at'] as dynamic).toDate()
          : null,
      isPremium: data['isPremium'] ?? false,
      isFeatured: data['isFeatured'] ?? false,
      createdAt: (data['createdAt'] as dynamic).toDate(),
    );
  }

  static List<String> _toList(dynamic value) {
    if (value is List) return List<String>.from(value.map((e) => e.toString()));
    if (value is String && value.isNotEmpty) return [value];
    return [];
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'nameAr': nameAr,
      'nameFr': nameFr,
      'slug': slug,
      'description': description,
      'descriptionAr': descriptionAr,
      'descriptionFr': descriptionFr,
      'industries': industries,
      'industry': industries.isNotEmpty ? industries.first : '',
      'country': country,
      'city': city,
      'startDate': startDate,
      'endDate': endDate,
      'venue': venue,
      'images': images,
      'imageUrl': images.isNotEmpty ? images.first : null,
      'youtubeVideoId': youtubeVideoId,
      'registrationUrl': registrationUrl,
      'organizer': organizer,
      'website': website,
      'exhibitors_count': exhibitorsCount,
      'visitors_count': visitorsCount,
      'tags': tags,
      'languages': languages,
      'last_verified_at': lastVerifiedAt,
      'isPremium': isPremium,
      'isFeatured': isFeatured,
      'createdAt': createdAt,
    };
  }

  String get industry => industries.isNotEmpty ? industries.first : '';

  String? get imageUrl => images.isNotEmpty ? images.first : null;

  String get durationText {
    final days = endDate.difference(startDate).inDays;
    if (days == 0) return '1 day';
    return '$days days';
  }

  bool get isOngoing {
    final now = DateTime.now();
    return startDate.isBefore(now) && endDate.isAfter(now);
  }

  bool get isUpcoming => startDate.isAfter(DateTime.now());

  bool get isPast => endDate.isBefore(DateTime.now());
}
