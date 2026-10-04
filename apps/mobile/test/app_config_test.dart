import 'package:flutter_test/flutter_test.dart';
import 'package:no_mobile/core/config/app_config.dart';

void main() {
  test('dev and staging resolve to distinct environments', () {
    final dev = AppConfig.fromFlavor('dev');
    final staging = AppConfig.fromFlavor('staging');
    expect(dev.environment, AppEnvironment.dev);
    expect(staging.environment, AppEnvironment.staging);
    expect(dev.appName, isNot(staging.appName));
  });

  test('missing or unknown flavor never silently falls back', () {
    for (final flavor in [null, '', 'production']) {
      expect(() => AppConfig.fromFlavor(flavor), throwsArgumentError);
    }
  });
}
