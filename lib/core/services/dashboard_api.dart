import 'package:flutter/material.dart';
import 'package:insight_hub/model/app_error.dart';
import 'package:insight_hub/core/services/api_service.dart';

class DashboardApi {
  final ApiService _apiService;

  DashboardApi({ApiService? apiService}) : _apiService = apiService ?? ApiService();

  /// Fetches JSON from API and handles all errors (network, invalid JSON, nulls).
  // ignore: unintended_html_in_doc_comment
  /// Always returns a safe List<Map<String, dynamic>> (never null).
Future<List<Map<String, dynamic>>> fetchDashboardData(String endpoint) async {
  try {
    final response = await _apiService.get(endpoint);

    if (response['success'] != true) {
      final errorData = response['data'];
      if (errorData is Map<String, dynamic>) {
        debugPrint("Dashboard Error: ${AppError.fromJson(errorData).getErrorMessage()}");
      } else {
        debugPrint("Dashboard Error: ${response['error']}");
      }
      return [];
    }

    /// response['data'] = { "status": "success", "data": { ... } }
    final body = response['data'];
    if (body is! Map<String, dynamic>) return [];

    final dashboardMap = body['data'];
    if (dashboardMap is! Map<String, dynamic>) return [];

    return dashboardMap.entries.map((entry) {
      final value = entry.value;
      if (value is! Map<String, dynamic>) return <String, dynamic>{};

      return <String, dynamic>{
        'id': entry.key,
        'title': value['title'] ?? entry.key,
        'type': value['type'] ?? 'unknown',
        'objective': value['objective'] ?? '',
        'description': value['description'] ?? '',
        'data': value, // 🔥 pass full map
      };
    }).where((e) => e.isNotEmpty).toList();

  } catch (e) {
    debugPrint("Dashboard Crash: $e");
    return [];
  }
}}