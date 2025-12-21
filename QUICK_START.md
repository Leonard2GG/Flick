# ⚡ Referencia Rápida - Flick

## 🚀 Inicio Rápido

```bash
# Navegar al proyecto
cd c:\Users\USER\Desktop\Flick\flick

# Opción 1: Verificar todo automáticamente (Windows)
verify.bat

# Opción 2: Verificar manualmente (PowerShell/Bash)
.\verify.ps1

# Opción 3: Pasos manuales
flutter clean
flutter pub get
flutter run
```

---

## 📱 Ejecutar en Diferentes Plataformas

### Android (Emulador o Dispositivo)
```bash
flutter run
```

### Web (Chrome)
```bash
flutter run -d chrome
```

### Con logs detallados
```bash
flutter run -v
```

### Build APK (para instalar después)
```bash
flutter build apk --debug
# El APK estará en: build/app/outputs/apk/debug/app-debug.apk
```

---

## 🔧 Soluciones Rápidas

### Dependencias no se instalan
```bash
flutter clean
flutter pub get --verbose
```

### Errores de compilación aleatorios
```bash
flutter clean
flutter pub get
flutter run
```

### SharedPreferences error
```bash
flutter pub add shared_preferences
flutter pub get
```

### Ver dispositivos disponibles
```bash
flutter devices
```

### Crear emulador (Android)
```bash
# Abrir Android Studio y crear uno gráficamente, o:
# La mayoría de máquinas ya tienen emuladores en Android Studio
```

---

## 📁 Estructura del Proyecto

```
flick/
├── lib/
│   ├── main.dart                 # Punto de entrada
│   ├── screens/
│   │   ├── home_screen.dart      # Géneros
│   │   ├── discovery_screen.dart # Películas con swipe
│   │   ├── watchlist_screen.dart # Mi lista
│   │   ├── movie_detail_screen.dart
│   │   └── main_wrapper.dart     # Navegación
│   ├── models/
│   │   └── movie.dart            # Modelo de película
│   ├── providers/
│   │   └── movie_provider.dart   # State management
│   ├── services/
│   │   └── tmdb_service.dart     # API de TMDB
│   └── widgets/
│       ├── category_card.dart
│       └── movie_search_delegate.dart
├── pubspec.yaml                  # Dependencias
├── SETUP.md                       # Guía completa
├── verify.bat                     # Script verificación (Windows)
└── verify.ps1                     # Script verificación (PowerShell)
```

---

## 🧪 Checklist de Verificación

- [ ] `flutter doctor` - Sin errores críticos
- [ ] `flutter pub get` - Éxito
- [ ] `flutter analyze` - Sin errores (advertencias OK)
- [ ] App inicia sin crashes
- [ ] Puedes ver géneros en HomeScreen
- [ ] Puedes deslizar película en DiscoveryScreen
- [ ] Película se guarda en MI LISTA
- [ ] Película se elimina al deslizar en watchlist
- [ ] Búsqueda funciona (ícono lupa)

---

## 🌐 Credenciales API

✅ **TMDB API**: Ya configurada en `lib/services/tmdb_service.dart`

No necesitas agregar nada, ya está incluido.

---

## 📊 Funcionalidades Actuales

- ✅ Carga de géneros desde TMDB
- ✅ Películas populares de TMDB
- ✅ Swipe para guardar/descartar (Tinder style)
- ✅ Guardado en Mi Lista (persistencia local)
- ✅ Búsqueda de películas
- ✅ Detalles de película
- ✅ Eliminación de watchlist

---

## 🎮 Comandos Durante Ejecución

```
r    - Hot reload (recarga código, mantiene estado)
R    - Hot restart (recarga todo)
L    - Ver logs (si está en log mode)
W    - Toggle widget inspector
q    - Quit (salir)
```

---

## 🔴 Problemas Comunes

| Problema | Solución |
|----------|----------|
| `pubspec.yaml not found` | Estás en la carpeta incorrecta |
| No hay emuladores | Abre uno en Android Studio |
| App se crashea al iniciar | Revisa logs con `flutter run -v` |
| SharedPreferences error | Ejecuta `flutter pub add shared_preferences` |
| Imágenes no cargan | Verifica conexión a internet |
| Búsqueda no funciona | Verifica API de TMDB está disponible |

---

## 📚 Archivos Importantes

- **Lógica de películas**: `lib/providers/movie_provider.dart`
- **API TMDB**: `lib/services/tmdb_service.dart`
- **Películas swipe**: `lib/screens/discovery_screen.dart`
- **Mi Lista**: `lib/screens/watchlist_screen.dart`
- **Dependencias**: `pubspec.yaml`

---

## 🆘 Necesitas Ayuda?

1. Consulta `SETUP.md` (guía completa)
2. Ejecuta `verify.bat` o `verify.ps1` (diagnóstico automático)
3. Revisa logs: `flutter run -v`
4. Ejecuta `flutter doctor` (estado del sistema)

---

**Última actualización**: Diciembre 2025
