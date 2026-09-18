final class ApiConfig {
  const ApiConfig._();

  static const String baseUrl = String.fromEnvironment(
    'URL_API_UPT',
    defaultValue: 'https://api-moviles.fottuto.men/api',
  );
}
