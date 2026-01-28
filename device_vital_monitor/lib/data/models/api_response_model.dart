class ApiResponseModel<T> {
  final bool success;
  final T? data;
  final String? error;
  final int? statusCode;

  ApiResponseModel({
    required this.success,
    this.data,
    this.error,
    this.statusCode,
  });

  factory ApiResponseModel.fromJson(Map<String, dynamic> json, T Function(dynamic) fromJsonT) {
    return ApiResponseModel<T>(
      success: json['success'] ?? false,
      data: json['data'] != null ? fromJsonT(json['data']) : null,
      error: json['error'],
      statusCode: json['statusCode'],
    );
  }

  Map<String, dynamic> toJson(dynamic Function(T) toJsonT) {
    return {
      'success': success,
      'data': data != null ? toJsonT(data as T) : null,
      'error': error,
      'statusCode': statusCode,
    };
  }
}
