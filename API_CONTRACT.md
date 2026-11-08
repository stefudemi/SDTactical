# Contrato de la API v1

Documento de referencia para el front-end. Todo lo descripto corresponde a la API implementada en `app/controllers/api/v1`.

## 1. Configuración general

| Concepto | Valor |
| --- | --- |
| URL base (desarrollo) | `http://localhost:3000/api/v1` |
| Formato | JSON en peticiones y respuestas (`Content-Type: application/json`) |
| Autenticación | Token Bearer opaco, obtenido con `POST /login` o `POST /register` |
| Credenciales en rutas protegidas | Encabezado `Authorization: Bearer <token>` |
| Cerrar sesión | `DELETE /logout` invalida el token en el servidor |
| CORS | Se acepta el origen definido en `FRONTEND_ORIGIN` (por defecto `http://localhost:5173`); métodos `GET, POST, PATCH, DELETE, OPTIONS` |
| Idioma de los mensajes | Español |
| Fechas | ISO 8601 en UTC, por ejemplo `2026-11-08T00:50:14.567Z` |
| Decimales | Los importes (`price`, `total`, `unit_price`) se devuelven como **string** (`"150000.0"`); convertir con `Number()` para operar |

Cada usuario tiene un único token activo: iniciar sesión de nuevo genera un token nuevo e invalida el anterior. El back-office (`/admin`) es independiente y usa sesión por cookie; no forma parte de este contrato.

### Formato de errores

| Situación | Código | Cuerpo |
| --- | --- | --- |
| Error de validación de campos | `422` | `{ "errors": { "campo": ["mensaje", ...] } }` |
| Regla de negocio incumplida (stock, estado, ítems) | `422` | `{ "error": "mensaje" }` |
| Falta un parámetro requerido o el JSON es inválido | `400` | `{ "error": "mensaje" }` |
| Token ausente, inválido o credenciales incorrectas | `401` | `{ "error": "mensaje" }` |
| Recurso inexistente o ajeno | `404` | `{ "error": "mensaje" }` |

Los pedidos ajenos devuelven `404` (y no `403`) para no revelar su existencia. Los endpoints protegidos solo requieren usuario autenticado; no hay endpoints administrativos en la API.

## 2. Resumen de endpoints

| Método | Ruta | Acceso |
| --- | --- | --- |
| POST | `/register` | Público |
| POST | `/login` | Público |
| DELETE | `/logout` | Token |
| GET | `/profile` | Token |
| PATCH | `/profile` | Token |
| GET | `/categories` | Público |
| GET | `/products` | Público |
| GET | `/products/:id` | Público |
| GET | `/orders` | Token |
| GET | `/orders/:id` | Token |
| POST | `/orders` | Token |
| POST | `/orders/:id/cancel` | Token |

Los endpoints `GET /categories`, filtros de `GET /products`, `PATCH /profile` y `POST /orders/:id/cancel` se incorporaron en el TP 2.

---

## 3. Sesión y cuenta

### POST `/register` — Crear cuenta (público)

Crea un usuario final (nunca administrador) y devuelve un token.

Cuerpo:

| Campo | Tipo | Obligatorio | Validaciones |
| --- | --- | --- | --- |
| `user.name` | string | Sí | No vacío |
| `user.email` | string | Sí | Formato de email, único sin distinguir mayúsculas; se guarda en minúsculas |
| `user.password` | string | Sí | Mínimo 6 caracteres |
| `user.password_confirmation` | string | Sí | Debe coincidir con `password` |

Respuesta `201`:

| Campo | Descripción |
| --- | --- |
| `token` | Token Bearer |
| `token_type` | Siempre `"Bearer"` |
| `user` | `id`, `name`, `email` |

Errores: `422` validación, `400` falta `user`.

```sh
curl -X POST http://localhost:3000/api/v1/register \
  -H "Content-Type: application/json" \
  -d '{"user":{"name":"Ana","email":"ana@demo.test","password":"secret1","password_confirmation":"secret1"}}'
```

```json
{ "token": "t5fgmxEnisDA25QaZAEo1Cyc", "token_type": "Bearer", "user": { "id": 4, "name": "Ana", "email": "ana@demo.test" } }
```

Error `422`:

```json
{ "errors": { "name": ["no puede estar vacío"], "email": ["no es válido"], "password": ["es demasiado corto (mínimo 6 caracteres)"], "password_confirmation": ["no coincide con Contraseña"] } }
```

### POST `/login` — Iniciar sesión (público)

| Campo | Tipo | Obligatorio | Notas |
| --- | --- | --- | --- |
| `email` | string | Sí | Se normaliza a minúsculas |
| `password` | string | Sí | |

Respuesta `200`: `token`, `token_type` (`"Bearer"`) y `user` (`id`, `name`, `email`, `admin`).

Errores: `401` credenciales inválidas.

```sh
curl -X POST http://localhost:3000/api/v1/login \
  -H "Content-Type: application/json" \
  -d '{"email":"ana@demo.test","password":"secret1"}'
```

```json
{ "token": "abNcCA6VZdvXSV7nsaXJxCXQ", "token_type": "Bearer", "user": { "id": 4, "name": "Ana", "email": "ana@demo.test", "admin": false } }
```

Error `401`:

```json
{ "error": "Email o contraseña inválidos" }
```

### DELETE `/logout` — Cerrar sesión (token)

Sin cuerpo. Respuesta `200` sin contenido; el token deja de ser válido. Errores: `401` token ausente o inválido.

```sh
curl -X DELETE http://localhost:3000/api/v1/logout -H "Authorization: Bearer $TOKEN"
```

### GET `/profile` — Datos del usuario (token)

Respuesta `200`: `id` (integer), `name` (string), `email` (string), `admin` (boolean). Errores: `401`.

```sh
curl http://localhost:3000/api/v1/profile -H "Authorization: Bearer $TOKEN"
```

```json
{ "id": 4, "name": "Ana", "email": "ana@demo.test", "admin": false }
```

Error `401`:

```json
{ "error": "No autorizado" }
```

### PATCH `/profile` — Editar datos (token)

Cuerpo: `{ "user": { "name": string, "email": string } }`. Ambos campos son opcionales; los enviados siguen las mismas validaciones que en el registro. No permite modificar `admin` ni la contraseña.

Respuesta `200`: igual que `GET /profile`. Errores: `401`, `400` falta `user`, `422` validación.

```sh
curl -X PATCH http://localhost:3000/api/v1/profile \
  -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" \
  -d '{"user":{"name":"Ana María"}}'
```

```json
{ "id": 4, "name": "Ana María", "email": "ana@demo.test", "admin": false }
```

Error `422`:

```json
{ "errors": { "name": ["no puede estar vacío"] } }
```

---

## 4. Catálogo

### GET `/categories` (público)

Respuesta `200`: lista ordenada por nombre de `{ id, name, description }` (`description` puede ser `null`).

```sh
curl http://localhost:3000/api/v1/categories
```

```json
[ { "id": 4, "name": "Accesorios", "description": "Accesorios y repuestos." }, { "id": 2, "name": "Rifles", "description": "Réplicas largas para airsoft." } ]
```

### GET `/products` (público)

Parámetros de consulta (todos opcionales y combinables):

| Parámetro | Tipo | Descripción |
| --- | --- | --- |
| `q` | string | Texto contenido en el nombre o la descripción (sin distinguir mayúsculas) |
| `category_id` | integer | Filtra por categoría |

Respuesta `200`: lista (posiblemente vacía) de productos ordenados por `id`. Un producto contiene:

| Campo | Tipo | Descripción |
| --- | --- | --- |
| `id` | integer | |
| `name` | string | |
| `description` | string \| null | |
| `price` | string decimal | Precio unitario |
| `stock` | integer | Unidades disponibles (`0` = sin stock) |
| `category` | object | `{ id, name }` |
| `image_url` | string \| null | Ruta relativa al servidor (`/rails/active_storage/...`); anteponer el host del back-end. `null` si no tiene imagen |

```sh
curl "http://localhost:3000/api/v1/products?q=rifle&category_id=2"
```

```json
[ { "id": 4, "name": "Rifle de entrenamiento", "description": "Producto de ejemplo para desarrollo.", "price": "150000.0", "stock": 5, "category": { "id": 2, "name": "Rifles" }, "image_url": null } ]
```

### GET `/products/:id` (público)

Parámetro de ruta `id` (integer). Respuesta `200`: un producto con la estructura anterior. Error `404`:

```json
{ "error": "Producto no encontrado" }
```

---

## 5. Pedidos (todos requieren token)

Un pedido contiene:

| Campo | Tipo | Descripción |
| --- | --- | --- |
| `id` | integer | |
| `status` | string | `pending`, `confirmed`, `shipped` o `cancelled` |
| `total` | string decimal | Suma de `unit_price × quantity` |
| `created_at` | string ISO 8601 | |
| `items` | array | `{ product_id, product_name, quantity, unit_price }`; `unit_price` es el precio al momento de la compra |

El estado inicial es `pending`; los cambios a `confirmed` y `shipped` los realiza el administrador desde el back-office.

### GET `/orders`

Respuesta `200`: lista de pedidos del usuario autenticado, del más reciente al más antiguo (puede estar vacía). Errores: `401`.

```sh
curl http://localhost:3000/api/v1/orders -H "Authorization: Bearer $TOKEN"
```

### GET `/orders/:id`

Respuesta `200`: un pedido propio. Errores: `401`; `404` si no existe o pertenece a otro usuario:

```json
{ "error": "Pedido no encontrado" }
```

### POST `/orders` — Crear pedido

| Campo | Tipo | Obligatorio | Validaciones |
| --- | --- | --- | --- |
| `order.items` | array | Sí | Al menos un ítem |
| `order.items[].product_id` | integer | Sí | Debe existir |
| `order.items[].quantity` | integer | Sí | Mayor que 0 y no superior al stock disponible |

El servidor ignora cualquier precio o total enviado: usa el precio vigente, descuenta el stock de forma atómica y encola el email de confirmación. Si un ítem falla, no se guarda nada.

Respuesta `201`: el pedido creado. Errores: `401`; `400` falta `order`; `422` en los casos siguientes:

| Causa | Mensaje (`error`) |
| --- | --- |
| `items` vacío o con formato inválido | `items debe incluir al menos un ítem` / `Cada ítem debe incluir product_id y quantity` |
| Cantidad o id no enteros | `product_id y quantity deben ser enteros válidos` |
| Cantidad no positiva | `quantity debe ser positivo` |
| Producto inexistente | `Producto 999 inexistente` |
| Stock insuficiente | `Stock insuficiente para <producto>` |

```sh
curl -X POST http://localhost:3000/api/v1/orders \
  -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" \
  -d '{"order":{"items":[{"product_id":4,"quantity":1}]}}'
```

```json
{ "id": 6, "status": "pending", "total": "150000.0", "created_at": "2026-11-08T00:50:14.567Z", "items": [ { "product_id": 4, "product_name": "Rifle de entrenamiento", "quantity": 1, "unit_price": "150000.0" } ] }
```

Error `422`:

```json
{ "error": "Stock insuficiente para Rifle de entrenamiento" }
```

### POST `/orders/:id/cancel` — Cancelar pedido

Sin cuerpo. Solo se pueden cancelar pedidos propios en estado `pending`; el stock de sus ítems se devuelve y el estado pasa a `cancelled`.

Respuesta `200`: el pedido con `status: "cancelled"`. Errores: `401`; `404` pedido inexistente o ajeno; `422` si no está pendiente:

```json
{ "error": "Solo se pueden cancelar pedidos pendientes" }
```

```sh
curl -X POST http://localhost:3000/api/v1/orders/6/cancel -H "Authorization: Bearer $TOKEN"
```
