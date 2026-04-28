# 🥛 Recojo de Leche — Prototipo Flutter

Aplicación móvil **offline-first** para la gestión del recojo de leche en zonas rurales con baja conectividad.

---

## 📦 Características implementadas

| Módulo | Estado |
|---|---|
| Autenticación simulada (login) | ✅ |
| Sesión persistente (SharedPreferences) | ✅ |
| Manejo básico de roles (Administrador / Acopiador) | ✅ |
| Registro de recolecciones con UUID | ✅ |
| Validaciones de calidad (litros, temperatura, densidad) | ✅ |
| Almacenamiento offline en SQLite | ✅ |
| Historial de registros con estado visual | ✅ |
| Sincronización simulada (con delay de red) | ✅ |
| Ruta del día asociada al registro | ✅ |
| GPS simulado | ✅ |

---

## 🛠️ Requisitos

- **Flutter SDK** 3.10 o superior ([instalación](https://docs.flutter.dev/get-started/install))
- **Android Studio** (Hedgehog o superior recomendado)
- **JDK 17** (incluido con Android Studio)
- Un **emulador Android** o un **dispositivo físico** con depuración USB activada

Verifica que todo esté correcto con:

```bash
flutter doctor
```

---

## ▶️ Cómo ejecutar el proyecto

### Opción 1 — Desde Android Studio

1. Descomprime el proyecto y abre la carpeta `recojo_leche` en Android Studio.
2. Espera a que se descarguen las dependencias (`pub get` se ejecuta automáticamente).
3. Si no se ejecuta solo, abre la terminal integrada y corre:
   ```bash
   flutter pub get
   ```
4. Conecta un dispositivo o inicia un emulador Android.
5. Presiona el botón ▶️ **Run** o usa `Shift + F10`.

### Opción 2 — Desde la terminal

```bash
cd recojo_leche
flutter pub get
flutter run
```

### 🔑 Usuarios de prueba

| Usuario | Contraseña | Rol |
|---|---|---|
| `admin` | `1234` | Administrador |
| `acopiador` | `1234` | Acopiador |
| `maria` | `1234` | Acopiador |

---

## 📂 Estructura del proyecto

```
lib/
├── main.dart                          # Punto de entrada y tema visual
├── modelos/
│   ├── recoleccion.dart               # Modelo de una recolección
│   └── usuario.dart                   # Modelo del usuario logueado
├── servicios/
│   ├── base_datos.dart                # SQLite (sqflite)
│   ├── servicio_autenticacion.dart    # Login mock + sesión persistente
│   └── servicio_sincronizacion.dart   # Sincronización simulada
├── pantallas/
│   ├── pantalla_login.dart
│   ├── pantalla_menu.dart             # Menú principal con roles
│   ├── pantalla_registro.dart         # Formulario CORE de registro
│   ├── pantalla_historial.dart        # Lista con estado visual
│   └── pantalla_sincronizacion.dart   # Botón "Sincronizar"
└── utiles/
    └── datos_predefinidos.dart        # Lista de productores y ruta
```

---

## 💾 Cómo funciona el almacenamiento offline

La app usa **SQLite** a través del paquete `sqflite`, ideal para Android porque:

- Es nativo del sistema operativo (no requiere instalar nada extra).
- Funciona **completamente sin internet**.
- Es muy ligero, perfecto para dispositivos de gama baja.

**Flujo:**

1. Cuando el usuario presiona **Guardar** en el formulario de registro, se crea un objeto `Recoleccion` con un **UUID único** (`uuid` package).
2. Ese objeto se inserta en la tabla `recolecciones` de la base de datos local con estado `"pendiente"`.
3. La pantalla de **Historial** lee directamente de SQLite con `obtenerTodas()`, ordenado por fecha descendente.
4. Los datos persisten incluso si el usuario cierra la app o reinicia el teléfono.

**Tabla creada:**

```sql
CREATE TABLE recolecciones (
  id TEXT PRIMARY KEY,        -- UUID único
  nombreProductor TEXT,
  litros REAL,
  fechaHora TEXT,             -- ISO 8601
  latitud REAL,
  longitud REAL,
  temperatura REAL,
  densidad REAL,
  observaciones TEXT,
  estado TEXT,                -- "pendiente" | "sincronizado"
  ruta TEXT
);
```

La sesión del usuario se guarda aparte en **SharedPreferences**, así no tiene que loguearse cada vez que abre la app.

---

## 🔄 Cómo se simula la sincronización

No hay backend real. La sincronización se simula así:

1. El usuario presiona el botón **"SINCRONIZAR AHORA"** en la pantalla de sincronización.
2. El `ServicioSincronizacion` consulta la BD local: `SELECT * WHERE estado = 'pendiente'`.
3. Se aplica un **delay artificial de 2 segundos** con `Future.delayed`, simulando una llamada de red.
4. Cada registro pendiente se actualiza a estado `"sincronizado"` mediante `marcarComoSincronizada(id)`.
5. El UUID generado al momento del registro **garantiza idempotencia**: si en un sistema real el servidor recibiera dos veces el mismo registro (por ejemplo, por reintentos de red), lo reconocería por su ID y no lo duplicaría.

Visualmente, en el historial:
- 🟠 **Naranja + ícono de nube tachada** → registro pendiente
- 🟢 **Verde + ícono de nube con check** → registro sincronizado

---

## 🎨 Decisiones de diseño UX (entorno rural)

- **Botones grandes (mínimo 56 px de alto)** para ser fáciles de presionar incluso con dedos sucios o gruesos.
- **Tipografía grande** (mínimo 16 px en cuerpo, 18-22 en títulos).
- **Iconos antes que texto** cada vez que es posible.
- **Pocos campos por pantalla**, agrupados con etiquetas claras.
- **Colores con buen contraste** (verde fuerte sobre fondo claro).
- **Mensajes en español, sin tecnicismos** ("Pendiente" / "Sincronizado", no "syncing").
- **Validaciones que explican el problema en lenguaje simple**: por ejemplo, ante densidad baja se indica "Posible adulteración con agua".

---

## 🔍 Validaciones implementadas

| Campo | Regla | Acción |
|---|---|---|
| Litros | Debe ser > 0 | Bloquea el guardado |
| Temperatura | Si > 10°C | Muestra alerta amarilla, permite guardar con confirmación |
| Densidad | Si < 1.028 g/mL | Muestra alerta de **posible adulteración**, permite guardar con confirmación |
| Productor | Obligatorio | Bloquea el guardado |

---

## 🧪 Cómo probar el flujo completo

1. Inicia sesión con `acopiador` / `1234`.
2. Toca **NUEVA RECOLECCIÓN** y completa el formulario.
3. Prueba meter **densidad = 1.020** → verás la alerta de adulteración.
4. Guarda algunos registros más.
5. Ve a **HISTORIAL** → todos aparecen 🟠 pendientes.
6. Toca un item → se abre el detalle con todos los datos.
7. Vuelve al menú y entra a **SINCRONIZAR**.
8. Presiona **SINCRONIZAR AHORA** → verás el delay de 2 segundos.
9. Vuelve al historial → ahora todos están 🟢 sincronizados.
10. Cierra la app totalmente y reábrela → la sesión sigue activa y los datos siguen ahí.

---

## 🚫 Limitaciones del prototipo (conocidas)

- No hay backend real (sincronización es simulada).
- GPS está hardcodeado (en producción se usaría `geolocator`).
- Roles muy básicos: el rol no restringe pantallas, solo personaliza el saludo.
- No hay edición ni eliminación de registros (solo lectura tras crear).

Todas estas son extensiones naturales que se pueden agregar manteniendo la misma arquitectura.
