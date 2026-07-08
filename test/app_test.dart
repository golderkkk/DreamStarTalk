import 'package:flutter_test/flutter_test.dart';
import 'package:dream_startalk/app/app.dart';

void main() {
  group('App', () {
    test('should create app widget', () {
      // Basic test to ensure app can be instantiated
      expect(const AIChatStudioApp(), isNotNull);
    });
  });
}
