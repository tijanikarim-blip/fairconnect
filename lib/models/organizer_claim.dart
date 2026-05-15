class OrganizerClaim {
  final String id;
  final String exhibitionId;
  final String userId;
  final String companyName;
  final String contactEmail;
  final String? phone;
  final String? website;
  final String status;
  final DateTime createdAt;
  final DateTime? approvedAt;

  OrganizerClaim({
    required this.id,
    required this.exhibitionId,
    required this.userId,
    required this.companyName,
    required this.contactEmail,
    this.phone,
    this.website,
    this.status = 'pending',
    DateTime? createdAt,
    this.approvedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory OrganizerClaim.fromFirestore(Map<String, dynamic> data, String id) {
    return OrganizerClaim(
      id: id,
      exhibitionId: data['exhibitionId'] ?? '',
      userId: data['userId'] ?? '',
      companyName: data['companyName'] ?? '',
      contactEmail: data['contactEmail'] ?? '',
      phone: data['phone'],
      website: data['website'],
      status: data['status'] ?? 'pending',
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as dynamic).toDate()
          : DateTime.now(),
      approvedAt: data['approvedAt'] != null
          ? (data['approvedAt'] as dynamic).toDate()
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'exhibitionId': exhibitionId,
      'userId': userId,
      'companyName': companyName,
      'contactEmail': contactEmail,
      'phone': phone,
      'website': website,
      'status': status,
      'createdAt': createdAt,
      'approvedAt': approvedAt,
    };
  }
}
