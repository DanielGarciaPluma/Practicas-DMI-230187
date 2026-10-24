# Demostración de TokTik en Appetize.io

Esta carpeta reúne las instrucciones para compilar la versión Android, subirla a Appetize.io y compartir el enlace de una compilación.

## Estado de publicación

**Demo:** [Probar TokTik en Appetize.io](https://appetize.io/app/b_wwsqnavmpk4jd6h7jt75qjmrxq). La URL del identificador de la aplicación aparece abierta en las capturas de evidencia. El acceso puede depender de los permisos o de la sesión de Appetize; esta actualización no comprobó en vivo el estado actual del servicio ni cargó el APK local más reciente.

La compilación de depuración terminó correctamente. Los ocho MP4 esperados por las publicaciones locales (`assets/videos/1.mp4` a `assets/videos/8.mp4`) no están en el proyecto ni dentro del APK; no se añadieron archivos sustitutos. Los feeds iniciales usan fuentes remotas y requieren conectividad. Consulta [INSTRUCCIONES.md](INSTRUCCIONES.md) para los pasos de preparación y carga.

## Preparar y subir

Desde la raíz de `tok_tik`:

```powershell
flutter pub get
flutter build apk --debug
```

El APK generado está en `build/app/outputs/flutter-apk/app-debug.apk` (165,139,031 bytes; identificador Android `com.example.tok_tik`). Para publicar una compilación nueva, inicia sesión y sube ese archivo en <https://appetize.io/upload>. Tras procesarlo, abre **Apps** o **App Builds**, selecciona la compilación y pulsa **Share** para copiar el enlace específico de esa versión.

La guía paso a paso está en [INSTRUCCIONES.md](INSTRUCCIONES.md). La carga requiere una sesión de Appetize.io y debe realizarla una persona con acceso a la cuenta.
