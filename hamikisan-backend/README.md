# HamiKisan Backend

Production-oriented backend scaffold for HamiKisan using:
- Node.js + Express
- PostgreSQL
- Redis (optional but recommended)
- Socket.IO for realtime chat/signaling

## 1) Setup

```bash
cd hamikisan-backend
cp .env.example .env
```

Update `.env` values, especially `JWT_SECRET` and DB credentials.

Run DB schema:

```bash
psql -U postgres -d hamikisan_db -f database/schema.sql
```

## 2) Run

```bash
npm install
npm run dev
```

Server default: `http://localhost:5000`

## 3) API Overview

Health:
- `GET /`
- `GET /health`

Auth:
- `POST /api/auth/register`
- `POST /api/auth/login`

Users:
- `GET /api/users/me` (JWT required)
- `GET /api/users/doctors` (JWT required)

Appointments:
- `POST /api/appointments` (JWT required)
- `GET /api/appointments/mine` (JWT required)
- `PATCH /api/appointments/:id/status` (JWT required)

Chat:
- `GET /api/chat/rooms/:roomId/messages` (JWT required)
- `POST /api/chat/messages` (JWT required)

Posts:
- `GET /api/posts`
- `POST /api/posts` (JWT required)
- `DELETE /api/posts/:id` (JWT required)
- `POST /api/posts/:id/like` (JWT required)

Products:
- `GET /api/products`
- `GET /api/products/mine` (JWT required)
- `POST /api/products` (JWT required)
- `PATCH /api/products/:id/status` (admin JWT required)

Orders:
- `POST /api/orders` (JWT required)
- `GET /api/orders/mine` (JWT required)
- `PATCH /api/orders/:id/status` (JWT required)

## 4) Socket.IO Events

Client must connect with JWT:

```js
const socket = io('http://localhost:5000', {
  auth: { token: 'Bearer <jwt>' }
});
```

Events:
- `join_room` -> `{ roomId?, peerUserId? }`
- `leave_room` -> `{ roomId }`
- `typing` -> `{ roomId, isTyping }`
- `send_message` -> `{ roomId?, receiverId, message }`
- `receive_message` (server -> client)

## 5) Flutter Connection Notes

- Android emulator base URL: `http://10.0.2.2:5000`
- iOS simulator base URL: `http://localhost:5000`
- Real device: use your machine LAN IP, e.g. `http://192.168.1.10:5000`

## 6) Suggested Next Steps

- Add request validation (`zod` or `joi`).
- Add rate limiting for auth and chat endpoints.
- Add migration tooling (`knex`, `prisma`, or `node-pg-migrate`).
- Add CI checks and endpoint tests.
