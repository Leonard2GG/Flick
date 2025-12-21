# 🎬 Flick - Guía de Configuración del Entorno

## 📋 Requisitos Previos

Antes de comenzar, asegúrate de tener instalado:

- **Flutter SDK** (v3.0 o superior)
- **Dart SDK** (incluido con Flutter)
- **Git**
- **Android SDK** (para desarrollo Android)
- **Un editor de código** (VS Code, Android Studio, etc.)

### Verificar instalación:
```bash
flutter --version
dart --version
```

---

## 🚀 Instalación Inicial del Proyecto

### 1. Clonar o descargar el proyecto

```bash
# Si es en un repositorio Git
git clone <url-del-repositorio>
cd flick

# O navegar a la carpeta si ya la tienes descargada
cd c:\Users\USER\Desktop\Flick\flick
```

### 2. Limpiar y preparar el entorno

```bash
# Limpiar archivos anteriores (IMPORTANTE si es la primera vez)
flutter clean

# Obtener todas las dependencias
flutter pub get

# Opcional: Actualizar dependencias a versiones más recientes
flutter pub upgrade
```

### 3. Verificar que todo está correcto

```bash
# Ver el estado del proyecto
flutter doctor

# Analizar el código
flutter analyze

# Ver si hay errores de compilación
flutter pub get
```

---

## 📱 Configurar Emulador o Dispositivo

### Opción A: Usar Emulador Android

```bash
# Ver emuladores disponibles
flutter emulators

# Iniciar un emulador
flutter emulators --launch <emulator_name>

# Ejemplo:
flutter emulators --launch Pixel_4_API_30
```

### Opción B: Conectar Dispositivo Físico

1. Habilitar **Depuración USB** en tu teléfono Android
2. Conectar el dispositivo por USB
3. Verificar que se detecta:
   ```bash
   flutter devices
   ```

### Opción C: Ejecutar en Web (Chrome)

```bash
# No requiere emulador, solo Chrome
flutter run -d chrome
```

---

## ▶️ Ejecutar la Aplicación

### Modo Debug (Desarrollo)

```bash
# Ejecutar en el dispositivo/emulador por defecto
flutter run

# Ejecutar en un dispositivo específico
flutter run -d <device_id>

# Ejecutar con logs verbose
flutter run -v

# Ejecutar en Chrome (web)
flutter run -d chrome
```

### Modo Release (Producción)

```bash
# Para probar en dispositivo real
flutter run --release

# Para generar APK (Android)
flutter build apk --release

# Para generar bundle (Play Store)
flutter build appbundle --release
```

---

## 🔧 Verificación Paso a Paso

Ejecuta estos comandos EN ORDEN para verificar que todo funciona:

### ✅ Paso 1: Verificar Flutter
```bash
flutter doctor
```
**Esperado**: Todos los items en ✓ (excepto posiblemente Visual Studio en Windows, que es opcional)

### ✅ Paso 2: Obtener dependencias
```bash
flutter pub get
```
**Esperado**: Mensaje de éxito sin errores

### ✅ Paso 3: Analizar código
```bash
flutter analyze
```
**Esperado**: Sin errores, máximo advertencias menores

### ✅ Paso 4: Compilar (sin ejecutar)
```bash
flutter build apk --debug
```
O para web:
```bash
flutter build web
```
**Esperado**: Build completado sin errores

### ✅ Paso 5: Ejecutar
```bash
flutter run
```
**Esperado**: La app se abre correctamente en el emulador/dispositivo

---

## 📦 Dependencias del Proyecto

El proyecto usa las siguientes librerías:

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.2
  provider: ^6.0.5                    # State management
  flutter_card_swiper: ^2.0.3         # (opcional, tenemos custom swiper)
  http: ^1.1.0                        # Llamadas a TMDB API
  shared_preferences: ^2.0.0          # Persistencia local
```

Para agregar una dependencia manual:
```bash
flutter pub add nombre_paquete
```

---

## 🌐 Configuración de API (TMDB)

El proyecto ya incluye las credenciales de TMDB en `lib/services/tmdb_service.dart`:

- **API Key**: Ya configurado
- **Access Token**: Ya configurado

⚠️ **Importante**: En producción, estas credenciales deben estar en variables de entorno o en un archivo `.env` ignorado en Git.

---

## 🐛 Solución de Problemas Comunes

### Problema: "No pubspec.yaml found"
```bash
# Solución: Asegúrate de estar en la carpeta correcta
cd c:\Users\USER\Desktop\Flick\flick
```

### Problema: Dependencias no se instalan
```bash
# Solución 1: Limpiar caché y reinstalar
flutter clean
flutter pub get

# Solución 2: Verificar conexión a internet
# Solución 3: Usar repositorio alternativo
flutter pub get --verbose
```

### Problema: Emulador no se abre
```bash
# Listar emuladores disponibles
flutter emulators

# Crear uno nuevo desde Android Studio si no hay
# O usar web como alternativa: flutter run -d chrome
```

### Problema: Errores de compilación
```bash
# Verificar errores específicos
flutter analyze --verbose

# Limpiar y reintentar
flutter clean
flutter pub get
flutter run
```

### Problema: SharedPreferences no funciona
```bash
# Asegúrate de que está instalado
flutter pub add shared_preferences

# Luego ejecuta
flutter pub get
```

### Problema: La app se cierra al iniciar
```bash
# Ver logs detallados
flutter run -v

# Revisar errores en la consola
# Común: Faltan dependencias o la API de TMDB no responde
```

---

## 🎯 Checklist de Verificación

Antes de hacer cambios al código, verifica que:

- [ ] `flutter doctor` muestra todo en ✓
- [ ] `flutter pub get` se ejecuta sin errores
- [ ] `flutter analyze` sin errores críticos
- [ ] `flutter run` inicia la app correctamente
- [ ] Puedes navegar entre las 3 pestañas:
  - [ ] Menú (Géneros)
  - [ ] Descubrir (Películas con swipe)
  - [ ] Mi Lista (Watchlist)
- [ ] Puedes deslizar una película y guardarla
- [ ] La película aparece en "Mi Lista"
- [ ] Puedes buscar películas (ícono de búsqueda)

---

## 💡 Comandos Útiles Frecuentes

```bash
# Ver dispositivs conectados
flutter devices

# Ejecutar con logs
flutter run -v

# Ejecutar en modo debug con pausa inicial
flutter run -d <device_id> -v

# Generar APK para pruebas
flutter build apk --debug

# Hot reload (durante ejecución)
r (en terminal)

# Hot restart
R (en terminal)

# Salir de flutter run
q (en terminal)

# Limpiar todo
flutter clean

# Ver versión de Flutter
flutter --version

# Ver info detallada del proyecto
flutter pub global activate devtools
devtools
```

---

## 🔐 Seguridad - Antes de Publicar

- [ ] Mover credenciales de API a variables de entorno
- [ ] Cambiar SharedPreferences por base de datos (local o remota) para datos sensibles
- [ ] Ejecutar `flutter analyze` sin advertencias críticas
- [ ] Probar en múltiples dispositivos
- [ ] Verificar permisos en AndroidManifest.xml

---

## 📚 Documentación Adicional

- **Flutter**: https://flutter.dev/docs
- **Provider**: https://pub.dev/packages/provider
- **TMDB API**: https://www.themoviedb.org/settings/api
- **Dart**: https://dart.dev/guides

---

## ❓ ¿Problemas?

Si algo no funciona después de seguir estos pasos:

1. Ejecuta `flutter doctor` y revisa los errores
2. Intenta `flutter clean && flutter pub get`
3. Revisa los logs con `flutter run -v`
4. Verifica que tienes conexión a internet (para TMDB API)

---

**Última actualización**: Diciembre 2025
**Versión de Flutter**: 3.32.4 o superior
