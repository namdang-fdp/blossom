enum AppEnvironment { dev, staging }

class AppConfig {
  const AppConfig(this.environment);

  factory AppConfig.fromFlavor(String? flavor) => switch (flavor) {
    'dev' => const AppConfig(AppEnvironment.dev),
    'staging' => const AppConfig(AppEnvironment.staging),
    _ => throw ArgumentError.value(flavor, 'flavor', 'Use dev or staging'),
  };

  final AppEnvironment environment;

  String get appName => switch (environment) {
    AppEnvironment.dev => 'Nở Dev',
    AppEnvironment.staging => 'Nở Staging',
  };
}
