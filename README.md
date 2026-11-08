# SDTactical

Tienda de equipamiento de airsoft. Trabajo Práctico N.º 2 de Programación IV: integración de un back-end Rails con un front-end moderno.

| | |
| --- | --- |
| Temática | Catálogo de productos de airsoft y pedidos de clientes |
| Integrantes | Stefano De Minicis |
| Modalidad | Individual |
| Autor del back-end original (TP 1) | Stefano De Minicis |
| Back-end | Ruby on Rails 8.1 (API JSON en `/api/v1` + back-office con vistas en `/admin`), SQLite |
| Front-end | React 19 + Vite + React Router, en [`frontend/`](frontend/) (repositorio independiente: <https://github.com/stefudemi/SDTactical-frontend>) |
| Contrato de la API | [API_CONTRACT.md](API_CONTRACT.md) |

El back-office Rails (`/admin`) sigue funcionando y es independiente de la interfaz del usuario final.

## Funcionalidades

- **Usuario final (React):** catálogo con búsqueda y filtro por categoría, detalle de producto, carrito persistente, registro, inicio y cierre de sesión, confirmación de pedido, historial y cancelación de pedidos pendientes, edición de datos de la cuenta.
- **Estados de interfaz:** carga, ausencia de resultados, error con reintento, confirmaciones, validación de formularios con los errores devueltos por la API, botones deshabilitados durante el envío, navegación por teclado y diseño adaptable a pantallas pequeñas.
- **Administración (Rails):** CRUD de productos, categorías, pedidos y usuarios.
- **Evolución del back-end en el TP 2:** `GET /categories`, filtros `q` y `category_id` en `/products`, `PATCH /profile`, `POST /orders/:id/cancel` (devuelve el stock), validaciones de usuario (nombre, email, contraseña de 6+ caracteres), errores JSON en español y CORS con `PATCH`.

## Requisitos

- Ruby 3.4.7 (ver `.ruby-version`; la suite también pasa con Ruby 4.0) y Bundler
- SQLite 3
- Node.js 24 o compatible y npm

## Instalación y ejecución

Back-end:

```sh
bundle install
bin/rails db:prepare
bin/rails db:seed
bin/rails server        # http://localhost:3000
```

Front-end (en otra terminal):

```sh
cd frontend
npm install
npm run dev             # http://localhost:5173
```

### Variables de entorno (sin secretos)

| Variable | Proyecto | Por defecto | Uso |
| --- | --- | --- | --- |
| `FRONTEND_ORIGIN` | Back-end | `http://localhost:5173` | Origen permitido por CORS |
| `VITE_API_URL` | Front-end | `http://localhost:3000/api/v1` | URL base de la API (ver `frontend/.env.example`) |

Si el front-end se publica en otra URL, definir `FRONTEND_ORIGIN` en el back-end con ese origen exacto.

## Datos de prueba

`bin/rails db:seed` crea categorías y productos de ejemplo y, **solo en desarrollo**, dos usuarios locales:

| Rol | Email | Contraseña |
| --- | --- | --- |
| Administrador (back-office `/admin`) | `admin@sdtactical.test` | `dev-password-123` |
| Cliente (front-end) | `cliente@sdtactical.test` | `demo-password-123` |

Los clientes también pueden crearse desde el formulario "Crear cuenta" del front-end. Los administradores solo se crean por seed o desde el back-office. No son cuentas reales.

## Pruebas y controles de calidad

```sh
bin/rails test                  # back-end: modelos, back-office, API y jobs
bin/rubocop
bin/brakeman --no-pager
bin/bundler-audit               # auditoría de gemas

cd frontend
npm test                        # front-end: Vitest + Testing Library (API simulada)
npm run build                   # compilación de producción
```

Las pruebas del front-end usan respuestas simuladas; la demostración integrada usa la API real. Incluyen interacciones relevantes (carrito, inicio de sesión, confirmación y cancelación de pedidos) y casos de error (catálogo caído, credenciales inválidas, stock insuficiente, sesión vencida, producto inexistente).

## Estructura

```
app/controllers/api/v1/   API JSON (autenticación Bearer)
app/controllers/admin/    back-office
app/services/orders/      creación y cancelación de pedidos
frontend/src/             pages/, components/, context/ y api.js
```

## Despliegue

No se realizó despliegue. Si se publica, verificar `FRONTEND_ORIGIN` y `VITE_API_URL` y repetir los flujos de inicio de sesión y pedido en el entorno publicado.
