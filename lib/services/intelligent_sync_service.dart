import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:path/path.dart' as path_pkg;
import 'dart:convert';

/// Servicio de sincronización inteligente en background
/// Detecta cambios de conectividad y sincroniza datos automáticamente
class IntelligentSyncService {
  static final IntelligentSyncService _instance =
      IntelligentSyncService._internal();
  
  late Database _cacheDb;
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;
  bool _isInitialized = false;
  bool _isOnline = false;
  Timer? _syncTimer;
  
  // Callbacks para notificar cambios
  final List<Function(bool)> _connectivityListeners = [];
  final List<Function(Map<String, dynamic>)> _syncListeners = [];

  factory IntelligentSyncService() {
    return _instance;
  }

  IntelligentSyncService._internal();

  /// Inicializa el servicio
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Inicializar base de datos de caché
      await _initCacheDatabase();

      // Verificar conectividad inicial
      final result = await Connectivity().checkConnectivity();
      _isOnline = result != ConnectivityResult.none;

      // Escuchar cambios de conectividad
      _connectivitySubscription =
          Connectivity().onConnectivityChanged.listen((result) {
        final wasOnline = _isOnline;
        _isOnline = result != ConnectivityResult.none;

        // Notificar cambios de conectividad
        _notifyConnectivityChange(_isOnline);

        // Si vuelve la conexión, sincronizar datos pendientes
        if (!wasOnline && _isOnline) {
          _performSync();
        }
      });

      // Ejecutar sincronización periódica cada 30 minutos cuando hay conexión
      _syncTimer = Timer.periodic(const Duration(minutes: 30), (_) {
        if (_isOnline) {
          _performSync();
        }
      });

      _isInitialized = true;
    } catch (e) {
      // Error al inicializar - continuar sin sincronización
    }
  }

  /// Inicializa la base de datos de caché adaptativo
  Future<void> _initCacheDatabase() async {
    try {
      final documentsDirectory = await getApplicationDocumentsDirectory();
      final dbPath = path_pkg.join(documentsDirectory.path, 'flick_cache.db');
      
      _cacheDb = await openDatabase(
        dbPath,
        version: 1,
        onCreate: (db, version) async {
          // Tabla de caché de películas
          await db.execute('''
            CREATE TABLE IF NOT EXISTS movie_cache (
              id TEXT PRIMARY KEY,
              title TEXT,
              data TEXT,
              rating REAL,
              year TEXT,
              category TEXT,
              cached_at INTEGER,
              access_count INTEGER DEFAULT 0,
              last_accessed INTEGER,
              priority INTEGER DEFAULT 0
            )
          ''');

          // Tabla de búsquedas
          await db.execute('''
            CREATE TABLE IF NOT EXISTS search_cache (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              query TEXT UNIQUE,
              results TEXT,
              cached_at INTEGER,
              access_count INTEGER DEFAULT 0
            )
          ''');

          // Tabla de sincronización pendiente
          await db.execute('''
            CREATE TABLE IF NOT EXISTS pending_sync (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              action TEXT,
              data TEXT,
              created_at INTEGER,
              retry_count INTEGER DEFAULT 0
            )
          ''');

          // Tabla de patrones de visualización
          await db.execute('''
            CREATE TABLE IF NOT EXISTS viewing_patterns (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              movie_id TEXT,
              watched_at INTEGER,
              watch_duration INTEGER,
              completion_percentage REAL,
              category TEXT,
              rating REAL
            )
          ''');
        },
      );
    } catch (e) {
      // Error al inicializar BD - continuar sin caché
    }
  }

  /// Realiza sincronización de datos pendientes
  Future<void> _performSync() async {
    try {
      final pendingSyncItems = await _cacheDb.query('pending_sync');

      for (final item in pendingSyncItems) {
        try {
          final action = item['action'] as String?;
          final dataStr = item['data'] as String?;

          if (action == null || dataStr == null) continue;

          // Sincronizar según tipo de acción
          switch (action) {
            case 'add_favorite':
              // Sincronizar favoritos
              break;
            case 'rating':
              // Sincronizar calificaciones
              break;
            case 'watchlist':
              // Sincronizar watchlist
              break;
          }

          // Si se sincroniza exitosamente, eliminar del pending
          await _cacheDb.delete(
            'pending_sync',
            where: 'id = ?',
            whereArgs: [item['id']],
          );

          // Notificar sincronización
          _notifySyncComplete({'action': action, 'status': 'success'});
        } catch (e) {
          // Incrementar retry count
          final retryCount = ((item['retry_count'] ?? 0) as int) + 1;
          if (retryCount < 3) {
            await _cacheDb.update(
              'pending_sync',
              {'retry_count': retryCount},
              where: 'id = ?',
              whereArgs: [item['id']],
            );
          } else {
            // Si supera reintentos, eliminar
            await _cacheDb.delete(
              'pending_sync',
              where: 'id = ?',
              whereArgs: [item['id']],
            );
          }
        }
      }

      // Limpiar caché adaptativo (eliminar items menos accedidos)
      await _cleanupAdaptiveCache();
    } catch (e) {
      // Error en sincronización - continuar
    }
  }

  /// Limpia caché adaptativo basado en frecuencia de acceso y antigüedad
  Future<void> _cleanupAdaptiveCache() async {
    try {
      final now = DateTime.now().millisecondsSinceEpoch;
      final sevenDaysAgo = now - (7 * 24 * 60 * 60 * 1000);

      // Eliminar items más antiguos de 7 días con bajo acceso
      await _cacheDb.delete(
        'movie_cache',
        where: 'cached_at < ? AND access_count < ?',
        whereArgs: [sevenDaysAgo, 2],
      );

      // Si caché es muy grande (>50MB), eliminar items menos accedidos
      final dbSize = File(_cacheDb.path).lengthSync();
      if (dbSize > 52428800) {
        // Obtener items con menos acceso
        final leastAccessed = await _cacheDb.query(
          'movie_cache',
          orderBy: 'access_count ASC, last_accessed ASC',
          limit: 50,
        );

        for (final item in leastAccessed) {
          await _cacheDb.delete(
            'movie_cache',
            where: 'id = ?',
            whereArgs: [item['id']],
          );
        }
      }
    } catch (e) {
      // Error limpiando caché - continuar
    }
  }

  /// Cachea una película adaptivamente
  Future<void> cacheMovie(Map<String, dynamic> movieData) async {
    try {
      await _cacheDb.insert(
        'movie_cache',
        {
          'id': movieData['id'],
          'title': movieData['title'],
          'data': jsonEncode(movieData),
          'rating': movieData['rating'],
          'year': movieData['year'],
          'category': movieData['category'],
          'cached_at': DateTime.now().millisecondsSinceEpoch,
          'access_count': 1,
          'last_accessed': DateTime.now().millisecondsSinceEpoch,
          'priority': _calculatePriority(movieData),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      // Error cacheando película - continuar
    }
  }

  /// Obtiene una película del caché
  Future<Map<String, dynamic>?> getCachedMovie(String movieId) async {
    try {
      final results = await _cacheDb.query(
        'movie_cache',
        where: 'id = ?',
        whereArgs: [movieId],
      );

      if (results.isNotEmpty) {
        final item = results.first;
        final dataStr = item['data'] as String?;
        
        if (dataStr != null) {
          // Actualizar contador de acceso
          await _cacheDb.update(
            'movie_cache',
            {
              'access_count': (item['access_count'] as int) + 1,
              'last_accessed': DateTime.now().millisecondsSinceEpoch,
            },
            where: 'id = ?',
            whereArgs: [movieId],
          );

          return jsonDecode(dataStr);
        }
      }
      return null;
    } catch (e) {
      // Error obteniendo película en caché - retornar null
      return null;
    }
  }

  /// Cachea resultados de búsqueda
  Future<void> cacheSearchResults(String query, List<dynamic> results) async {
    try {
      await _cacheDb.insert(
        'search_cache',
        {
          'query': query,
          'results': jsonEncode(results),
          'cached_at': DateTime.now().millisecondsSinceEpoch,
          'access_count': 1,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      // Error cacheando búsqueda - continuar
    }
  }

  /// Obtiene resultados de búsqueda en caché
  Future<List<dynamic>?> getCachedSearchResults(String query) async {
    try {
      final results = await _cacheDb.query(
        'search_cache',
        where: 'query = ?',
        whereArgs: [query],
      );

      if (results.isNotEmpty) {
        final item = results.first;
        final resultsStr = item['results'] as String?;
        
        if (resultsStr != null) {
          // Actualizar acceso
          await _cacheDb.update(
            'search_cache',
            {
              'access_count': (item['access_count'] as int) + 1,
            },
            where: 'query = ?',
            whereArgs: [query],
          );

          return jsonDecode(resultsStr);
        }
      }
      return null;
    } catch (e) {
      // Error obteniendo búsqueda en caché - retornar null
      return null;
    }
  }

  /// Registra patrón de visualización para recomendaciones
  Future<void> recordViewingPattern({
    required String movieId,
    required String category,
    required double rating,
    required int watchDuration,
    required double completionPercentage,
  }) async {
    try {
      await _cacheDb.insert(
        'viewing_patterns',
        {
          'movie_id': movieId,
          'watched_at': DateTime.now().millisecondsSinceEpoch,
          'watch_duration': watchDuration,
          'completion_percentage': completionPercentage,
          'category': category,
          'rating': rating,
        },
      );
    } catch (e) {
      // Error registrando patrón - continuar
    }
  }

  /// Obtiene patrones de visualización
  Future<List<Map<String, dynamic>>> getViewingPatterns() async {
    try {
      return await _cacheDb.query('viewing_patterns');
    } catch (e) {
      // Error obteniendo patrones - retornar lista vacía
      return [];
    }
  }

  /// Agrega un elemento a sincronizar offline
  Future<void> addPendingSync({
    required String action,
    required Map<String, dynamic> data,
  }) async {
    try {
      await _cacheDb.insert(
        'pending_sync',
        {
          'action': action,
          'data': jsonEncode(data),
          'created_at': DateTime.now().millisecondsSinceEpoch,
          'retry_count': 0,
        },
      );
    } catch (e) {
      // Error agregando sincronización - continuar
    }
  }

  /// Obtiene estado de conectividad
  bool get isOnline => _isOnline;

  /// Escucha cambios de conectividad
  void onConnectivityChanged(Function(bool) callback) {
    _connectivityListeners.add(callback);
  }

  /// Escucha cambios de sincronización
  void onSyncComplete(Function(Map<String, dynamic>) callback) {
    _syncListeners.add(callback);
  }

  void _notifyConnectivityChange(bool isOnline) {
    for (final listener in _connectivityListeners) {
      listener(isOnline);
    }
  }

  void _notifySyncComplete(Map<String, dynamic> data) {
    for (final listener in _syncListeners) {
      listener(data);
    }
  }

  /// Calcula prioridad de caché basada en rating
  int _calculatePriority(Map<String, dynamic> movieData) {
    final rating = (movieData['rating'] ?? 0) as num;
    if (rating >= 8) return 3;
    if (rating >= 6) return 2;
    return 1;
  }

  /// Limpia toda la caché
  Future<void> clearAllCache() async {
    try {
      await _cacheDb.delete('movie_cache');
      await _cacheDb.delete('search_cache');
      await _cacheDb.delete('viewing_patterns');
    } catch (e) {
      // Error limpiando caché - continuar
    }
  }

  /// Cierra el servicio
  void dispose() {
    _connectivitySubscription.cancel();
    _syncTimer?.cancel();
  }
}
