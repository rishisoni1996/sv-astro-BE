import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class BaseResponse<T> {
  final int statusCode;
  final String message;
  final T? data;
  final Map<String, dynamic>? errors;

  factory BaseResponse.fromDioResponse(Response response,
      {T Function(Map<String, dynamic>)? mapper,
      T Function(List<dynamic>)? listMapper}) {
    try {
      final dynamic rawData = response.data;

      // Handle array responses directly (e.g., GET /user-interests returns [...])
      if (rawData is List) {
        return BaseResponse(
          statusCode: response.statusCode ?? 500,
          message: "Success",
          data: listMapper != null ? listMapper(rawData) : null,
        );
      }

      // Handle object responses
      Map<String, dynamic> responseData = rawData as Map<String, dynamic>;

      // Determine the data to map:
      // 1. If response has a "data" field, use that
      // 2. Otherwise, use the entire response body (for flat responses)
      dynamic dataToMap;
      if (responseData["data"] != null) {
        dataToMap = responseData["data"];
      } else if (mapper != null) {
        // For flat responses without a "data" wrapper, use the entire response
        dataToMap = responseData;
      } else if (listMapper != null) {
        // For list responses wrapped in an object without "data" field
        dataToMap = responseData;
      }

      // If listMapper is provided but dataToMap is a Map (paginated response),
      // extract the nested "data" list from it
      if (listMapper != null && dataToMap is Map<String, dynamic> && dataToMap["data"] is List) {
        dataToMap = dataToMap["data"];
      }

      return BaseResponse(
          statusCode: response.statusCode ?? 500,
          message: responseData["message"] ?? "Success",
          data: dataToMap != null
              ? mapper != null
                  ? mapper(dataToMap)
                  : listMapper != null
                      ? listMapper(dataToMap)
                      : null
              : null);
    } catch (error, stackTrace) {
      debugPrint('BaseResponse parsing error: $error');
      debugPrint('BaseResponse stack trace: $stackTrace');
      return BaseResponse(
          statusCode: 500, message: "Failure in converting response to model.");
    }
  }

  factory BaseResponse.fromJson(Map<String, dynamic> json) =>
      BaseResponse(statusCode: json["statusCode"], message: json["message"]);

  BaseResponse({required this.statusCode, required this.message, this.data, this.errors});
}
