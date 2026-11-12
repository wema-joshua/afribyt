// repositories/request_repository.dart

import 'dart:convert';
import 'package:http/http.dart' as http;

import '../services/auth_service.dart';

class RequestRepository {
  final AuthService authService = AuthService();

  static const String _baseUrl =
      'https://bytly-backend.onrender.com';

  /// SUBMIT A SERVICE BOOKING
  
  /// [payload] 
 
  Future<Map<String, dynamic>> submitBooking(
    Map<String, dynamic> payload,
  ) async {
    try {
      final token = await authService.getToken();

      if (token == null || token.isEmpty) {
        return {
          'success': false,
          'sessionExpired': true,
          'message': 'Session expired — please log in again',
        };
      }

      final response = await http.post(
        Uri.parse('$_baseUrl/api/request-service'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'message': 'Booking confirmed',
          'data': jsonDecode(response.body),
        };
      }

      if (response.statusCode == 401) {
        return {
          'success': false,
          'sessionExpired': true,
          'message': 'Session expired — please log in again',
        };
      }

      
      String? serverMessage;
      try {
        final decoded = jsonDecode(response.body);
        serverMessage = decoded is Map ? decoded['message'] as String? : null;
      } catch (_) {
        // response body wasn't JSON - fall through to the generic message
      }

      return {
        'success': false,
        'message': serverMessage ?? 'Something went wrong. Please try again.',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error — check your connection',
        'error': e.toString(),
      };
    }
  }

  /// =========================
  /// GET MY BOOKING REQUESTS
  /// =========================
  Future<List<Map<String, dynamic>>?> getMyRequests() async {
    try {
      final token = await authService.getToken();

      if (token == null || token.isEmpty) {
        return null;
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/api/my-requests'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode != 200) {
        return null;
      }

      final decoded = jsonDecode(response.body);
      if (decoded is List) {
        return decoded.cast<Map<String, dynamic>>();
      }
      return null;
    } catch (e) {
      print('GET MY REQUESTS ERROR');
      return null;
    }
  }
}
