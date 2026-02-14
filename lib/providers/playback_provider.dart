import 'package:flutter/material.dart';

class PlaybackProvider with ChangeNotifier {
  final Map<String, Duration> _progress = {};

  Duration getProgress(String movieId) => _progress[movieId] ?? Duration.zero;

  void updateProgress(String movieId, Duration position) {
    _progress[movieId] = position;
    notifyListeners();
  }

  void resetProgress(String movieId) {
    _progress[movieId] = Duration.zero;
    notifyListeners();
  }
}
