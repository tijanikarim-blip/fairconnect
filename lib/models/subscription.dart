class Subscription {
  final String id;
  final String userId;
  final String productId;
  final DateTime purchaseDate;
  final DateTime expiryDate;
  final bool isActive;
  final String paymentMethod;

  Subscription({
    required this.id,
    required this.userId,
    required this.productId,
    required this.purchaseDate,
    required this.expiryDate,
    this.isActive = true,
    this.paymentMethod = '',
  });

  factory Subscription.fromFirestore(Map<String, dynamic> data, String id) {
    return Subscription(
      id: id,
      userId: data['userId'] ?? '',
      productId: data['productId'] ?? '',
      purchaseDate: data['purchaseDate'] != null
          ? (data['purchaseDate'] as dynamic).toDate()
          : DateTime.now(),
      expiryDate: data['expiryDate'] != null
          ? (data['expiryDate'] as dynamic).toDate()
          : DateTime.now(),
      isActive: data['isActive'] ?? true,
      paymentMethod: data['paymentMethod'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'productId': productId,
      'purchaseDate': purchaseDate,
      'expiryDate': expiryDate,
      'isActive': isActive,
      'paymentMethod': paymentMethod,
    };
  }
}
