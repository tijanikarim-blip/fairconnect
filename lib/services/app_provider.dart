import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/app_user.dart';
import '../models/exhibition.dart';
import 'auth_service.dart';
import 'firestore_service.dart';
import 'localization_service.dart';
import 'notification_service.dart';

class AppProvider extends ChangeNotifier {
  final AuthService _auth = AuthService();
  final FirestoreService _firestore = FirestoreService();
  final LocalizationService _localization = LocalizationService();
  Timer? _reminderTimer;
  StreamSubscription<User?>? _authSubscription;
  StreamSubscription<AppUser?>? _userSubscription;
  StreamSubscription<List<Exhibition>>? _exhibitionsSubscription;

  AppUser? _currentUser;
  User? _firebaseUser;
  List<Exhibition> _exhibitions = [];
  bool _isLoading = false;
  String? _error;

  AppUser? get currentUser => _currentUser;
  User? get firebaseUser => _firebaseUser;
  List<Exhibition> get exhibitions => _exhibitions;
  bool get isLoading => _isLoading;
  String? get error => _error;
  LocalizationService get localization => _localization;

  void init() {
    _startReminderCheck();
    _authSubscription = _auth.authState.listen(
      (user) {
        _firebaseUser = user;
        _userSubscription?.cancel();
        if (user != null) {
          _userSubscription = _firestore.getUser(user.uid).listen(
            (appUser) {
              _currentUser = appUser;
              notifyListeners();
            },
            onError: (error) {
              _error = error.toString();
              notifyListeners();
            },
          );
        } else {
          _currentUser = null;
          notifyListeners();
        }
      },
      onError: (error) {
        _error = error.toString();
        notifyListeners();
      },
    );

    _exhibitionsSubscription = _firestore.getExhibitions().listen(
      (list) {
        _exhibitions = list;
        notifyListeners();
      },
      onError: (error) {
        _error = error.toString();
        notifyListeners();
      },
    );
  }

  void _startReminderCheck() {
    _reminderTimer?.cancel();
    _reminderTimer = Timer.periodic(const Duration(minutes: 4), (_) async {
      try {
        final dueReminders = await _firestore.getDueReminders();
        for (final reminder in dueReminders) {
          final id = reminder['id'] as String;
          await NotificationService().showExhibitionReminder(
            id: id.hashCode,
            title: 'Exhibition Reminder',
            body: 'An exhibition you saved is coming up!',
          );
          await _firestore.markReminderSent(id);
        }
      } catch (_) {}
    });
  }

  @override
  void dispose() {
    _reminderTimer?.cancel();
    _authSubscription?.cancel();
    _userSubscription?.cancel();
    _exhibitionsSubscription?.cancel();
    super.dispose();
  }

  Future<bool> signIn(String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();
      await _auth.signInWithEmail(email, password);
      _error = null;
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register(String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();
      final cred = await _auth.registerWithEmail(email, password);
      if (cred.user == null) throw Exception('Registration failed - no user returned');
      final user = AppUser(
        id: cred.user!.uid,
        email: email,
      );
      await _firestore.createUser(user);
      _error = null;
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> signInWithGoogle() async {
    try {
      _isLoading = true;
      notifyListeners();
      await _auth.signInWithGoogle();
      _error = null;
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> toggleFavorite(String exhibitionId) async {
    if (_currentUser == null) return;
    final userId = _currentUser!.id;
    if (_currentUser!.favoriteExhibitionIds.contains(exhibitionId)) {
      await _firestore.removeFavorite(userId, exhibitionId);
    } else {
      await _firestore.addFavorite(userId, exhibitionId);
    }
  }

  bool isFavorite(String exhibitionId) {
    return _currentUser?.favoriteExhibitionIds.contains(exhibitionId) ?? false;
  }

  List<Exhibition> get favoriteExhibitions {
    final favIds = _currentUser?.favoriteExhibitionIds ?? [];
    return _exhibitions.where((e) => favIds.contains(e.id)).toList();
  }

  void setLocale(Locale locale) {
    _localization.setLocale(locale);
    notifyListeners();
  }
}
