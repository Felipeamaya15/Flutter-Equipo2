# Proyecto Flutter - Equipo 2 🚀

Este repositorio contiene la base técnica de la aplicación móvil del **Equipo 2**, estructurada según el Plan de Organización definido en el **Sprint 0**. La arquitectura está diseñada para ser escalable, mantenible y facilitar el trabajo en paralelo.

## 🏗️ Arquitectura: Feature-First
Siguiendo los lineamientos del equipo, utilizamos un enfoque orientado a funcionalidades. Cada módulo dentro de `lib/features/` se divide en:

* **Presentation:** UI Widgets y gestión de estado.
* **Domain:** Entidades de negocio y contratos (interfaces).
* **Data:** Implementaciones de repositorios, DTOs (modelos de API) y mappers.

---

## 📁 Estructura del Repositorio
La organización de carpetas en `lib/` es la siguiente:

| Carpeta | Descripción |
| :--- | :--- |
| `app/` | Configuración global (Router, Temas, Inyección de Dependencias). |
| `core/` | Infraestructura: Cliente HTTP, interceptores y manejo de errores. |
| `features/` | Módulos por funcionalidad (ej: auth, inventory, home). |
| `shared/` | Widgets reutilizables y constantes del Sistema de Diseño. |
| `contracts/` | Modelos y acuerdos para la integración con APIs externas. |
| `env/` | Configuración de ambientes (Dev, QA, Prod). |

---

🛠️ Stack Tecnológico
Framework: Flutter (Channel Stable).

Backend: Firebase (Auth, Firestore, Cloud Functions).

Red: Dio / Http con interceptores para manejo de tokens.

Calidad: Reglas estrictas de linter en analysis_options.yaml.

Gestión: Jira (Metodología Scrum).

🚦 Flujo de Git & Entornos
Para garantizar la estabilidad del producto, el equipo trabajará bajo un esquema de tres ramas principales que segmentan el ciclo de vida del desarrollo:

dev (Desarrollo): Rama base para los desarrolladores. Aquí se integran las nuevas funcionalidades (feature/*) una vez terminadas. Es un entorno de integración continua.

qa (Testing): Rama destinada exclusivamente al equipo de QA. Una vez que una versión en dev es estable, se despliega a esta rama para pruebas de regresión, estrés y validación de historias de usuario.

main (Producción): Contiene únicamente código que ha sido aprobado por QA. Es la versión oficial y estable de la aplicación lista para distribución.

Reglas del Encargado:
Prohibido: Hacer push directo a main o qa.

Naming: Las ramas temporales deben seguir el formato feature/nombre-de-la-tarea.

Pull Requests (PR): Todo cambio debe pasar por una revisión de código (Code Review) y cumplir con el Definition of Done (linter aprobado y compilación exitosa).

Promoción de Código: El paso de dev a qa y de qa a main requiere la aprobación formal del encargado y el equipo de calidad.

---

## 💻 Instalación y Uso
1. Clonar el repositorio:
   ```bash
   git clone [https://github.com/Felipeamaya15/Flutter-Equipo2.git](https://github.com/Felipeamaya15/Flutter-Equipo2.git)
