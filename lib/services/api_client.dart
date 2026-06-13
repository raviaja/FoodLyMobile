import 'package:dio/dio.dart';

class ApiClient {
  static final Dio dio = Dio(
    BaseOptions(
      // Menggunakan IPv4 dari koneksi Wi-Fi Anda
      baseUrl: 'https://foodly-backend-5mci.onrender.com/api/', 
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );
}