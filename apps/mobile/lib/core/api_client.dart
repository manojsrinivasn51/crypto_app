import 'package:dio/dio.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiClient {
  static final Dio dio = Dio(BaseOptions(
    baseUrl: !kIsWeb && Platform.isAndroid ? 'http://10.0.2.2:3000/api' : 'http://localhost:3000/api',
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 3),
  ));
}
