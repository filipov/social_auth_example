import 'dart:convert';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:http/http.dart' as http;

final _appAuth = FlutterAppAuth();

// Вспомогательная функция для преобразования Map<String, dynamic> в Map<String, String>
Map<String, String> _convertToMapString(Map<String, dynamic> input) {
  return input.map((key, value) => MapEntry(key, value?.toString() ?? ''));
}

/// Класс для обработки OAuth 2.0 аутентификации через различные провайдеры.
///
/// Предоставляет методы для получения access token с использованием authorization code flow.
/// Содержит предустановленные конфигурации для Google, VK и Yandex.
class OAuthSignIn {
  final String _clientId;
  final String _redirectUri;
  final String _authorizationEndpoint;
  final String _tokenEndpoint;
  final List<String> _scopes;

  String get clientId => _clientId;

  /// Создает экземпляр OAuthSignIn с кастомной конфигурацией
  ///
  /// [clientId]: Идентификатор клиента, выданный сервером авторизации
  /// [redirectUri]: URI перенаправления, зарегистрированный у провайдера
  /// [authorizationEndpoint]: URL эндпоинта авторизации
  /// [tokenEndpoint]: URL эндпоинта для обмена токенов
  /// [scopes]: Запрашиваемые разрешения (scopes)
  OAuthSignIn({
    required clientId,
    required redirectUri,
    required authorizationEndpoint,
    required tokenEndpoint,
    required scopes,
  })  : _clientId = clientId,
        _redirectUri = redirectUri,
        _authorizationEndpoint = authorizationEndpoint,
        _tokenEndpoint = tokenEndpoint,
        _scopes = scopes;

  /// Создает предустановленную конфигурацию для Google
  ///
  /// Требует переменную окружения GOOGLE_APP_ID с числовым ID приложения
  /// Использует стандартные эндпоинты Google и базовые scopes
  static OAuthSignIn forGoogle() {
    const String _id = String.fromEnvironment('GOOGLE_APP_ID');

    return OAuthSignIn(
      clientId: '$_id.apps.googleusercontent.com',
      redirectUri: 'com.googleusercontent.apps.$_id:/oauth2redirect',
      authorizationEndpoint: 'https://accounts.google.com/o/oauth2/v2/auth',
      tokenEndpoint: 'https://oauth2.googleapis.com/token',
      scopes: ['openid', 'email', 'profile'],
    );
  }

  /// Создает предустановленную конфигурацию для ВКонтакте
  ///
  /// Требует переменную окружения VK_CLIENT_ID с ID приложения VK
  /// Использует эндпоинты VK и scope для доступа к email
  static OAuthSignIn forVk() {
    const String clientId = String.fromEnvironment('VK_CLIENT_ID');

    return OAuthSignIn(
      clientId: clientId,
      redirectUri: 'vk$clientId://vk.com/blank.html',
      authorizationEndpoint: 'https://id.vk.com/authorize',
      tokenEndpoint: 'https://id.vk.com/oauth2/auth',
      scopes: ['email'],
    );
  }

  /// Создает предустановленную конфигурацию для Яндекс
  ///
  /// Требует переменную окружения YA_CLIENT_ID с ID приложения Яндекса
  /// Использует эндпоинты Яндекс OAuth и базовые scopes
  static OAuthSignIn forYandex() {
    const String clientId = String.fromEnvironment('YA_CLIENT_ID');

    return OAuthSignIn(
      clientId: clientId,
      redirectUri: 'yx$clientId:/auth/finish',
      authorizationEndpoint: 'https://oauth.yandex.ru/authorize',
      tokenEndpoint: 'https://oauth.yandex.ru/token',
      scopes: ['login:email', 'login:info'],
    );
  }

  /// Выполняет OAuth 2.0 авторизацию для получения access token
  ///
  /// Возвращает [String] access token при успехе или null при ошибке
  /// Обрабатывает весь процесс:
  /// 1. Запрос авторизации через браузер
  /// 2. Обмен кода авторизации на токен
  /// 3. Извлечение access token из ответа
  ///
  /// Логирует ошибки в консоль при возникновении исключений
  Future<String?> getAccessToken() async {
    final configuration = AuthorizationServiceConfiguration(
      authorizationEndpoint: _authorizationEndpoint,
      tokenEndpoint: _tokenEndpoint,
    );

    try {
      // Инициализация запроса авторизации
      final authRequest = AuthorizationRequest(
        _clientId,
        _redirectUri,
        serviceConfiguration: configuration,
        scopes: _scopes,
        externalUserAgent: ExternalUserAgent.asWebAuthenticationSession,
      );

      // Запуск процесса авторизации
      final authResult = await _appAuth.authorize(authRequest);

      // Подготовка параметров для запроса токена
      final additionalParameters =
      _convertToMapString(authResult.authorizationAdditionalParameters!);

      // Отправка запроса на получение токена
      final tokenResponse = await http.post(
        Uri.parse(configuration.tokenEndpoint),
        body: {
          ...additionalParameters,
          'code': authResult.authorizationCode,
          'code_verifier': authResult.codeVerifier,
          'client_id': authRequest.clientId,
          'redirect_uri': authRequest.redirectUrl,
          'grant_type': 'authorization_code',
        },
      );

      // Парсинг ответа с токеном
      final Map<String, dynamic> data = jsonDecode(tokenResponse.body);
      final accessToken = data['access_token'];

      return accessToken;
    } catch (e) {
      print('Ошибка OAuth аутентификации: $e');
      return null;
    }
  }
}