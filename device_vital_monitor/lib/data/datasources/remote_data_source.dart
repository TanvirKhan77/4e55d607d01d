import 'package:device_vital_monitor/core/constants.dart';
import 'package:device_vital_monitor/core/exceptions.dart';
import 'package:device_vital_monitor/data/models/device_vital_model.dart';
import 'package:device_vital_monitor/data/models/analytics_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Abstract class: Defines contract for remote data source operations
abstract class RemoteDataSource {
  Future<void> logVitals(DeviceVitalModel vitals); // Method: Log device vitals to remote server
  Future<List<DeviceVitalModel>> getHistoricalVitals(String deviceId); // Method: Fetch historical vitals for a device
  Future<AnalyticsModel> getAnalytics(String deviceId); // Method: Fetch analytics data for a device
  Future<bool> checkHealth(); // Method: Check health status of the remote server
}

// Implementation class: Concrete remote data source
class RemoteDataSourceImpl implements RemoteDataSource {
  final http.Client client; // Dependency: HTTP client for making requests
  final String baseUrl; // Base URL for the remote API

  // Constructor: Requires HTTP client and optional base URL
  RemoteDataSourceImpl({
    required this.client, // HTTP client instance
    this.baseUrl = AppConstants.baseUrl, // Default base URL
  });

  // Implementation: Log device vitals to remote server
  @override
  Future<void> logVitals(DeviceVitalModel vitals) async {
    try {
      // Make POST request to log vitals
      final response = await client.post(
        Uri.parse('$baseUrl/api/vitals'), // API endpoint
        headers: {'Content-Type': 'application/json'}, // Set content type to JSON
        body: jsonEncode(vitals.toJson()), // Convert vitals to JSON
      ).timeout(AppConstants.apiTimeout); // Set request timeout

      // Check for successful response
      if (response.statusCode == 201) {
        // Parse response body
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        
        // Verify success flag in response
        if (responseBody['success'] != true) {
          throw ApiException(
            responseBody['error'] ?? 'Unknown error', // Error message from server
            response.statusCode, // HTTP status code
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

  // Implementation: Fetch historical vitals for a device
  @override
  Future<List<DeviceVitalModel>> getHistoricalVitals(String deviceId) async {
    try {
      // Make GET request to fetch historical vitals
      final response = await client.get(
        Uri.parse('$baseUrl/api/vitals?device_id=$deviceId'),
      ).timeout(AppConstants.apiTimeout); // Set request timeout

      // Check for successful response
      if (response.statusCode == 200) {
        if (response.body.isEmpty) {
          throw ServerException('Empty response from server');
        }
        
        // Parse response body
        final Map<String, dynamic> responseBody = jsonDecode(response.body);

        // Verify success flag in response
        if (responseBody['success'] == true) {
          final List<dynamic> logs = responseBody['logs'] ?? []; // Extract logs
          return logs
              .map((log) => DeviceVitalModel.fromJson(log))
              .toList(); // Convert logs to list of DeviceVitalModel
        } else {
          throw ApiException(
            responseBody['error'] ?? 'Unknown error',
            response.statusCode, // HTTP status code
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

  // Implementation: Fetch analytics data for a device
  @override
  Future<AnalyticsModel> getAnalytics(String deviceId) async {
    try {
      // Make GET request to fetch analytics data
      final response = await client.get(
        Uri.parse('$baseUrl/api/vitals/analytics?device_id=$deviceId'),
      ).timeout(AppConstants.apiTimeout); // Set request timeout

      // Check for successful response
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body); // Parse response body

        // Verify success flag in response
        if (responseBody['success'] == true) {
          // Convert response to AnalyticsModel
          return AnalyticsModel.fromJson(responseBody);
        } else {
          // Handle API error response
          throw ApiException(
            responseBody['error'] ?? 'Unknown error', // Error message from server
            response.statusCode, // HTTP status code
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

  // Implementation: Check health status of the remote server
  @override
  Future<bool> checkHealth() async {
    try {
      final response = await client
          .get(Uri.parse('$baseUrl/health'))
          .timeout(const Duration(seconds: 5)); // Set timeout
      return response.statusCode == 200; // Return true if server is healthy
    } catch (_) {
      return false; // On error, consider server unhealthy
    }
  }
}
