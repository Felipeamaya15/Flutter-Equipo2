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

## 🛠️ Stack Tecnológico
* **Framework:** Flutter (Channel Stable).
* **Red:** Dio / Http con interceptores para manejo de tokens.
* **Calidad:** Reglas estrictas de linter en `analysis_options.yaml`.
* **Gestión:** Jira (Metodología Scrum).

---

## 🚦 Flujo de Git (Reglas del Encargado)
Para mantener el orden en el repositorio, todos los miembros deben seguir estas normas:

1.  **Ramas:** Prohibido hacer push directo a `main`.
2.  **Naming:** Las ramas deben seguir el formato `feature/nombre-de-la-tarea`.
3.  **Pull Requests (PR):** Todo cambio debe pasar por una revisión de código (Code Review) y cumplir con el *Definition of Done* (linter aprobado y compilación exitosa).

---

## 💻 Instalación y Uso
1. Clonar el repositorio:
   ```bash
   git clone [https://github.com/Felipeamaya15/Flutter-Equipo2.git](https://github.com/Felipeamaya15/Flutter-Equipo2.git)