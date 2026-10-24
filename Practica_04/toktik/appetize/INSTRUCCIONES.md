# Preparar, comprobar y actualizar la demostración

## Requisitos del proyecto

La configuración Android existente usa JDK 17, Android Gradle Plugin 9.1.0, Kotlin 2.4.0 y Gradle 9.3.1. Mantén las versiones definidas por el proyecto y utiliza el Flutter SDK instalado en el equipo.

## Generar y comprobar el APK

1. Desde la raíz de `Practica_04/tok_tik`, ejecuta:

   ```powershell
   flutter pub get
   flutter build apk --debug
   ```

2. Confirma que exista `build/app/outputs/flutter-apk/app-debug.apk`, revisa que su tamaño sea distinto de cero y verifica que la salida de Flutter informe que `assembleDebug` terminó. El APK actual pesa 165,139,031 bytes y el metadato de Gradle confirma `com.example.tok_tik`.
3. Para validar el comportamiento, instala el APK en un emulador Android o súbelo a Appetize.io y prueba el inicio, la reproducción de video, el audio y la navegación. Una compilación exitosa no demuestra que las fuentes remotas estén disponibles o que los videos se reproduzcan.

En esta revisión, `flutter pub get` y `flutter build apk --debug` terminaron correctamente sin crear una carpeta vacía. No hay videos MP4 en `tok_tik` ni en las carpetas de `Practica_04` inspeccionadas, aunque `pubspec.yaml` declara `assets/videos/` y `local_video_posts.dart` referencia ocho MP4. La inspección del APK confirmó que no contiene videos locales. Las cinco imágenes y los cuatro archivos MP3 declarados sí están incluidos. `main.dart` inicializa tres fuentes remotas para los feeds; por tanto, su reproducción depende de la red y de la disponibilidad de las URLs.

## Subir a Appetize.io

1. Inicia sesión en <https://appetize.io/upload>.
2. Selecciona la plataforma Android y sube `build/app/outputs/flutter-apk/app-debug.apk`.
3. Espera a que Appetize procese la compilación y ábrela en el navegador.
4. En **Apps** o **App Builds**, abre la compilación y selecciona **Share**. Copia el enlace generado; cada enlace de build identifica esa compilación concreta.
5. Prueba el enlace en una ventana privada si la configuración de acceso lo permite. Si el enlace requiere autenticación, ajusta los permisos desde Appetize con la cuenta propietaria.

La URL del identificador de aplicación proporcionada para esta demo es <https://appetize.io/app/android/com.example.tok_tik>. No se subió desde este entorno el APK local más reciente ni se verificó en vivo el enlace. Si cargas una nueva compilación, usa **Share** para copiar la URL específica de ese build y actualiza la documentación si vas a compartir ese enlace de versión.

## Actualizar una demostración existente

1. Vuelve a ejecutar `flutter pub get` y `flutter build apk --debug`.
2. Carga el nuevo APK en Appetize con la sesión propietaria. Al actualizar la app existente, Appetize asocia la nueva compilación a esa app.
3. Abre la nueva compilación, verifica el funcionamiento que necesites y copia el enlace de **Share** correspondiente a esa versión.
4. Actualiza la documentación si vas a compartir el enlace específico de la nueva compilación.

## Límites conocidos

- No se subió el APK local más reciente desde este entorno; no hay integración autorizada para cargarlo. Las capturas muestran una sesión previa de Appetize, pero no verifican su disponibilidad actual.
- Los MP4 locales declarados no están incluidos. La app principal carga feeds remotos que requieren conectividad y que sus URLs de demostración sigan disponibles.
- Una compilación exitosa solo comprueba el empaquetado Android; no equivale a una prueba funcional en emulador o Appetize.io.

## Documentación oficial

- [Cargar aplicaciones](https://docs.appetize.io/platform/app-management/uploading-apps)
- [Compartir aplicaciones](https://docs.appetize.io/platform/sharing-apps)
