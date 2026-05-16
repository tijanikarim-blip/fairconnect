import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._();
  factory AnalyticsService() => _instance;
  AnalyticsService._();

  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  Future<void> init() async {
    await _analytics.setAnalyticsCollectionEnabled(true);
  }

  Future<void> logAppOpen() async {
    await _analytics.logAppOpen();
  }

  Future<void> logEvent({
    required String name,
    Map<String, Object>? parameters,
  }) async {
    await _analytics.logEvent(name: name, parameters: parameters);
  }

  Future<void> logSearch(String searchTerm) async {
    await _analytics.logSearch(searchTerm: searchTerm);
  }

  Future<void> logViewItem({
    required String itemId,
    required String itemName,
    String? category,
  }) async {
    await _analytics.logViewItem(
      items: [
        AnalyticsEventItem(
          itemId: itemId,
          itemName: itemName,
          itemCategory: category,
        ),
      ],
    );
  }

  Future<void> logAddToFavorites(String exhibitionId, String exhibitionName) async {
    await _analytics.logAddToCart(
      value: 1,
      currency: 'USD',
      items: [
        AnalyticsEventItem(
          itemId: exhibitionId,
          itemName: exhibitionName,
          itemCategory: 'Exhibition',
        ),
      ],
    );
  }

  Future<void> logRemoveFromFavorites(String exhibitionId, String exhibitionName) async {
    await _analytics.logRemoveFromCart(
      items: [
        AnalyticsEventItem(
          itemId: exhibitionId,
          itemName: exhibitionName,
          itemCategory: 'Exhibition',
        ),
      ],
    );
  }

  Future<void> logSetReminder(String exhibitionId, String exhibitionName) async {
    await _analytics.logEvent(
      name: 'set_reminder',
      parameters: {
        'exhibition_id': exhibitionId,
        'exhibition_name': exhibitionName,
      },
    );
  }

  Future<void> logWatchVideo(String exhibitionId, String exhibitionName) async {
    await _analytics.logEvent(
      name: 'watch_video',
      parameters: {
        'exhibition_id': exhibitionId,
        'exhibition_name': exhibitionName,
      },
    );
  }

  Future<void> logRegisterClick(String exhibitionId, String exhibitionName) async {
    await _analytics.logEvent(
      name: 'register_click',
      parameters: {
        'exhibition_id': exhibitionId,
        'exhibition_name': exhibitionName,
      },
    );
  }

  Future<void> logSubscriptionStart(String plan) async {
    await _analytics.logBeginCheckout(
      value: 49.99,
      currency: 'USD',
      items: [
        AnalyticsEventItem(
          itemId: 'premium_annual',
          itemName: 'FairConnect Premium Annual',
          itemCategory: 'Subscription',
          price: 49.99,
        ),
      ],
    );
  }

  Future<void> logSubscriptionSuccess(String plan) async {
    await _analytics.logPurchase(
      value: 49.99,
      currency: 'USD',
      items: [
        AnalyticsEventItem(
          itemId: 'premium_annual',
          itemName: 'FairConnect Premium Annual',
          itemCategory: 'Subscription',
          price: 49.99,
        ),
      ],
    );
  }

  Future<void> logLanguageChange(String languageCode) async {
    await _analytics.logEvent(
      name: 'language_change',
      parameters: {
        'language_code': languageCode,
      },
    );
  }

  Future<void> logFilterUsage({
    String? industry,
    String? country,
    String? dateRange,
  }) async {
    await _analytics.logEvent(
      name: 'filter_used',
      parameters: {
        if (industry != null) 'industry': industry,
        if (country != null) 'country': country,
        if (dateRange != null) 'date_range': dateRange,
      },
    );
  }

  Future<void> setUserProperties({
    String? userId,
    bool? isPremium,
    String? preferredLanguage,
  }) async {
    if (userId != null) {
      await _analytics.setUserId(id: userId);
    }
    if (isPremium != null) {
      await _analytics.setUserProperty(name: 'is_premium', value: isPremium.toString());
    }
    if (preferredLanguage != null) {
      await _analytics.setUserProperty(name: 'language', value: preferredLanguage);
    }
  }
}