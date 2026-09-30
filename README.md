# SDTactical

Aplicación Rails para administrar un catálogo de productos de airsoft y permitir que usuarios consulten productos y creen pedidos mediante una API JSON.

## Requisitos

- Ruby 4.0.6 (ver `.ruby-version`)
- Bundler
- SQLite 3

## Instalación y ejecución

Desde la raíz del repositorio:

```sh
bundle install
bin/rails db:prepare
bin/rails db:seed
bin/rails server
```

Abrí <http://localhost:3000>. `db:prepare` crea la base y aplica las migraciones pendientes. `db:seed` carga categorías y productos de ejemplo y crea el administrador de desarrollo si todavía no existe.

## Back-office

Entrá en <http://localhost:3000/login>.

En desarrollo, las credenciales creadas por `db:seed` son:

- Email: `admin@sdtactical.test`
- Contraseña: `dev-password-123`

El back-office está bajo `/admin` y requiere iniciar sesión con un usuario administrador. Esta cuenta y contraseña son únicamente para desarrollo local; cambiá la contraseña y configurá un mecanismo seguro antes de publicar la aplicación.

Los usuarios finales pueden crear su propia cuenta desde <http://localhost:3000/signup> o desde el enlace de registro en la pantalla de login. El registro público siempre crea cuentas con permisos de usuario final (`admin: false`) e inicia sesión al completarse. La API no crea cuentas: su endpoint de login autentica usuarios ya registrados.

## API JSON v1

Los endpoints están bajo `/api/v1`. Productos se pueden consultar sin token. Perfil, pedidos y cierre de sesión requieren el encabezado `Authorization: Bearer <token>`.

| Método | Endpoint | Acceso | Descripción |
| --- | --- | --- | --- |
| `GET` | `/api/v1/products` | Público | Lista productos en JSON. |
| `GET` | `/api/v1/products/:id` | Público | Devuelve un producto. |
| `POST` | `/api/v1/login` | Público | Recibe `email` y `password`; devuelve un token Bearer. |
| `GET` | `/api/v1/profile` | Token | Devuelve el perfil del usuario autenticado. |
| `GET` | `/api/v1/orders` | Token | Lista los pedidos del usuario autenticado. |
| `GET` | `/api/v1/orders/:id` | Token | Devuelve un pedido propio. |
| `POST` | `/api/v1/orders` | Token | Crea un pedido; calcula los precios desde el servidor y descuenta stock. |
| `DELETE` | `/api/v1/logout` | Token | Invalida el token actual. |

Ejemplo de login con `curl`:

```sh
curl -X POST http://localhost:3000/api/v1/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@sdtactical.test","password":"dev-password-123"}'
```

La respuesta contiene `token` y `token_type: "Bearer"`. En pedidos protegidos, enviá el token en el encabezado `Authorization`. Para crear uno, enviá JSON con esta estructura:

```json
{
  "order": {
    "items": [
      { "product_id": 1, "quantity": 2 }
    ]
  }
}
```

Las respuestas de error usan códigos HTTP como `401` (sin autorización), `404` (recurso no encontrado) y `422` (datos no válidos o stock insuficiente).

## Modelo de datos

- **User**: usuario final o administrador; tiene muchos pedidos y un token para la API.
- **Category**: categoría de catálogo; tiene muchos productos.
- **Product**: pertenece a una categoría, tiene imagen adjunta mediante Active Storage y aparece en ítems de pedido.
- **Order**: pertenece a un usuario y contiene varios ítems; guarda estado, total y fecha de envío del email de confirmación.
- **OrderItem**: pertenece a un pedido y a un producto; guarda cantidad y precio unitario al momento de la compra.
- **Active Storage** agrega los modelos internos para adjuntos e imágenes.

## Emails

Al crear un pedido, la aplicación encola un trabajo que envía el email de confirmación mediante `OrderConfirmationMailer`. El entorno de desarrollo usa el adaptador `:test`, así que no envía correo real; en producción hay que configurar un servicio SMTP u otro proveedor de entrega.

## Calidad y pruebas

```sh
bin/rubocop
bin/brakeman --no-pager
bin/rails test
```

El repositorio incluye tests de modelos, controladores, API y trabajos. Revisá los resultados de RuboCop y Brakeman antes de entregar.
