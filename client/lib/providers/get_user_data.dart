import 'package:http/http.dart' as http;

const API_URL = String.fromEnvironment('BASE_API_URL');

Future<String?> getUserData (String provider, String accessToken, String clientId) async {
  final userDataResponse = await http.post(
    Uri.parse('$API_URL/auth/$provider'),
    body: {
      'accessToken': accessToken,
      'clientId': clientId,
    },
  );

  return userDataResponse.body;
}