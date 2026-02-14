import 'package:flutter/foundation.dart';
import 'package:flutter_chrome_cast/flutter_chrome_cast.dart';
import 'dart:async';
import 'dart:io';

class CastService extends ChangeNotifier {
  List<GoogleCastDevice> _devices = [];
  GoogleCastDevice? _selectedDevice;
  bool _isScanning = false;
  bool _isConnected = false;
  StreamSubscription? _discoverySubscription;
  StreamSubscription? _sessionSubscription;

  List<GoogleCastDevice> get devices => _devices;
  GoogleCastDevice? get selectedDevice => _selectedDevice;
  bool get isScanning => _isScanning;
  bool get isConnected => _isConnected;

  CastService() {
    _init();
  }

  void _init() {
    _sessionSubscription = GoogleCastSessionManager.instance.currentSessionStream.listen((session) {
      _isConnected = GoogleCastSessionManager.instance.connectionState == GoogleCastConnectState.connected;
      if (!_isConnected) {
         _selectedDevice = null;
      }
      notifyListeners();
    });
  }

  Future<void> initContext() async {
    const appId = GoogleCastDiscoveryCriteria.kDefaultApplicationId;
    GoogleCastOptions? options;
    if (Platform.isIOS) {
      options = IOSGoogleCastOptions(
        GoogleCastDiscoveryCriteriaInitialize.initWithApplicationID(appId),
      );
    } else {
      options = GoogleCastOptionsAndroid(
        appId: appId,
      );
    }
    await GoogleCastContext.instance.setSharedInstanceWithOptions(options);
  }

  void startScanning() {
    if (_isScanning) return;
    _isScanning = true;
    _devices = [];
    notifyListeners();

    GoogleCastDiscoveryManager.instance.startDiscovery();
    _discoverySubscription = GoogleCastDiscoveryManager.instance.devicesStream.listen((devices) {
      _devices = devices;
      notifyListeners();
    });
  }

  void stopScanning() {
    _isScanning = false;
    GoogleCastDiscoveryManager.instance.stopDiscovery();
    _discoverySubscription?.cancel();
    notifyListeners();
  }

  Future<void> connectToDevice(GoogleCastDevice device) async {
    _selectedDevice = device;
    notifyListeners();
    await GoogleCastSessionManager.instance.startSessionWithDevice(device);
  }

  Future<void> disconnect() async {
    await GoogleCastSessionManager.instance.endSessionAndStopCasting();
    _selectedDevice = null;
    notifyListeners();
  }

  Future<void> loadMedia(String url, {String? title, String? subtitle}) async {
    if (!_isConnected) return;

    final media = GoogleCastMediaInformation(
      contentId: url,
      contentType: 'video/mp4',
      streamType: CastMediaStreamType.buffered,
      metadata: GoogleCastMovieMediaMetadata(
        title: title ?? 'Video',
        subtitle: subtitle ?? 'RIYOBOX',
      ),
    );

    await GoogleCastRemoteMediaClient.instance.loadMedia(media);
  }

  @override
  void dispose() {
    _discoverySubscription?.cancel();
    _sessionSubscription?.cancel();
    super.dispose();
  }
}
