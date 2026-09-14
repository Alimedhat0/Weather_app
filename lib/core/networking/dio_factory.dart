import 'package:dio/dio.dart';
import 'package:flutter_application_1/core/networking/api_constant.dart';

class DioFactory {
  DioFactory._();

  static late Dio dio;

  static void init() {
    dio = Dio(
      BaseOptions(
        baseUrl: ApiConstant.baseUrl,
        queryParameters: {'key': ApiConstant.apiKey, 'q': 'Cairo'},
        connectTimeout: Duration(seconds: 60),
        receiveTimeout: Duration(seconds: 60),
        sendTimeout: Duration(seconds: 60),
      ),
    );
  }

  static Future<Response<dynamic>> getData(
    String endpoint,
    Map<String, dynamic> queryParameters,
  ) async {
    final response = await dio.get(endpoint, queryParameters: queryParameters);
    return response;
  }
}
