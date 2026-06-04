import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/item.dart';

class ApiService {
  static String baseUrl = 'http://10.0.2.2:3000/api';
  static const String webLocalUrl = 'http://localhost:3000/api';

  static Future<String> getResolvedUrl() async {
    return baseUrl;
  }

  static Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/auth/login');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'password': password}),
      ).timeout(const Duration(seconds: 5));

      return json.decode(response.body) as Map<String, dynamic>;
    } catch (e) {
      try {
        final altResponse = await http.post(
          Uri.parse('$webLocalUrl/auth/login'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'email': email, 'password': password}),
        ).timeout(const Duration(seconds: 3));

        baseUrl = webLocalUrl;
        return json.decode(altResponse.body) as Map<String, dynamic>;
      } catch (_) {
        return {
          'success': false,
          'message': 'Failed to connect to Teyvat backend server: $e'
        };
      }
    }
  }

  static Future<Map<String, dynamic>> register(String name, String email, String password) async {
    final url = Uri.parse('$baseUrl/auth/register');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'name': name, 'email': email, 'password': password}),
      ).timeout(const Duration(seconds: 5));

      return json.decode(response.body) as Map<String, dynamic>;
    } catch (e) {
      try {
        final altResponse = await http.post(
          Uri.parse('$webLocalUrl/auth/register'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'name': name, 'email': email, 'password': password}),
        ).timeout(const Duration(seconds: 3));

        baseUrl = webLocalUrl;
        return json.decode(altResponse.body) as Map<String, dynamic>;
      } catch (_) {
        return {
          'success': false,
          'message': 'Failed to connect to Teyvat backend server: $e'
        };
      }
    }
  }

  static Future<Map<String, dynamic>> loginWithGoogle(String idToken, String email, String name) async {
    final url = Uri.parse('$baseUrl/auth/oauth');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'provider': 'Google',
          'idToken': idToken,
          'email': email,
          'name': name,
        }),
      ).timeout(const Duration(seconds: 10));

      return json.decode(response.body) as Map<String, dynamic>;
    } catch (e) {
      try {
        final altResponse = await http.post(
          Uri.parse('$webLocalUrl/auth/oauth'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'provider': 'Google',
            'idToken': idToken,
            'email': email,
            'name': name,
          }),
        ).timeout(const Duration(seconds: 8));

        baseUrl = webLocalUrl;
        return json.decode(altResponse.body) as Map<String, dynamic>;
      } catch (_) {
        return {
          'success': false,
          'message': 'Failed to connect to Teyvat backend server: $e'
        };
      }
    }
  }

  static Future<List<Item>> getItems() async {
    final url = Uri.parse('$baseUrl/items');
    try {
      final response = await http.get(url).timeout(const Duration(seconds: 5));
      final decoded = json.decode(response.body) as Map<String, dynamic>;

      if (decoded['success'] == true) {
        final list = decoded['data'] as List;
        return list.map((itemJson) => Item.fromJson(itemJson)).toList();
      } else {
        throw Exception(decoded['message'] ?? 'Failed to retrieve items.');
      }
    } catch (e) {
      throw Exception('Server unreachable: $e');
    }
  }

  static Future<Item> getItemDetails(int id) async {
    final url = Uri.parse('$baseUrl/items/$id');
    try {
      final response = await http.get(url).timeout(const Duration(seconds: 5));
      final decoded = json.decode(response.body) as Map<String, dynamic>;

      if (decoded['success'] == true) {
        return Item.fromJson(decoded['data']);
      } else {
        throw Exception(decoded['message'] ?? 'Failed to retrieve item details.');
      }
    } catch (e) {
      throw Exception('Server unreachable: $e');
    }
  }

  static Future<Map<String, dynamic>> createItem(String token, Map<String, dynamic> itemData) async {
    final url = Uri.parse('$baseUrl/items');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
        body: json.encode(itemData),
      ).timeout(const Duration(seconds: 5));

      return json.decode(response.body) as Map<String, dynamic>;
    } catch (e) {
      return {'success': false, 'message': 'Network Error: $e'};
    }
  }

  static Future<Map<String, dynamic>> updateItem(String token, int id, Map<String, dynamic> itemData) async {
    final url = Uri.parse('$baseUrl/items/$id');
    try {
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
        body: json.encode(itemData),
      ).timeout(const Duration(seconds: 5));

      return json.decode(response.body) as Map<String, dynamic>;
    } catch (e) {
      return {'success': false, 'message': 'Network Error: $e'};
    }
  }

  static Future<Map<String, dynamic>> deleteItem(String token, int id) async {
    final url = Uri.parse('$baseUrl/items/$id');
    try {
      final response = await http.delete(
        url,
        headers: {
          'Authorization': 'Bearer $token'
        },
      ).timeout(const Duration(seconds: 5));

      return json.decode(response.body) as Map<String, dynamic>;
    } catch (e) {
      return {'success': false, 'message': 'Network Error: $e'};
    }
  }

  static Future<Map<String, dynamic>> buyItems(String token, List<Map<String, dynamic>> cart) async {
    final url = Uri.parse('$baseUrl/items/buy');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
        body: json.encode({'cart': cart}),
      ).timeout(const Duration(seconds: 5));

      return json.decode(response.body) as Map<String, dynamic>;
    } catch (e) {
      return {'success': false, 'message': 'Network Checkout Error: $e'};
    }
  }

  static Future<Map<String, dynamic>> uploadImage(List<int> bytes, String filename) async {
    final url = Uri.parse('$baseUrl/items/upload');
    try {
      final request = http.MultipartRequest('POST', url);
      request.files.add(
        http.MultipartFile.fromBytes(
          'image',
          bytes,
          filename: filename,
        ),
      );

      final streamedResponse = await request.send().timeout(const Duration(seconds: 10));
      final response = await http.Response.fromStream(streamedResponse);
      return json.decode(response.body) as Map<String, dynamic>;
    } catch (e) {
      try {
        final request = http.MultipartRequest('POST', Uri.parse('$webLocalUrl/items/upload'));
        request.files.add(
          http.MultipartFile.fromBytes(
            'image',
            bytes,
            filename: filename,
          ),
        );
        final streamedResponse = await request.send().timeout(const Duration(seconds: 10));
        final response = await http.Response.fromStream(streamedResponse);
        return json.decode(response.body) as Map<String, dynamic>;
      } catch (_) {
        return {'success': false, 'message': 'Upload Error: $e'};
      }
    }
  }
}
