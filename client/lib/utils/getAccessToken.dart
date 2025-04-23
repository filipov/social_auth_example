import 'dart:convert';

import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:http/http.dart' as http;

Map<String, String> convertToMapString(Map<String, dynamic> input) {
  return input.map((key, value) => MapEntry(key, value?.toString() ?? ''));
}

final _appAuth = FlutterAppAuth();

Future<String?> getAccessToken (
  String clientId,
  String redirectUri,
  String authorizationEndpoint,
  String tokenEndpoint,
  List<String>? scopes,
) async {
  final configuration = AuthorizationServiceConfiguration(
    authorizationEndpoint: authorizationEndpoint,
    tokenEndpoint: tokenEndpoint,
  );

  try {
    final authRequest = AuthorizationRequest(
      clientId,
      redirectUri,
      serviceConfiguration: configuration,
      scopes: scopes,
    );

    final authResult = await _appAuth.authorize(authRequest);

    final additionalParameters = convertToMapString(authResult.authorizationAdditionalParameters!);

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

    final accessToken = jsonDecode(tokenResponse.body)['access_token'];

    return accessToken;
  } catch (e) {
    return null;
  }
}