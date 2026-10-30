# SDTactical

Trabajo Práctico 2 de Programación IV. Aplicación individual para consultar productos de airsoft y realizar pedidos.

- Back-end: Ruby on Rails 8.1, SQLite y API JSON.
- Front-end: React + Vite en [`frontend/`](frontend/), preparado como repositorio independiente.

## Ejecutar

Back-end (Ruby 3.4.7):

```sh
bundle install
bin/rails db:prepare
bin/rails db:seed
bin/rails server
```

Front-end (Node 24 o compatible):

```sh
cd frontend
npm install
npm run dev
```

La web queda en `http://localhost:5173` y consume `http://localhost:3000/api/v1`. Si la API se publica en otra URL, crear `frontend/.env.local` con `VITE_API_URL=https://ejemplo/api/v1`.

`db:seed` crea productos de ejemplo y el administrador local `admin@sdtactical.test` / `dev-password-123`. El front permite registrar usuarios finales; no usar esas credenciales fuera del desarrollo.

## Funciones

Catálogo público con búsqueda, registro e inicio de sesión, carrito, confirmación de pedido, historial de pedidos y mensajes de carga, error, vacío y confirmación. El back-office Rails sigue disponible en `/admin`.

## Calidad

```sh
bin/rails test
bin/rubocop
bin/brakeman --no-pager
cd frontend && npm test && npm run build
```

El contrato de endpoints está en [API_CONTRACT.md](API_CONTRACT.md).
