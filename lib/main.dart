import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'providers/movie_provider.dart';
import 'screens/main_wrapper.dart';

void main() async {
  // Asegurar que Flutter esté inicializado
  WidgetsFlutterBinding.ensureInitialized();
  
  // Ocultar la barra de sistema y navegación permanentemente
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  
  // Inicializar MovieProvider con SharedPreferences
  final movieProvider = MovieProvider();
  await movieProvider.init();
  
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
      home: const MainWrapper(),
    );
  }
}