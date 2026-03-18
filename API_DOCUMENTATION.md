# API Documentation

## Authentication

All microservices (except public endpoints) require JWT token in the Authorization header:
```
Authorization: Bearer <token>
```

## Users Service (Port 3001)

### Authentication Endpoints

**POST /auth/login**
- Request: `{ "email": "user@example.com", "password": "password" }`
- Response: `{ "token": "jwt_token", "userId": 1 }`

**POST /auth/register**
- Request: `{ "name": "John Doe", "email": "user@example.com", "password": "password" }`
- Response: `{ "id": 1 }`

### User Management

**GET /users**
- Returns list of all users

**GET /users/:id**
- Returns specific user details

**POST /users**
- Request: `{ "name": "John", "email": "john@example.com", "role": "user" }`
- Creates new user

**PUT /users/:id**
- Request: `{ "name": "Jane", "email": "jane@example.com", "role": "admin" }`
- Updates user

**DELETE /users/:id**
- Deletes user

**GET /users/count**
- Returns total user count

## Orders Service (Port 3002)

**GET /orders**
- Returns all orders

**GET /orders/:id**
- Returns specific order

**POST /orders**
- Request: `{ "user_id": 1, "items": [...], "total_amount": 100.00 }`
- Creates new order

**PUT /orders/:id**
- Request: `{ "status": "confirmed" }`
- Updates order status

**GET /orders/count**
- Returns total orders count

## Shipments Service (Port 3003)

**GET /shipments**
- Returns all shipments

**GET /shipments/:id**
- Returns specific shipment

**POST /shipments**
- Request: `{ "order_id": 1, "origin": "New York", "destination": "Los Angeles", "carrier": "FedEx" }`
- Creates shipment

**PUT /shipments/:id**
- Request: `{ "status": "in-transit" }`
- Updates shipment status

**GET /shipments/track/:tracking_number**
- Public endpoint for tracking shipments

**GET /shipments/count**
- Returns total shipments count

## Inventory Service (Port 3004)

**GET /inventory**
- Returns all inventory items

**GET /inventory/:id**
- Returns specific inventory item

**POST /inventory**
- Request: `{ "sku": "SKU123", "name": "Product", "quantity": 100, "warehouse": "WH1", "unit_price": 10.00 }`
- Creates inventory item

**PUT /inventory/:id**
- Request: `{ "quantity": 150, "warehouse": "WH2", "unit_price": 12.00 }`
- Updates inventory item

**POST /inventory/:id/adjust**
- Request: `{ "adjustment": 50 }`
- Adjusts quantity

**GET /inventory/count**
- Returns total items count

## Notifications Service (Port 3005)

**POST /notify**
- Request: `{ "user_id": 1, "type": "order_created", "message": "Your order has been created" }`
- Creates notification

**GET /notifications/:user_id**
- Returns user notifications

**PUT /notifications/:id/read**
- Marks notification as read

## Health Checks

All services have a `/health` endpoint for liveness/readiness checks.
