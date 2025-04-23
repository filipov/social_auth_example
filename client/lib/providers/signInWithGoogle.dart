import '../utils/getAccessToken.dart';

final String _id = '18792754679-f5bso8tvtga9n5ga8aiofhj63k7eotc9';

final String _clientId = '$_id.apps.googleusercontent.com';
final String _redirectUri = 'com.googleusercontent.apps.$_id:/oauth2redirect';
final _authorizationEndpoint = 'https://accounts.google.com/o/oauth2/v2/auth';
final _tokenEndpoint = 'https://oauth2.googleapis.com/token';
final _scopes = ['openid', 'email', 'profile'];

Future<String?> signInWithGoogle() async {
  return await getAccessToken(
    _clientId,
    _redirectUri,
    _authorizationEndpoint,
    _tokenEndpoint,
    _scopes,
  );
}