import 'package:connectivity_plus/connectivity_plus.dart';

/// Utilidades para manejo de conectividad y reintentos
class ConnectivityUtils {
  static final Connectivity _connectivity = Connectivity();

  /// Verifica si hay conexión a internet
  static Future<bool> hasInternetConnection() async {
    try {
      final result = await _connectivity.checkConnectivity();
      return !result.contains(ConnectivityResult.none);
    } catch (e) {
      return false;
    }
  }

  /// Ejecuta una función con reintentos automáticos
  static Future<T> executeWithRetries<T>(
    Future<T> Function() function, {
    int maxRetries = 3,
    Duration retryDelay = const Duration(seconds: 2),
  }) async {
    int attempt = 0;
    while (attempt < maxRetries) {
      try {
        return await function();
      } catch (e) {
        attempt++;
        if (attempt >= maxRetries) {
          rethrow;
        }
        await Future.delayed(retryDelay);
      }
    }
    throw Exception('Max retries exceeded');
  }

  /// Valida si un string es una URL válida
  static bool isValidUrl(String url) {
    try {
      Uri.parse(url);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Valida el rango de rating (0-10)
  static bool isValidRating(double rating) {
    return rating >= 0 && rating <= 10;
  }

  /// Valida el año
  static bool isValidYear(String year) {
    try {
      final y = int.parse(year);
      return y >= 1900 && y <= DateTime.now().year + 1;
    } catch (e) {
      return false;
    }
  }

  /// Valida que un título no esté vacío
  static bool isValidTitle(String title) {
    return title.isNotEmpty && title.length <= 200;
  }
}
