import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../config/app_config.dart';

class HttpClientService {
  static HttpClientService? _instance;
  static HttpClientService get instance => _instance ??= HttpClientService._();
  
  HttpClientService._();

  Map<String, String> get _defaultHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  Future<http.Response> get(String url, {Map<String, String>? headers}) async {
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {..._defaultHeaders, ...?headers},
      ).timeout(Duration(seconds: AppConfig.syncTimeoutSeconds));
      
      if (kDebugMode) {
        print('GET $url - Status: ${response.statusCode}');
      }
      
      return response;
    } catch (e) {
      if (kDebugMode) {
        print('GET $url - Error: $e');
      }
      rethrow;
    }
  }

  Future<http.Response> post(String url, {
    Map<String, String>? headers,
    dynamic body,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {..._defaultHeaders, ...?headers},
        body: body is String ? body : json.encode(body),
      ).timeout(Duration(seconds: AppConfig.syncTimeoutSeconds));
      
      if (kDebugMode) {
        print('POST $url - Status: ${response.statusCode}');
      }
      
      return response;
    } catch (e) {
      if (kDebugMode) {
        print('POST $url - Error: $e');
      }
      rethrow;
    }
  }

  Future<bool> checkConnectivity(String healthUrl) async {
    try {
      final response = await get(healthUrl);
      return response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) {
        print('Connectivity check failed: $e');
      }
      return false;
    }
  }
}