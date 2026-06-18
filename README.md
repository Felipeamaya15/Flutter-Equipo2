# Productora Intercultural SpA — App de Gestión de Solicitudes

Aplicación móvil/web desarrollada en Flutter para la gestión interna de solicitudes de eventos de la empresa Productora Intercultural SpA. Permite a los trabajadores administrar solicitudes, revisar el cronograma de eventos y generar reportes en PDF.

----------------------------------------------------------------------------------

## Tabla de Contenidos

1. [Descripción general](#descripción-general)
2. [Tecnologías y librerías](#tecnologías-y-librerías)
3. [Backend: Firebase](#backend-firebase)
4. [Cómo conectarse al backend](#cómo-conectarse-al-backend)
5. [Cómo levantar la aplicación](#cómo-levantar-la-aplicación)
6. [Estructura del proyecto](#estructura-del-proyecto)
7. [Funcionalidades principales](#funcionalidades-principales)

------------------------------------------------------------------------------

## Descripción General

La app está orientada al uso interno de los trabajadores de la productora. Las funcionalidades principales son:

- Autenticación de trabajadores con correo y contraseña.
- Dashboard con resumen de solicitudes activas y eventos de la semana.
- Bandeja de solicitudes con cambio de estado (Pendiente / En proceso / Completado).
- Cronograma de eventos ordenado por fecha.
- Generación de reportes PDF de solicitudes.
- Nueva solicitud de evento desde la app.

----------------------------------------------------------------------------------------

## Tecnologías y Librerías

|         Librería        |   Versión   |                    Uso                    |
|-------------------------|-------------|-------------------------------------------|
|      `flutter` SDK      |  `^3.11.5`  | Framework principal                       |
|     `firebase_core`     |  `^4.7.0`   | Inicialización de Firebase                |
|     `firebase_auth`     |  `^6.5.1`   | Autenticación de usuarios                 |
|   `cloud_firestore`     |  `^6.4.0`   | Base de datos en tiempo real              |
|       `provider`        | `^6.1.5+1`  | Manejo de estado global                   |
|         `intl`          |  `^0.20.2`  | Formateo de fechas y localización         |
| `flutter_localizations` | SDK Flutter | Soporte multilenguaje                     |
|     `google_fonts`      |  `^8.1.0`   | Tipografías personalizadas                |
|          `pdf`          |  `^3.12.0`  | Generación de documentos PDF              |
|       `printing`        |  `^5.14.3`  | Impresión y exportación de PDFs           |
|         `uuid`          |  `^4.5.3`   | Generación de IDs únicos para solicitudes |
|   `cupertino_icons`     |  `^1.0.8`   | Íconos estilo iOS                         |

*Dev dependencies:*

|    Librería     |   Versión   |        Uso        |
|-----------------|-------------|-------------------|
|  `flutter_test` | SDK Flutter |      Testing      |
| `flutter_lints` |  `^6.0.0`   | Reglas de linting |

---------------------------------------------------------------------------------------

## Backend: Firebase

El proyecto utiliza Firebase como backend-as-a-service. No existe un servidor propio; toda la lógica de datos y autenticación se gestiona a través de los servicios de Firebase.

### Servicios utilizados

#### Firebase Authentication
- Método de acceso: correo electrónico y contraseña.
- Los usuarios son creados manualmente desde la consola de Firebase.
- Proyecto Firebase: `aplicaciones-moviles-cc5a6`

#### Cloud Firestore
- Base de datos NoSQL en tiempo real.
- Colección principal: `solicitudes`
- Cada documento en `solicitudes` contiene los siguientes campos:

|            Campo            |      Tipo      |                        Descripción                       |
|-----------------------------|----------------|----------------------------------------------------------|
|          `folio`            |     String     | Número de folio único de la solicitud                    |
|       `emailCliente`        |     String     | Correo del cliente                                       |
|       `nombreCliente`       |     String     | Nombre del cliente                                       |
|   `nombreContactoEmpresa`   |     String     | Contacto de la empresa                                   |
|    `direccionComercial`     |     String     | Dirección del evento                                     |
|        `lugarEvento`        |     String     | Lugar específico del evento                              | 
|        `fechaEvento`        |   Timestamp    | Fecha y hora del evento                                  |
|         `horaInicio`        |     String     | Hora de inicio (formato HH:mm)                           |
|        `horaTermino`        |     String     | Hora de término (formato HH:mm)                          |
|    `cantidadAsistentes`     |     Number     | Número de asistentes                                     |
|      `formatoServicio`      |     String     | Tipo de servicio (ej: Banquetería Completa)              |
|        `giroEmpresa`        |     String     | Giro de la empresa cliente                               |
|    `detallesEspeciales`     |     String     | Observaciones adicionales                                |
|          `estado`           |     String     | Estado: `Pendiente`, `En proceso`, `Completado`          |
|         `creado_en`         |   Timestamp    | Fecha de creación del registro                           |
|        `nombreEvento`       |     String     | Tipo de evento (ej: Matrimonio, Evento Corporativo)      |
|        `rutCliente`         |     String     | RUT del cliente (formato XX.XXX.XXX-X)                   |
|      `telefonoCliente`      |     String     | Teléfono de contacto del cliente                         |
|        `tipoCliente`        |     String     | Tipo de cliente (ej: Empresa, Particular)                |
|        `tipoEspacio`        |     String     | Tipo de espacio (ej: Aire Libre, Interior)               |
|      `preferenciaMenu`      | Array\<String> | Lista de preferencias de menú (ej: Fusión Intercultural) |
| `restriccionesAlimentarias` |      Map       | Restricciones alimentarias de los asistentes             |
|       `giroEmpresa`         |     String     | Giro de la empresa cliente                               |
|     `usuarioAsignado`       |     String     | Nombre del trabajador asignado a la solicitud            |
-----------------------------------------------------------------------------------------------------------

## Cómo Conectarse al Backend

El proyecto ya viene configurado con las credenciales de Firebase. Los archivos de configuración están incluidos en el repositorio:

- `firebase.json` — Configuración general del proyecto Firebase.
- `lib/firebase_options.dart` — Opciones de inicialización por plataforma (generado por FlutterFire CLI).
- `android/app/google-services.json` — Credenciales para Android (generado automáticamente al correr `flutterfire configure`).

### Datos del proyecto Firebase

|        Campo       |           Valor                                |
|====================|================================================|
|     Project ID     | `aplicaciones-moviles-cc5a6`                   | 
|   App ID Android   | `1:613070071056:android:5b83679f9b1f91da8ef195`| 
|  App ID iOS/macOS  | `1:613070071056:ios:fb2cd8389698105c8ef195`    |
|     App ID Web     | `1:613070071056:web:279efe5c1d79a1ac8ef195`    |
|   App ID Windows   | `1:613070071056:web:4114bf2d71cf2f448ef195`    |

No es necesario configurar Firebase manualmente. Al clonar el repositorio y correr el proyecto, la app se conectará automáticamente al proyecto Firebase ya configurado.

-----------------------------------------------------------------

## Cómo Levantar la Aplicación

### Prerrequisitos

Primeramente hay que tener instalado lo siguiente:

- [Flutter SDK](https://docs.flutter.dev/get-started/install) versión `3.11.5` o superior
- Dart SDK `^3.11.5` (incluido al instalar Flutter)
- Un editor: [VS Code](https://code.visualstudio.com/) con extensión Flutter, o Android Studio
- Git

Verificar instalación:
- flutter doctor

### Pasos para levantar el proyecto

*1. Clonar el repositorio*

- git clone https://github.com/Felipeamaya15/Flutter-Equipo2.git
- cd Flutter-Equipo2


*2. Instalar dependencias*

- flutter pub get


*3. Ejecutar la aplicación*

Para web:

- flutter run -d chrome


Para Android (requiere emulador o dispositivo conectado):

- flutter run -d android

Para listar dispositivos disponibles:

- flutter devices


### Credenciales de prueba

Para acceder a la app, usar algunas de las cuentas registradas en Firebase Authentication:

|          Correo            |    Contraseña   |
|============================|=================|
| developer@productora.com   | 123456          |
| trabajador3@productora.com | 123456          |


------------------------------------------------------

### Estructura del Proyecto

lib/
├── core/
│   ├── firebase/
│   │   └── firebase_collections.dart     # Constantes con los nombres de las colecciones de Firestore
│   ├── routes/
│   │   └── app_routes.dart               # Rutas de la app y AuthWrapper (redirige según sesión activa)
│   └── utils/
│       └── validators.dart               # Validadores de RUT, email, teléfono y fecha futura
│
├── features/
│   ├── auth/                             # Módulo de autenticación
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   └── firebase_auth_datasource.dart   # Llamadas directas a FirebaseAuth (login, registro, recuperar/cambiar contraseña)
│   │   │   └── repositories/
│   │   │       └── auth_repository_impl.dart        # Implementación del repositorio: conecta datasource con dominio
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── app_user.dart                    # Entidad usuario (uid + email)
│   │   │   └── repositories/
│   │   │       └── auth_repository.dart             # Interfaz del repositorio de autenticación
│   │   └── presentation/
│   │       └── providers/
│   │           └── auth_provider.dart               # Provider: expone recuperar y cambiar contraseña a la UI
│   │
│   ├── dashboard/                        # Módulo del panel de trabajadores
│   │   └── presentacion/
│   │       ├── pages/
│   │       │   ├── worker_dashboard_page.dart       # Pantalla principal: dashboard, bandeja de solicitudes y agenda
│   │       │   └── generar_reporte_dialog.dart      # Diálogo para generar y descargar reporte PDF de solicitudes
│   │       ├── providers/
│   │       │   └── solicitudes_provider.dart        # Provider: stream en tiempo real de solicitudes desde Firestore
│   │       └── viewmodels/
│   │           └── report_viewmodel.dart            # ViewModel: calcula métricas (estados, asignaciones, eventos por mes)
│   │
│   └── solicitudes/                      # Módulo de solicitudes de cotización
│       ├── data/
│       │   ├── datasources/
│       │   │   ├── solicitud_remote_datasource.dart  # Escritura de solicitudes en Firestore
│       │   │   └── solicitud_mock_datasource.dart    # Datasource en memoria para tests (sin Firebase)
│       │   ├── models/
│       │   │   └── solicitud_model.dart              # Modelo de datos: serializa/deserializa Solicitud a/desde Firestore
│       │   └── repositories/
│       │       └── solicitud_repository_impl.dart    # Implementación del repositorio de solicitudes
│       ├── domain/
│       │   ├── entities/
│       │   │   ├── solicitud.dart                    # Entidad base de solicitud (id, email, teléfono, fecha, estado)
│       │   │   └── cotizacion.dart                   # Entidad cotización con campos extendidos (evento, encargado)
│       │   └── repositories/
│       │       └── solicitud_repository.dart         # Contrato (interfaz) del repositorio de solicitudes
│       └── presentation/
│           ├── pages/
│           │   ├── login_page.dart                   # Pantalla de inicio de sesión con recuperación de contraseña
│           │   ├── solicitud_form_page.dart           # Pantalla contenedora del formulario (crear formulario o ver el detalle del formulario)
│           │   └── confirmation_page.dart             # Pantalla de confirmación tras enviar solicitud + descarga PDF
│           └── widgets/
│               ├── reusable_solicitud_form.dart       # Formulario paso a paso con validaciones completas
│               └── cotizacion_document_view.dart      # Vista de solo lectura de una cotización existente
│
├── firebase_options.dart                 # Configuración de Firebase por plataforma
└── main.dart                             # Punto de entrada: inicializa Firebase, providers y tema de la app



--------------------------------------------------------------------------

### Funcionalidades Principales

|     Pantalla    |                       Descripción                                   |
|=================|=====================================================================|
|      Login      | Acceso para trabajadores con correo y contraseña vía Firebase Auth  | 
|    Dashboard    | Muestra solicitudes activas, eventos de la semana y próximos eventos|
|   Solicitudes   | Bandeja con todas las solicitudes; permite cambiar su estado        |
|      Agenda     | Cronograma de eventos ordenado por fecha                            |
| Nueva Solicitud | Formulario para registrar una nueva solicitud de evento             |
|   Reporte PDF   | Generación y exportación de reporte en PDF                          |

-----------------------------------------------------------------------------------------
