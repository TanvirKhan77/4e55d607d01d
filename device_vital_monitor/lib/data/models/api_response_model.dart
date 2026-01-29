// Model class: Generic API response model
class ApiResponseModel<T> {
  final bool success;
  final T? data;
  final String? error;
  final int? statusCode;

  // Constructor
  ApiResponseModel({
    required this.success,
    this.data,
    this.error,
    this.statusCode,
  });

  // Factory constructor: Create ApiResponseModel from JSON
  factory ApiResponseModel.fromJson(Map<String, dynamic> json, T Function(dynamic) fromJsonT) {
    return ApiResponseModel<T>(
      success: json['success'] ?? false,
      data: json['data'] != null ? fromJsonT(json['data']) : null,
      error: json['error'],
      statusCode: json['statusCode'],
    );
  }

  // Method: Convert ApiResponseModel to JSON
  Map<String, dynamic> toJson(dynamic Function(T) toJsonT) {
    return {
      'success': success,
      'data': data != null ? toJsonT(data as T) : null,
      'error': error,
      'statusCode': statusCode,
    };
  }
}
