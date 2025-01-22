import 'dart:convert';
import 'package:http/http.dart' as http;

const String apiUrlLogin = "https://tfte.azurewebsites.net/api/credentials/login/";

class CredentialService {
  Future<http.Response> login(String phone, String pin) async {
    final response = await http.post(
      Uri.parse(apiUrlLogin),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'phone_number': phone,
        'pin': pin,
      }),
    );
    return response;
    
  }
}
