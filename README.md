# 🎬 Flick - Tu App de Películas Inteligente

<div align="center">

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)
![Version](https://img.shields.io/badge/Version-1.0.0-blue?style=for-the-badge)

**Descubre, explora y guarda tus películas favoritas de forma inteligente**

[Características](#características) • [Instalación](#instalación) • [Estructura](#estructura-del-proyecto) • [API](#api) • [Contribuciones](#contribuciones)

</div>

---

## ✨ Características

### 🎯 Exploración Inteligente
- **Búsqueda avanzada** de películas con filtros por género
- **Descubrimiento automático** de nuevas películas
- **Recomendaciones personalizadas** basadas en tus gustos
- **Interfaz fluida** con animaciones suaves

### 📋 Gestión de Lista
- **Watchlist personalizada** para guardar películas
- **Búsqueda dentro de tu lista** de películas guardadas
- **Clasificación personalizada** con ratings propios
- **Gestor de favoritos** para marcar tus películas preferidas

### 🔄 Funcionalidades Sociales
- **Compartir películas en WhatsApp** con detalles y reparto
- **Vista previa del contenido** antes de compartir
- **Formato elegante** con emojis y información detallada
- **Copiar contenido** al portapapeles fácilmente

### 🖼️ Experiencia Visual
- **Imágenes en caché** para mejor rendimiento
- **Efecto parallax** en las imágenes de películas
- **Dark mode** por defecto optimizado para ojos
- **Animaciones smooth** en transiciones

### 🌐 Conectividad
- **Detección automática** de conexión a internet
- **Manejo robusto** de errores de red
- **Funcionamiento offline** parcial en listas guardadas
- **Sincronización** automática cuando hay conexión

---

## 🚀 Instalación

### Requisitos Previos
- Flutter 3.0+ 
- Dart 3.0+
- Android SDK / iOS SDK
- Conexión a Internet (para API de películas)

### Pasos de Instalación

```bash
# 1. Clonar el repositorio
git clone https://github.com/tu-usuario/flick.git
cd flick

# 2. Instalar dependencias
flutter pub get

# 3. Generar archivos necesarios (si es necesario)
flutter pub run build_runner build

# 4. Ejecutar la app
flutter run
```

### Configuración de API
1. Obtén tu API key de [TMDB](https://www.themoviedb.org/settings/api)
2. Actualiza el archivo de configuración en `lib/services/tmdb_service.dart`
3. ¡Listo! La app está lista para usar

---

## 📁 Estructura del Proyecto

```
lib/
├── main.dart                 # Punto de entrada de la aplicación
├── models/
│   └── movie.dart           # Modelo de datos de películas
├── providers/
│   └── movie_provider.dart  # State management con Provider
├── screens/
│   ├── home_screen.dart     # Pantalla principal
│   ├── discovery_screen.dart # Exploración de películas
│   ├── watchlist_screen.dart # Lista de películas guardadas
│   ├── movie_detail_screen.dart # Detalle de película
│   ├── splash_screen.dart   # Pantalla de inicio
│   └── main_wrapper.dart    # Wrapper principal
├── services/
│   ├── tmdb_service.dart    # Integración con API TMDB
│   ├── share_service.dart   # Servicio de compartición
│   └── connectivity_utils.dart # Gestión de conectividad
└── widgets/
    ├── cached_image_loader.dart # Carga optimizada de imágenes
    ├── share_movie_bottom_sheet.dart # UI para compartir
    ├── animations.dart      # Animaciones personalizadas
    ├── category_card.dart   # Tarjeta de categoría
    └── ...                  # Otros widgets
```

---

## 🔌 API & Servicios

### TMDB API
La aplicación utiliza [The Movie Database (TMDB)](https://www.themoviedb.org/) para obtener:
- Información detallada de películas
- Posters y imágenes
- Ratings y reseñas
- Información del reparto
- Géneros y categorías

### Servicios Internos

#### `ShareService`
Maneja el compartir películas en redes sociales:
```dart
// Compartir con formato elegante
await ShareService.shareMovieWithImage(movie);
```

#### `MovieProvider`
Gestiona el estado global de películas usando Provider:
```dart
// Acceder a la watchlist
final watchlist = context.read<MovieProvider>().watchlist;
```

#### `ConnectivityUtils`
Verifica la conexión a internet:
```dart
// Verificar conectividad
await ConnectivityUtils.isConnected();
```

---

## 🎨 Diseño & UI

- **Color Scheme**: Dark mode (#121212, #1E1E1E) con acentos verde (#4ADE80)
- **Tipografía**: Roboto y Poppins para mejor legibilidad
- **Animaciones**: Smooth transitions y parallax effects
- **Responsive**: Adaptable a diferentes tamaños de pantalla

---

## 📦 Dependencias Principales

```yaml
flutter:
  sdk: flutter
  
provider: ^6.0.0           # State management
http: ^1.1.0              # Peticiones HTTP
share_plus: ^6.0.0        # Compartir contenido
connectivity_plus: ^4.0.0 # Detectar conectividad
path_provider: ^2.0.0     # Rutas del sistema
sqflite: ^2.2.0           # Base de datos local
cached_network_image: ^3.2.0 # Caché de imágenes
```

---

## 🐛 Troubleshooting

### La app no carga películas
- Verifica tu conexión a internet
- Comprueba que tu API key de TMDB sea válida
- Revisa los logs: `flutter logs`

### Las imágenes no se cargan
- Asegúrate de tener permisos de internet en AndroidManifest.xml
- Borra el caché: `flutter clean`

### Errores de compilación
```bash
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
flutter run
```

---

## 🤝 Contribuciones

¡Las contribuciones son bienvenidas! Por favor:

1. Fork el repositorio
2. Crea una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

---

## 📝 Licencia

Este proyecto está bajo la licencia MIT. Ver [LICENSE](LICENSE) para más detalles.

---

## 👨‍💻 Autor

**Creado con ❤️ para los amantes del cine**

- GitHub: [@tu-usuario](https://github.com/tu-usuario)
- Email: tu-email@ejemplo.com

---

## 🔗 Enlaces Útiles

- [Flutter Documentation](https://flutter.dev/docs)
- [TMDB API Docs](https://developer.themoviedb.org/docs)
- [Provider Package](https://pub.dev/packages/provider)
- [Dart Documentation](https://dart.dev/guides)

---

<div align="center">

**⭐ Si te gusta el proyecto, por favor dale una estrella!**

Hecho con Flutter 🚀 | Version 1.0.0

</div>
