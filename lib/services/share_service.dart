import 'package:share_plus/share_plus.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/movie.dart';

/// Servicio para formatear y compartir películas de forma elegante
class ShareService {
  /// Genera formato elegante para compartir películas en texto plano
  static String formatMovieShare(Movie movie) {
    final castList = movie.cast.isNotEmpty 
        ? movie.cast.take(5).join(', ') 
        : 'No disponible';
    
    return '''
🎬 ${movie.title} 🎬

⭐ Rating: ${movie.rating}/10
📅 Año: ${movie.year}
🎭 Género: ${movie.category}

📝 Sinopsis:
${movie.description}

👥 Reparto:
$castList

¿Ya lo viste? ¡Descárgate Flick y descubre más películas!
''';
  }

  /// Descarga la imagen de la película y comparte con la imagen
  static Future<void> shareMovieWithImage(Movie movie) async {
    try {
      // Descargar imagen temporalmente
      final response = await http.get(Uri.parse(movie.imageUrl));
      
      if (response.statusCode == 200) {
        // Obtener directorio temporal
        final tempDir = await getTemporaryDirectory();
        final file = File('${tempDir.path}/${movie.id}_poster.jpg');
        
        // Guardar imagen
        await file.writeAsBytes(response.bodyBytes);
        
        // Compartir con imagen
        final text = formatMovieShare(movie);
        await Share.shareXFiles(
          [XFile(file.path)],
          text: text,
          subject: '${movie.title} - Película recomendada 🎬',
        );
      }
    } catch (e) {
      // Si falla la descarga, compartir solo el texto
      final text = formatMovieShare(movie);
      await Share.share(
        text,
        subject: '${movie.title} - Película recomendada 🎬',
      );
    }
  }

  /// Genera HTML para preview visual (útil para compartir en web)
  static String formatMovieShareHtml(Movie movie) {
    final castList = movie.cast.isNotEmpty 
        ? movie.cast.take(5).join(', ') 
        : 'No disponible';
    
    return '''
<div style="background: linear-gradient(135deg, #1a1a1a 0%, #2d2d2d 100%); padding: 20px; border-radius: 12px; color: white; font-family: Arial, sans-serif; max-width: 400px;">
  <h2 style="color: #4ade80; margin: 0 0 15px 0;">🎬 ${movie.title}</h2>
  <div style="margin-bottom: 12px;">
    <p style="margin: 5px 0;"><strong>⭐ Rating:</strong> ${movie.rating}/10</p>
    <p style="margin: 5px 0;"><strong>📅 Año:</strong> ${movie.year}</p>
    <p style="margin: 5px 0;"><strong>🎭 Género:</strong> ${movie.category}</p>
  </div>
  <p style="margin: 10px 0;"><strong>📝 Sinopsis:</strong> ${movie.description}</p>
  <p style="margin: 10px 0;"><strong>👥 Reparto:</strong> $castList</p>
</div>
''';
  }

  /// Genera formato JSON para compartir programáticamente
  static Map<String, dynamic> formatMovieShareJson(Movie movie) {
    return {
      'title': movie.title,
      'rating': movie.rating,
      'year': movie.year,
      'genre': movie.category,
      'synopsis': movie.description,
      'cast': movie.cast.take(5).toList(),
      'poster': movie.imageUrl,
    };
  }
}
