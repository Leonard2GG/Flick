import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'providers/movie_provider.dart';
import 'screens/main_wrapper.dart';

void main() {
  // Ocultar la barra de sistema y navegación permanentemente
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MovieProvider()),
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