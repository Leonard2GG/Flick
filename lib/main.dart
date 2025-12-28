import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'providers/movie_provider.dart';
import 'providers/recommendation_provider.dart';
import 'services/intelligent_sync_service.dart';
import 'screens/main_wrapper.dart';
//import 'screens/splash_screen.dart';


void main() async {
  // Asegurar que Flutter esté inicializado
  WidgetsFlutterBinding.ensureInitialized();
  
  // Ocultar completamente los elementos del sistema
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  
  // Inicializar sincronización inteligente
  final syncService = IntelligentSyncService();
  await syncService.initialize();
  
  // Inicializar recomendaciones
  final recommendationProvider = RecommendationProvider();
  await recommendationProvider.initialize();
  
  // Inicializar MovieProvider con SharedPreferences
  final movieProvider = MovieProvider();
  await movieProvider.init();

   // Establecer colores para las barras del sistema (compatibles con splash)
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.black,
      systemNavigationBarColor: Colors.black,
    ),
  );
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<MovieProvider>.value(value: movieProvider),
        Provider<RecommendationProvider>.value(value: recommendationProvider),
      ],
      child: const FlickApp(),
    ),
  );
}

class FlickApp extends StatelessWidget {
  const FlickApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flick',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121212),
        primaryColor: Colors.greenAccent,
      ),
      // SplashScreenPage como pantalla inicial
      home: const MainWrapper(),
    );
  }
}