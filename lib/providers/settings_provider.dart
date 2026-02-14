import 'package:flutter/material.dart';

class SettingsProvider with ChangeNotifier {
  String _language = 'English';
  bool _notificationsEnabled = true;
  String _playbackQuality = 'Auto';
  bool _isOffline = false;

  String get language => _language;
  bool get notificationsEnabled => _notificationsEnabled;
  String get playbackQuality => _playbackQuality;
  bool get isOffline => _isOffline;

  void setLanguage(String lang) {
    _language = lang;
    notifyListeners();
  }

  void toggleNotifications(bool value) {
    _notificationsEnabled = value;
    notifyListeners();
  }

  void setPlaybackQuality(String quality) {
    _playbackQuality = quality;
    notifyListeners();
  }

  void setOfflineMode(bool value) {
    _isOffline = value;
    notifyListeners();
  }
}
