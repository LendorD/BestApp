class AppConfig {
  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8080/api/v1',
  );

  static const useMockApi = bool.fromEnvironment(
    'USE_MOCK_API',
    defaultValue: true,
  );

  static const defaultDotaAccountId = String.fromEnvironment(
    'DEFAULT_DOTA_ACCOUNT_ID',
    defaultValue: '369102305',
  );
}
