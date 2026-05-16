import 'package:firebase_remote_config/firebase_remote_config.dart';

class RemoteConfigService {
  static final RemoteConfigService _instance = RemoteConfigService._();
  factory RemoteConfigService() => _instance;
  RemoteConfigService._();

  late RemoteConfig _remoteConfig;

  static const String _defaultPremiumPrice = '49.99';
  static const String _defaultMinExhibitors = '100';
  static const String _defaultShowOnboarding = 'true';
  static const String _defaultMaintenanceMode = 'false';
  static const String _defaultAppVersion = '1.0.0';

  String get premiumPrice => _remoteConfig.getString('premium_price').isEmpty
      ? _defaultPremiumPrice
      : _remoteConfig.getString('premium_price');

  int get minExhibitors => int.tryParse(_remoteConfig.getString('min_exhibitors')) ?? 100;

  bool get showOnboarding => _remoteConfig.getBool('show_onboarding');

  bool get maintenanceMode => _remoteConfig.getBool('maintenance_mode');

  String get appVersion => _remoteConfig.getString('app_version').isEmpty
      ? _defaultAppVersion
      : _remoteConfig.getString('app_version');

  String get minAppVersion => _remoteConfig.getString('min_app_version').isEmpty
      ? _defaultAppVersion
      : _remoteConfig.getString('min_app_version');

  String get whatsNew => _remoteConfig.getString('whats_new');

  List<String> get featuredIndustries {
    final value = _remoteConfig.getString('featured_industries');
    if (value.isEmpty) return [];
    return value.split(',').map((e) => e.trim()).toList();
  }

  List<String> get supportedCountries {
    final value = _remoteConfig.getString('supported_countries');
    if (value.isEmpty) return ['China', 'Germany', 'UAE', 'Turkey', 'USA', 'Italy', 'Spain'];
    return value.split(',').map((e) => e.trim()).toList();
  }

  Future<void> init() async {
    _remoteConfig = RemoteConfig.instance;

    await _remoteConfig.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: const Duration(seconds: 10),
      minimumFetchInterval: const Duration(hours: 1),
    ));

    await _fetchConfig();
  }

  Future<void> _fetchConfig() async {
    try {
      await _remoteConfig.fetchAndActivate();
    } catch (e) {
      print('Error fetching remote config: $e');
    }
  }

  Future<void> refresh() async {
    await _fetchConfig();
  }

  bool shouldUpdateApp() {
    final current = appVersion.split('.').map(int.parse).toList();
    final min = minAppVersion.split('.').map(int.parse).toList();

    for (int i = 0; i < 3; i++) {
      if (current[i] < min[i]) return true;
      if (current[i] > min[i]) return false;
    }
    return false;
  }
}