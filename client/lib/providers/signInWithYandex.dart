import 'package:social_auth_example/utils/getAccessToken.dart';

final String _clientId = 'ba99d9fac22646638bce62a902cf2c12';
final String _redirectUri = 'https://yx$_clientId.oauth.yandex.ru/auth/finish';
final _authorizationEndpoint = 'https://oauth.yandex.ru/authorize';
final _tokenEndpoint = 'https://oauth.yandex.ru/token';
final _scopes = ['login:email', 'login:info'];

Future<String?> signInWithYandex() async {
    return await getAccessToken(
        _clientId,
        _redirectUri,
        _authorizationEndpoint,
        _tokenEndpoint,
        _scopes,
    );
}