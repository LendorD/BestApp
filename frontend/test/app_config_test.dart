import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/config/app_config.dart';

void main() {
  test('uses mock API by default', () {
    expect(AppConfig.useMockApi, isTrue);
  });
}
