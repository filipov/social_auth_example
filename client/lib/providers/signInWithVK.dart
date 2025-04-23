import 'package:social_auth_example/utils/getAccessToken.dart';

final String _clientId = '53460009'; // '53460008';
final String _redirectUri = 'vk$_clientId://vk.com/blank.html';
final _authorizationEndpoint = 'https://id.vk.com/authorize';
final _tokenEndpoint = 'https://id.vk.com/oauth2/auth';
final _scopes = ['phone', 'email'];

Future<String?> signInWithVK() async {
  return await getAccessToken(
      _clientId,
      _redirectUri,
      _authorizationEndpoint,
      _tokenEndpoint,
      _scopes,
  );
}