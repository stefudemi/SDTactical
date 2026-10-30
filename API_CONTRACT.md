# API v1

Base: `http://localhost:3000/api/v1`. Todas las peticiones y respuestas usan JSON. Las rutas protegidas requieren `Authorization: Bearer <token>`.

## Sesión y cuenta

| Método | Ruta | Cuerpo | Respuesta |
| --- | --- | --- | --- |
| POST | `/register` | `{ "user": { "name", "email", "password", "password_confirmation" } }` | `201` con `token`, `token_type` y `user` |
| POST | `/login` | `{ "email", "password" }` | `200` con `token` y `token_type` |
| DELETE | `/logout` | Token | `200` sin cuerpo |
| GET | `/profile` | Token | `200` con `id`, `name`, `email`, `admin` |

`email` es obligatorio y único; la contraseña debe cumplir las validaciones del modelo. Un login inválido responde `401 { "error": "Email o contraseña inválidos" }`; un registro inválido responde `422 { "errors": { "campo": ["mensaje"] } }`.

## Catálogo

| Método | Ruta | Acceso | Respuesta exitosa |
| --- | --- | --- | --- |
| GET | `/products` | Público | `200`, lista de productos |
| GET | `/products/:id` | Público | `200`, un producto |

Un producto contiene `id`, `name`, `description`, `price`, `stock`, `category` (`id`, `name`) e `image_url` opcional. Un id inexistente devuelve `404 { "error": "Producto no encontrado" }`.

## Pedidos

| Método | Ruta | Acceso | Respuesta exitosa |
| --- | --- | --- | --- |
| GET | `/orders` | Token | `200`, lista de pedidos propios |
| GET | `/orders/:id` | Token | `200`, pedido propio |
| POST | `/orders` | Token | `201`, pedido creado |

Para crear: `{ "order": { "items": [{ "product_id": 1, "quantity": 2 }] } }`. `product_id` y `quantity` son enteros; la cantidad debe ser positiva. El servidor calcula precios, descuenta el stock y devuelve `id`, `status`, `total`, `created_at` e `items`. Datos inválidos o stock insuficiente devuelven `422`; un pedido ajeno o inexistente devuelve `404`; la falta de token o un token inválido devuelve `401 { "error": "No autorizado" }`.
