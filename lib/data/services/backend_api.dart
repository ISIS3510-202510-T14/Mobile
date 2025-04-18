import 'dart:convert';
import 'package:http/http.dart' as http;

class BackendApi {
  static const _base = 'http://localhost:8000/api';

  /// POST /users      (used at sign‑up)
  static Future<void> registerUser({
    required String uid,
    required String email,
    String? name,
    String? phone,
  }) async {
    final res = await http.post(
      Uri.parse('$_base/users'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'user_id': uid,
        'email' : email,
        'name'  : name,
        'phone' : phone,
        'balance': 0,
      }),
    );
    if (res.statusCode != 201) {
      throw Exception('Backend registration failed: ${res.body}');
    }
  }

  /// GET /auth/login?uid=<uid>   (used at sign‑in)
  /// • 200 OK  → user exists ‑ continue
  /// • 404     → uid not found ‑ treat as login error
  static Future<void> verifyLogin(String uid) async {
    final res = await http
        .get(Uri.parse('$_base/auth/login').replace(queryParameters: {'uid': uid}));
    if (res.statusCode == 200) return;
    throw Exception('User does not exist in backend');
  }
}
