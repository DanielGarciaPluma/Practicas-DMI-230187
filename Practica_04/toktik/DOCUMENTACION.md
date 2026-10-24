DOCUMENTACION.md
# Documentación técnica de TokTik

Esta guía amplía el resumen del [README principal](README.md) con la organización observada en el código, las dependencias, la configuración Android, las pruebas disponibles y las limitaciones comprobadas.

## Estructura del proyecto

~~~text
tok_tik/
├── android/                 Configuración Android, Activity, receptor e iconos
├── appetize/                Instrucciones para la demo y capturas de Appetize
│   └── imagenes/            Siete capturas originales de la aplicación
├── architecture/            Diagramas PNG, HTML y JSON
├── assets/
│   ├── Iconos/              Evidencias de iconos por temporada
│   ├── Opciones/            Evidencias de configuración de fecha, fuente y tema
│   └── Videos/              Evidencias de feeds e interacciones
├── lib/
│   ├── config/              Tema, temporada y formato de métricas
│   ├── domain/              Entidad VideoPost y contratos
│   ├── infrastructure/      Datasources, modelos, repositorio y almacenamiento
│   ├── presentation/        Provider, pantallas y widgets
│   └── shared/              Datos estáticos de publicaciones locales
├── test/                    Pruebas de widget y unitarias
├── pubspec.yaml             SDK, paquetes y recursos Flutter
└── README.md                Presentación y evidencias de la práctica
~~~

Los posts locales hacen referencia a **assets/videos/**, pero esa carpeta no existe en el checkout y no está declarada como recurso en pubspec.yaml.

## Organización del código

### Inicio de la aplicación

**lib/main.dart** inicializa el almacenamiento local, determina la temporada, solicita sincronizar el icono nativo y registra un DiscoverProvider con tres repositorios:

- **Discover:** LocalVideoDatasource.
- **For You:** PixabayVideoDatasource.
- **Favorites:** CoverVideoDatasource.

### Presentación

- **presentation/providers/discover_provider.dart** mantiene las listas de videos, favoritos, estados de carga, refresco y paginación; delega la obtención de publicaciones en repositorios.
- **presentation/screens/splash/** presenta la bienvenida antes de navegar al contenido.
- **presentation/screens/discover/** implementa el selector de temporada, las cuatro páginas y el gesto de navegación horizontal entre secciones.
- **presentation/widgets/video/** contiene el reproductor a pantalla completa y su fondo visual.
- **presentation/widgets/shared/** reúne el feed vertical, los controles y la navegación inferior.
- **presentation/widgets/favorites/** muestra la lista de favoritos persistidos.

### Dominio

- **domain/entities/video_post.dart** define la publicación de video y su serialización.
- **domain/datasources/video_posts_datasource.dart** y **domain/repositories/video_posts_repository.dart** declaran contratos para las fuentes y el repositorio.

### Infraestructura

- **infrastructure/datasources/** contiene las fuentes Cover, Pixabay y Internet Archive, el datasource local y LocalStorageService.
- **infrastructure/models/local_video_model.dart** convierte los mapas de publicaciones locales en entidades.
- **infrastructure/repositories/video_posts_repository_impl.dart** delega la carga a un datasource.
- **LocalStorageService** usa SharedPreferences y una caché en memoria para favoritos y videos vistos.

La implementación principal usa datos remotos. Cloudinary entrega un catálogo de URLs de demostración. Pixabay y Cover permiten consultar sus endpoints si se les proporciona una clave; su argumento apiKey tiene valor inicial vacío y main.dart no les pasa claves, por lo que la configuración actual devuelve los catálogos estáticos de ejemplo. El datasource local y los ocho posts locales existen en código, pero no son los repositorios registrados en main.dart.

### Configuración y recursos

- **config/theme/** define los cuatro temas y selecciona una temporada automáticamente según la fecha; permite también elegirla desde la interfaz.
- **config/helpers/** contiene el cálculo aleatorio de métricas y el formato abreviado de números.
- **android/app/** integra MainActivity, DateChangeReceiver y aliases de icono estacionales.
- **assets/** contiene capturas de evidencia para la documentación de la práctica; no son recursos usados por la aplicación ni están declaradas en pubspec.yaml.
- **lib/assets/audio/** contiene MP3 de la aplicación, declarados en pubspec.yaml.
- **architecture/** incluye dos diagramas de arquitectura en PNG y sus fuentes HTML/JSON. El diagrama de Provider local representa una propuesta inicial; el diagrama Clean Code describe la separación usada en la app.

## Dependencias principales

| Paquete | Responsabilidad en el código |
|---|---|
| provider | Inyección de estado reactivo con ChangeNotifierProvider |
| video_player | Control y reproducción de videos locales o de red |
| audioplayers | Reproducción de los sonidos declarados |
| dio | Cliente HTTP para los datasources remotos |
| shared_preferences | Persistencia local de favoritos e historial |
| animate_do | Transiciones de la pantalla de bienvenida |
| intl | Formateo internacionalizado |
| cupertino_icons | Iconografía complementaria |

Flutter y flutter_test provienen del SDK. flutter_lints está en dependencias de desarrollo. Las versiones están fijadas por **pubspec.yaml** y **pubspec.lock**.

## Instalación, ejecución y Android

Desde la raíz del repositorio:

~~~powershell
cd Practica_04/tok_tik
flutter pub get
flutter run
~~~

Para compilar Android en modo debug:

~~~powershell
flutter build apk --debug
~~~

La configuración inspeccionada usa JDK 17, Android Gradle Plugin 9.1.0, Kotlin 2.4.0 y Gradle 9.3.1. El identificador Android definido es **com.example.tok_tik**. Consulta [appetize/INSTRUCCIONES.md](appetize/INSTRUCCIONES.md) para subir y compartir un APK de demostración.

## Pruebas y evidencias

**test/widget_test.dart** contiene cuatro casos: renderizado del tema, límites de métricas generadas, serialización de VideoPost y operaciones de favoritos/videos vistos. La existencia del código de prueba no indica que se haya ejecutado ni aprobado en esta actualización.

Las imágenes de **assets/** son evidencias visuales de la práctica y se organizan así; no forman parte de los recursos de ejecución de la app:

- **Iconos/** contiene las variantes de Normal (`N`), Halloween (`H`), Navidad (`NV`) y San Valentín (`SV`). El número identifica el uso: `1` icono mostrado en el móvil, `2` icono de la aplicación y `3` icono de carga.
- **Opciones/Fecha/** (`FH.jpeg`, `FN.jpeg`, `FNV.jpeg`, `FSV.jpeg`) muestra el cambio de tema según la fecha y el tema activo.
- **Opciones/Fuente/** (`Aleatorio.jpeg`, `Local.jpeg`, `Cover.jpeg`, `Pixabay.jpeg`, `InternetArchive.jpeg`) muestra la selección de la fuente de videos.
- **Opciones/Tema/** documenta la elección del tema (`1`) y el tema seleccionado (`2`), con variantes para las temporadas disponibles.
- **Videos/** muestra Discover o For You según la fuente indicada en el nombre del archivo. Las fuentes representadas son Aleatorio, Local, Cover, Pixabay e Internet Archive. `Like.jpeg`, `Mute.jpeg` y `Pause.jpeg` evidencian las acciones de dar me gusta, silenciar y pausar.

### Evidencias visuales

Las capturas siguientes se muestran directamente desde sus carpetas originales. En **Iconos**, `1` corresponde al icono en el móvil, `2` al icono de la aplicación y `3` al icono de carga.

#### Iconos por temporada

| Normal | Halloween | Navidad | San Valentín |
|---|---|---|---|
| <img src="assets/Iconos/N1.jpeg" width="150" alt="Icono Normal en el móvil"> | <img src="assets/Iconos/H1.jpeg" width="150" alt="Icono Halloween en el móvil"> | <img src="assets/Iconos/NV1.jpeg" width="150" alt="Icono Navidad en el móvil"> | <img src="assets/Iconos/SV1.jpeg" width="150" alt="Icono San Valentín en el móvil"> |
| **1 — Móvil** | **1 — Móvil** | **1 — Móvil** | **1 — Móvil** |
| <img src="assets/Iconos/N2.jpeg" width="150" alt="Icono Normal de la aplicación"> | <img src="assets/Iconos/H2.jpeg" width="150" alt="Icono Halloween de la aplicación"> | <img src="assets/Iconos/NV2.jpeg" width="150" alt="Icono Navidad de la aplicación"> | <img src="assets/Iconos/SV2.jpeg" width="150" alt="Icono San Valentín de la aplicación"> |
| **2 — Aplicación** | **2 — Aplicación** | **2 — Aplicación** | **2 — Aplicación** |
| <img src="assets/Iconos/N3.jpeg" width="150" alt="Pantalla de carga Normal"> | <img src="assets/Iconos/H3.jpeg" width="150" alt="Pantalla de carga Halloween"> | <img src="assets/Iconos/NV3.jpeg" width="150" alt="Pantalla de carga Navidad"> | <img src="assets/Iconos/SV3.jpeg" width="150" alt="Pantalla de carga San Valentín"> |
| **3 — Carga** | **3 — Carga** | **3 — Carga** | **3 — Carga** |

#### Cambio de tema por fecha

| Halloween | Normal | Navidad | San Valentín |
|---|---|---|---|
| <img src="assets/Opciones/Fecha/FH.jpeg" width="180" alt="Tema Halloween activado por fecha"> | <img src="assets/Opciones/Fecha/FN.jpeg" width="180" alt="Tema Normal activado por fecha"> | <img src="assets/Opciones/Fecha/FNV.jpeg" width="180" alt="Tema Navidad activado por fecha"> | <img src="assets/Opciones/Fecha/FSV.jpeg" width="180" alt="Tema San Valentín activado por fecha"> |

#### Selección de fuente de videos

| Aleatorio | Local | Cover | Pixabay | Internet Archive |
|---|---|---|---|---|
| <img src="assets/Opciones/Fuente/Aleatorio.jpeg" width="150" alt="Fuente de videos Aleatorio"> | <img src="assets/Opciones/Fuente/Local.jpeg" width="150" alt="Fuente de videos Local"> | <img src="assets/Opciones/Fuente/Cover.jpeg" width="150" alt="Fuente de videos Cover"> | <img src="assets/Opciones/Fuente/Pixabay.jpeg" width="150" alt="Fuente de videos Pixabay"> | <img src="assets/Opciones/Fuente/InternetArchive.jpeg" width="150" alt="Fuente de videos Internet Archive"> |

#### Elección del tema

| Halloween | Normal | Navidad | San Valentín |
|---|---|---|---|
| <img src="assets/Opciones/Tema/H1.jpeg" width="180" alt="Selector de tema Halloween"> | <img src="assets/Opciones/Tema/N1.jpeg" width="180" alt="Selector de tema Normal"> | <img src="assets/Opciones/Tema/NV1.jpeg" width="180" alt="Selector de tema Navidad"> | <img src="assets/Opciones/Tema/SV1.jpeg" width="180" alt="Selector de tema San Valentín"> |

| Tema Halloween seleccionado | Tema Normal seleccionado | Tema San Valentín seleccionado |
|---|---|---|
| <img src="assets/Opciones/Tema/H2.jpeg" width="180" alt="Tema Halloween seleccionado"> | <img src="assets/Opciones/Tema/N2.jpeg" width="180" alt="Tema Normal seleccionado"> | <img src="assets/Opciones/Tema/SV2.jpeg" width="180" alt="Tema San Valentín seleccionado"> |

#### Feeds e interacciones de video

| Fuente | Evidencia Discover | Evidencia For You |
|---|---|---|
| Aleatorio | <img src="assets/Videos/AleatorioDiscover.jpeg" width="180" alt="Discover con fuente Aleatorio"> | <img src="assets/Videos/AleatorioForYou.jpeg" width="180" alt="Discover con fuente Aleatorio"> |
| Local | <img src="assets/Videos/LocalDiscover.jpeg" width="180" alt="Discover con fuente Local"> | <img src="assets/Videos/LocalForYou.jpeg" width="180" alt="For You con fuente Local"> |
| Cover | <img src="assets/Videos/CoverDiscover.jpeg" width="180" alt="Discover con fuente Cover"> | <img src="assets/Videos/ForyouCover.jpeg" width="180" alt="For You con fuente Cover"> |
| Pixabay | <img src="assets/Videos/PixabayDiscover.jpeg" width="180" alt="Discover con fuente Pixabay"> | <img src="assets/Videos/ForYouPixabay.jpeg" width="180" alt="For You con fuente Pixabay"> |
| Internet Archive | <img src="assets/Videos/InternetArchiveDiscover.jpeg" width="180" alt="Discover con fuente Internet Archive"> | <img src="assets/Videos/InternetArchiveForYou.jpeg" width="180" alt="For You con fuente Internet Archive"> |

| Me gusta | Silencio | Pausa |
|---|---|---|
| <img src="assets/Videos/Like.jpeg" width="180" alt="Video con me gusta"> | <img src="assets/Videos/Mute.jpeg" width="180" alt="Video silenciado"> | <img src="assets/Videos/Pause.jpeg" width="180" alt="Video pausado"> |

El [README](README.md#evidencias-de-funcionamiento) también inserta siete capturas independientes de **appetize/imagenes/**. Estas muestran una sesión de Appetize.io con Pixel 7 y Android 13; no demuestran por sí solas que todos los flujos funcionen en cualquier dispositivo ni garantizan que la demo siga accesible.

## Limitaciones conocidas

- Los posts locales hacen referencia a **assets/videos/1.mp4** hasta **assets/videos/8.mp4**, pero esos archivos no están en el checkout ni declarados como recursos en pubspec.yaml.
- Los feeds iniciales de la app son remotos. La reproducción requiere conectividad y disponibilidad de las URLs configuradas en los catálogos de ejemplo.
- Pixabay y Cover tienen modo de consulta con API key opcional, pero la inicialización actual no proporciona esas claves.
- El enlace de Appetize puede depender de permisos, sesión y disponibilidad del build.
- No se ejecutaron pruebas automatizadas ni una sesión de Appetize como parte de esta actualización documental.


## Referencias del repositorio

- **Diagrama de arquitectura Clean Code:** [abrir imagen PNG](architecture/diagrama_clean_code.png) · [ver fuente HTML](architecture/diagrama_clean_code.html)

  [![Diagrama de arquitectura Clean Code](architecture/diagrama_clean_code.png)](architecture/diagrama_clean_code.png)

- **Diagrama inicial con Provider local:** [abrir imagen PNG](architecture/diagrama_provider_local.png) · [ver fuente HTML](architecture/diagrama_provider_local.html)

  [![Diagrama inicial con Provider local](architecture/diagrama_provider_local.png)](architecture/diagrama_provider_local.png)

- [Instrucciones de Appetize.io](appetize/INSTRUCCIONES.md)
- [README de Appetize.io](appetize/README.md)