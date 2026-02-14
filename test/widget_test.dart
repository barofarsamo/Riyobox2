import 'dart:async';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:riyobox/main.dart';

void main() {
  setUpAll(() {
    HttpOverrides.global = _MockHttpOverrides();
  });

  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Splash Screen should be visible initially
    expect(find.text('RIYOBOX'), findsAtLeast(1));
    expect(find.text('PREMIUM STREAMING EXPERIENCE'), findsOneWidget);

    // Wait for splash animation to finish (2.5s in code)
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    // After splash, since onboarding is not complete, we should be on Welcome Screen
    expect(find.text('Unlimited movies, TV shows, and more.'), findsOneWidget);
    expect(find.text('GET STARTED'), findsOneWidget);
  });
}

class _MockHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) => _MockHttpClient();
}

class _MockHttpClient implements HttpClient {
  @override
  Future<HttpClientRequest> getUrl(Uri url) async => _MockHttpClientRequest();

  @override
  Future<HttpClientRequest> get(String host, int port, String path) async => _MockHttpClientRequest();

  @override
  bool autoUncompress = true;

  @override
  Duration? connectionTimeout;

  @override
  Duration idleTimeout = const Duration(seconds: 15);

  @override
  int? maxConnectionsPerHost;

  @override
  String? userAgent;

  @override
  dynamic noSuchMethod(Invocation invocation) {
    return null;
  }
}

class _MockHttpClientRequest implements HttpClientRequest {
  @override
  HttpHeaders get headers => _MockHttpHeaders();

  @override
  Future<HttpClientRequest> openUrl(String method, Uri url) async => this;

  @override
  Future<HttpClientResponse> close() async => _MockHttpClientResponse();

  @override
  dynamic noSuchMethod(Invocation invocation) {
    return null;
  }
}

class _MockHttpClientResponse implements HttpClientResponse {
  final List<int> _data = [
    0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52,
    0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01, 0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4,
    0x89, 0x00, 0x00, 0x00, 0x0A, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
    0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE,
    0x42, 0x60, 0x82
  ];

  @override
  int get statusCode => 200;

  @override
  int get contentLength => _data.length;

  @override
  HttpClientResponseCompressionState get compressionState => HttpClientResponseCompressionState.notCompressed;

  @override
  StreamSubscription<List<int>> listen(void onData(List<int> event)?,
      {Function? onError, void onDone()?, bool? cancelOnError}) {
    return Stream.fromIterable([_data]).listen(onData,
        onError: onError, onDone: onDone, cancelOnError: cancelOnError);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    return null;
  }
}

class _MockHttpHeaders implements HttpHeaders {
  @override
  dynamic noSuchMethod(Invocation invocation) {
    return null;
  }
}
