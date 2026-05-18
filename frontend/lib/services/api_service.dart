import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

String getBaseUrl() {
  return "http://127.0.0.1:8000";
}

String _parseError(dynamic error) {
  if (error is String) return error;

  if (error is List && error.isNotEmpty) {
    final first = error.first;
    if (first is Map && first["msg"] != null) {
      return first["msg"].toString();
    }
    return error.toString();
  }

  if (error is Map && error["msg"] != null) {
    return error["msg"].toString();
  }

  return "Something went wrong";
}

class ApiService {
  static final String baseUrl = getBaseUrl();

  // ---------------- LOGIN ----------------
  static Future<Map<String, dynamic>> login({
    required String phone,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/login"),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({
          "phone": phone.trim(),
          "password": password.trim(),
        }),
      );

      if (response.statusCode == 200) {
        return {"success": true};
      }

      final data = jsonDecode(response.body);
      return {
        "success": false,
        "message": _parseError(data["detail"]),
      };
    } catch (e) {
      return {
        "success": false,
        "message": "Unable to connect to server",
      };
    }
  }

  // ---------------- SIGNUP ----------------
  static Future<Map<String, dynamic>> signup({
    required String name,
    required String phone,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/signup"),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({
          "name": name.trim(),
          "phone": phone.trim(),
          "password": password.trim(),
        }),
      );

      if (response.statusCode == 200) {
        return {"success": true};
      }

      final data = jsonDecode(response.body);
      return {
        "success": false,
        "message": _parseError(data["detail"]),
      };
    } catch (_) {
      return {
        "success": false,
        "message": "Unable to connect to server",
      };
    }
  }

  // ---------------- FETCH PROFILE ----------------
  static Future<Map<String, dynamic>> fetchProfile(String phone) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/profile/$phone"),
        headers: {"Accept": "application/json"},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          "success": true,
          "name": data["name"],
          "phone": data["phone"],
          "language": data["language"] ?? "en",
        };
      }

      final data = jsonDecode(response.body);
      return {
        "success": false,
        "message": _parseError(data["detail"]),
      };
    } catch (_) {
      return {
        "success": false,
        "message": "Unable to connect to server",
      };
    }
  }

  // ---------------- UPDATE PROFILE ----------------
  static Future<Map<String, dynamic>> updateProfile({
    required String phone,
    required String name,
    required String language,
  }) async {
    try {
      final response = await http.put(
        Uri.parse("$baseUrl/profile/$phone"),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({
          "name": name.trim(),
          "language": language,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          "success": true,
          "name": data["name"],
          "language": data["language"],
        };
      }

      final data = jsonDecode(response.body);
      return {
        "success": false,
        "message": _parseError(data["detail"]),
      };
    } catch (_) {
      return {
        "success": false,
        "message": "Unable to connect to server",
      };
    }
  }

  // ---------------- CHANGE PASSWORD ----------------
  static Future<Map<String, dynamic>> changePassword({
    required String phone,
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final response = await http.put(
        Uri.parse("$baseUrl/profile/$phone/change-password"),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({
          "current_password": currentPassword.trim(),
          "new_password": newPassword.trim(),
        }),
      );

      if (response.statusCode == 200) {
        return {"success": true};
      }

      final data = jsonDecode(response.body);
      return {
        "success": false,
        "message": _parseError(data["detail"]),
      };
    } catch (_) {
      return {
        "success": false,
        "message": "Unable to connect to server",
      };
    }
  }
  // ---------------- CHAT ----------------
  static Future<Map<String, dynamic>> sendMessage({
    required String phone,
    required String message,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/chat"),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({
          "phone": phone,
          "message": message,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          "success": true,
          "reply": data["reply"],
        };
      }

      return {
        "success": false,
        "message": "Server error",
      };
    } catch (_) {
      return {
        "success": false,
        "message": "Unable to connect to server",
      };
    }
  }
  // ---------------- CROP RECOMMENDATION ----------------
  static Future<Map<String, dynamic>> recommendCrop({
    required String phone,
    required double N,
    required double P,
    required double K,
    required double temperature,
    required double humidity,
    required double ph,
    required double rainfall,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/recommend-crop"),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({
          "phone": phone,
          "N": N,
          "P": P,
          "K": K,
          "temperature": temperature,
          "humidity": humidity,
          "ph": ph,
          "rainfall": rainfall
        }),
      );

      if (response.statusCode == 200) {
        return {
          "success": true,
          "data": jsonDecode(response.body)
        };
      }

      if (response.statusCode == 422) {
        try {
          final data = jsonDecode(response.body);
          if (data["detail"] is List && data["detail"].isNotEmpty) {
            final errors = (data["detail"] as List).map((e) {
              final field = e["loc"]?.last ?? "field";
              final msg = e["msg"] ?? "Invalid value";
              return "$field: $msg";
            }).join(", ");
            return {
              "success": false,
              "message": "Validation error: $errors"
            };
          }
        } catch (_) {}
      }

      return {
        "success": false,
        "message": "Server error"
      };
    } catch (_) {
      return {
        "success": false,
        "message": "Unable to connect to server"
      };
    }
  }
  static Future<List<String>> searchCommodities(String query) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/market/commodities?q=$query"),
        headers: {
          "Accept": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final List results = data["results"] ?? [];

        return results.map((e) => e.toString()).toList();
      }

      return [];
    } catch (_) {
      return [];
    }
  }
  static Future<Map<String, dynamic>> fetchMarketPrices({
    required String commodity,
    required String state,
  }) async {
    try {
      final response = await http
          .get(
            Uri.parse(
              "$baseUrl/market/prices?commodity=${Uri.encodeComponent(commodity)}&state=${Uri.encodeComponent(state)}",
            ),
            headers: {"Accept": "application/json"},
          )
          .timeout(const Duration(seconds: 120));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }

      return {"success": false, "message": "Unable to fetch prices"};
    } catch (_) {
      return {"success": false, "message": "Server unavailable"};
    }
  }
}
