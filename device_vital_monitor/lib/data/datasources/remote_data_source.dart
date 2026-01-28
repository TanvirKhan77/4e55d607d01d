import 'package:device_vital_monitor/core/constants.dart';
import 'package:device_vital_monitor/core/exceptions.dart';
import 'package:device_vital_monitor/data/models/device_vital_model.dart';
import 'package:device_vital_monitor/data/models/analytics_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

abstract class RemoteDataSource {
  Future<void> logVitals(DeviceVitalModel vitals);
  Future<List<DeviceVitalModel>> getHistoricalVitals(String deviceId);
  Future<AnalyticsModel> getAnalytics(String deviceId);
  Future<bool> checkHealth();
}

class RemoteDataSourceImpl implements RemoteDataSource {
  final http.Client client;
  final String baseUrl;

  RemoteDataSourceImpl({
    required this.client,
    this.baseUrl = AppConstants.baseUrl,
  });

  @override
  Future<void> logVitals(DeviceVitalModel vitals) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/api/vitals'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(vitals.toJson()),
      ).timeout(AppConstants.apiTimeout);

      if (response.statusCode == 201) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);

        if (responseBody['success'] != true) {
          throw ApiException(
            responseBody['error'] ?? 'Unknown error',
            response.statusCode,
          );
        }
      } else {
        throw ApiException('Failed to log vitals', response.statusCode);
      }
    } on ApiException {
      rethrow;
    } on http.ClientException catch (e) {
      // Network error - could be offline
      throw ServerException('Network error: ${e.message}');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ServerException('Network error: $e');
    }
  }

  @override
  Future<List<DeviceVitalModel>> getHistoricalVitals(String deviceId) async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/api/vitals?device_id=$deviceId'),
      ).timeout(AppConstants.apiTimeout);

      if (response.statusCode == 200) {
        if (response.body.isEmpty) {
          throw ServerException('Empty response from server');
        }
        
        final Map<String, dynamic> responseBody = jsonDecode(response.body);

        if (responseBody['success'] == true) {
          final List<dynamic> logs = responseBody['logs'] ?? [];
          return logs
              .map((log) => DeviceVitalModel.fromJson(log))
              .toList();
        } else {
          throw ApiException(
            responseBody['error'] ?? 'Unknown error',
            response.statusCode,
          );
        }
      } else {
        throw ApiException('Failed to fetch vitals', response.statusCode);
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      if (e is ServerException) rethrow;
      throw ServerException('Network error: $e');
    }
  }

  @override
  Future<AnalyticsModel> getAnalytics(String deviceId) async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/api/vitals/analytics?device_id=$deviceId'),
      ).timeout(AppConstants.apiTimeout);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);

        if (responseBody['success'] == true) {
          return AnalyticsModel.fromJson(responseBody);
        } else {
          throw ApiException(
            responseBody['error'] ?? 'Unknown error',
            response.statusCode,
          );
        }
      } else {
        throw ApiException('Failed to fetch analytics', response.statusCode);
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ServerException('Network error: $e');
    }
  }

  @override
  Future<bool> checkHealth() async {
    try {
      final response = await client
          .get(Uri.parse('$baseUrl/health'))
          .timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
