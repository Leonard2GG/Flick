import 'package:share_plus/share_plus.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/movie.dart';

/// Servicio para formatear y compartir películas de forma elegante
/// Solo comparte nombres de actores sin imágenes de fotos
class ShareService {
  /// Genera formato elegante para compartir películas en texto plano
  /// IMPORTANTE: Solo comparte nombres de actores, SIN FOTOS
  /// Se envían solo los nombres en texto para mejor compatibilidad con WhatsApp
  static String formatMovieShare(Movie movie) {
    // Obtener solo los nombres de los actores (máximo 5)
    // Sin fotos ni imágenes adicionales
    final castNamesList = movie.cast.isNotEmpty 
        ? movie.cast.take(5).toList()
        : [];
    final castNames = castNamesList.isNotEmpty
        ? castNamesList.join(', ')
        : 'No disponible';
    
    return '''
🎬 ${movie.title} 🎬

⭐ Rating: ${movie.rating}/10
📅 Año: ${movie.year}
🎭 Género: ${movie.category}

📝 Sinopsis:
${movie.description}

👥 Reparto Principal:
$castNames

¿Ya lo viste? ¡Descárgate Flick y descubre más películas!
''';
  }
  
  /// Extrae solo los nombres de los actores para compartir
  /// Useful si necesitas solo los nombres sin formato
  static List<String> getActorNames(Movie movie) {
    return movie.cast.take(5).toList();
  }
  
  /// Obtiene los nombres de actores formateados como texto simple
  /// Sin emojis, sin imágenes, solo nombres
  static String getSimpleCastList(Movie movie) {
    if (movie.cast.isEmpty) return 'No disponible';
    return movie.cast.take(5).join(', ');
  }

  /// Descarga la imagen de la película (SOLO el poster, NO fotos de actores)
  /// y comparte con el contenido de texto que incluye nombres de actores
  static Future<void> shareMovieWithImage(Movie movie) async {
    try {
      // Descargar SOLO el poster de la película (no fotos de actores)
      final response = await http.get(Uri.parse(movie.imageUrl)).timeout(
        const Duration(seconds: 10),
      );
      
      if (response.statusCode == 200) {
        // Obtener directorio temporal
        final tempDir = await getTemporaryDirectory();
        final file = File('${tempDir.path}/${movie.id}_poster.jpg');
        
        // Guardar imagen del poster
        await file.writeAsBytes(response.bodyBytes);
        
        // Verificar que el archivo existe y tiene contenido
        if (await file.exists() && await file.length() > 0) {
          // Compartir: Poster (imagen) + Nombres de actores (texto)
          // IMPORTANTE: Se comparten SOLO los nombres de actores, sin fotos
          final text = formatMovieShare(movie);
          try {
            await Share.shareXFiles(
              [XFile(file.path)],
              text: text,
              subject: '${movie.title} - Película recomendada 🎬',
            ).timeout(const Duration(seconds: 15));
          } catch (shareError) {
            // Si falla compartir con imagen, intentar solo con texto
            await _shareTextOnly(movie);
          }
        } else {
          // Si el archivo está vacío, compartir solo texto
          await _shareTextOnly(movie);
        }
      } else {
        // Si la descarga falla, compartir solo texto con nombres
        await _shareTextOnly(movie);
      }
    } catch (e) {
      // Si hay cualquier error, compartir solo el texto con nombres de actores
      await _shareTextOnly(movie);
    }
  }

  /// Comparte solo el texto de la película (sin imágenes)
  /// Incluye: Título, rating, año, género, sinopsis y NOMBRES de actores
  /// NO incluye fotos de actores, solo sus nombres
  static Future<void> _shareTextOnly(Movie movie) async {
    try {
      final text = formatMovieShare(movie);
      await Share.share(
        text,
        subject: '${movie.title} - Película recomendada 🎬',
      );
    } catch (e) {
      // Error silencioso si todo falla
      print('Error al compartir: $e');
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
