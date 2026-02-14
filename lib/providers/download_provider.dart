import 'package:flutter/material.dart';
import 'package:riyobox/models/movie.dart';

enum DownloadQuality { low, medium, high }

class DownloadProvider with ChangeNotifier {
  final List<Movie> _downloadingMovies = [];
  final List<Movie> _downloadedMovies = [];

  // Settings
  DownloadQuality _quality = DownloadQuality.medium;
  bool _wifiOnly = true;
  bool _autoDownloadEpisodes = true;
  bool _autoDownloadRecommendations = true;
  bool _onlyWhenCharging = false;
  bool _autoDeleteAfterWatching = true;
  int _keepDays = 30;

  List<Movie> get downloadingMovies => _downloadingMovies;
  List<Movie> get downloadedMovies => _downloadedMovies;

  DownloadQuality get quality => _quality;
  bool get wifiOnly => _wifiOnly;
  bool get autoDownloadEpisodes => _autoDownloadEpisodes;
  bool get autoDownloadRecommendations => _autoDownloadRecommendations;
  bool get onlyWhenCharging => _onlyWhenCharging;
  bool get autoDeleteAfterWatching => _autoDeleteAfterWatching;
  int get keepDays => _keepDays;

  // Storage stats (Mock)
  double get totalStorageGB => 128.0;
  double get usedStorageGB => 45.2;
  double get downloadsSizeGB => 1.2;

  DownloadProvider() {
    _initMockData();
  }

  void _initMockData() {
    _downloadingMovies.add(
      Movie(
        id: 8,
        title: 'Fallout',
        overview: 'Post-apocalyptic series',
        posterPath: '',
        releaseDate: '2024',
        isTvShow: true,
        isDownloading: true,
        downloadProgress: 0.85,
        fileSize: '280.7 MB',
        downloadedEpisodesCount: 1,
      )
    );

    _downloadedMovies.add(
      Movie(
        id: 9,
        title: 'Road House',
        overview: 'Action movie',
        posterPath: '',
        releaseDate: '2024',
        runtime: 123,
        fileSize: '520.1 MB',
        isDownloaded: true,
      )
    );
  }

  void setQuality(DownloadQuality quality) {
    _quality = quality;
    notifyListeners();
  }

  void setWifiOnly(bool value) {
    _wifiOnly = value;
    notifyListeners();
  }

  void setAutoDownloadEpisodes(bool value) {
    _autoDownloadEpisodes = value;
    notifyListeners();
  }

  void setAutoDownloadRecommendations(bool value) {
    _autoDownloadRecommendations = value;
    notifyListeners();
  }

  void setOnlyWhenCharging(bool value) {
    _onlyWhenCharging = value;
    notifyListeners();
  }

  void setAutoDeleteAfterWatching(bool value) {
    _autoDeleteAfterWatching = value;
    notifyListeners();
  }

  void setKeepDays(int days) {
    _keepDays = days;
    notifyListeners();
  }

  void cancelDownload(int movieId) {
    _downloadingMovies.removeWhere((m) => m.id == movieId);
    notifyListeners();
  }

  void deleteDownload(int movieId) {
    _downloadedMovies.removeWhere((m) => m.id == movieId);
    notifyListeners();
  }

  void clearAllDownloads() {
    _downloadedMovies.clear();
    _downloadingMovies.clear();
    notifyListeners();
  }
}
