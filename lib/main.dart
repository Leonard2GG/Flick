import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'providers/movie_provider.dart';
//import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';


void main() async {
  // Asegurar que Flutter esté inicializado
  WidgetsFlutterBinding.ensureInitialized();
  
  // Ocultar completamente los elementos del sistema
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  
  
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
      home: const HomeScreen(),
    );
  }
}