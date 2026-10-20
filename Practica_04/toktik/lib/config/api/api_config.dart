import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  const ApiConfig._();

  static String get coverrApiKey => dotenv.env['COVERR_API_KEY'] ?? '';
  static String get pixabayApiKey => dotenv.env['PIXABAY_API_KEY'] ?? '';
}
