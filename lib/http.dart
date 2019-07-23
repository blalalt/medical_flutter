import 'package:dio/dio.dart';

BaseOptions options = new BaseOptions(
    baseUrl: "http://192.168.2.132:6666/api",
//    connectTimeout: 5000,
//    receiveTimeout: 3000,
);
Dio dio = new Dio(options);


