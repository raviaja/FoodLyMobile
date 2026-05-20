import 'package:dio/dio.dart';

class ApiClient {
  static final Dio dio = Dio(
    BaseOptions(
      // Menggunakan IPv4 dari koneksi Wi-Fi Anda
      baseUrl: 'http://192.168.18.162:8000/api', 
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );
}