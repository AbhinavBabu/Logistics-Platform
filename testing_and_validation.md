# 🧪 Logistics Platform - Testing & Validation Guide

## 🎯 Objective

This guide explains how to test and validate that all microservices, databases, and integrations in the Logistics Platform are working correctly.

---

## ✅ 1. Prerequisites

* Docker & Docker Compose installed
* EC2 instance (or local machine)
* Required ports open (3000–3005)

---

## 🚀 2. Start the Application

```bash
docker-compose up --build
```

OR run in background:

```bash
docker-compose up -d
```

---

## 🔍 3. Verify Containers

```bash
docker ps
```

Ensure the following are running:

* users-service (3001)
* orders-service (3002)
* shipments-service (3003)
* inventory-service (3004)
* notifications-service (3005)
* frontend (3000)
* PostgreSQL databases

---

## 🧪 4. Health Check

Test each service:

```bash
curl http://<EC2-IP>:3001/health
curl http://<EC2-IP>:3002/health
curl http://<EC2-IP>:3003/health
curl http://<EC2-IP>:3004/health
curl http://<EC2-IP>:3005/health
```

Expected: Healthy/OK response

---

## 🔐 5. Authentication Testing

### Register User

```bash
curl -X POST http://<EC2-IP>:3001/auth/register \
-H "Content-Type: application/json" \
-d '{"name":"Test","email":"test@test.com","password":"123456"}'
```

### Login

```bash
curl -X POST http://<EC2-IP>:3001/auth/login \
-H "Content-Type: application/json" \
-d '{"email":"test@test.com","password":"123456"}'
```

Save the JWT token from response.

---

## 👤 6. Users Service Testing

```bash
curl http://<EC2-IP>:3001/users \
-H "Authorization: Bearer <TOKEN>"
```

Test Create User:

```bash
curl -X POST http://<EC2-IP>:3001/users \
-H "Content-Type: application/json" \
-H "Authorization: Bearer <TOKEN>" \
-d '{"name":"NewUser","email":"new@test.com","role":"user"}'
```

---

## 📦 7. Orders Service Testing

```bash
curl http://<EC2-IP>:3002/orders
```

Create Order:

```bash
curl -X POST http://<EC2-IP>:3002/orders \
-H "Content-Type: application/json" \
-d '{"user_id":1,"items":[{"name":"item1","qty":1}],"total_amount":100}'
```

---

## 🚚 8. Shipments Service Testing

```bash
curl http://<EC2-IP>:3003/shipments
```

Create Shipment:

```bash
curl -X POST http://<EC2-IP>:3003/shipments \
-H "Content-Type: application/json" \
-d '{"order_id":1,"origin":"A","destination":"B","carrier":"DHL"}'
```

---

## 📦 9. Inventory Service Testing

```bash
curl http://<EC2-IP>:3004/inventory
```

---

## 🔔 10. Notifications Service Testing

```bash
curl -X POST http://<EC2-IP>:3005/notify \
-H "Content-Type: application/json" \
-d '{"user_id":1,"type":"order_created","message":"Order created"}'
```

---

## 🌐 11. Frontend Testing

Open in browser:

```
http://<EC2-IP>:3000
```

Validate:

* Pages load
* Data is displayed
* API interactions work

---

## 🗄️ 12. Database Validation

Enter DB:

```bash
docker exec -it logistics-platform_users-db_1 psql -U postgres
```

Switch DB:

```sql
\c users_db
```

Check tables:

```sql
\dt
```

Check data:

```sql
SELECT * FROM users;
```

---

## 🔄 13. End-to-End Workflow Test

1. Register user
2. Login and get token
3. Create order
4. Create shipment
5. Send notification

---

## 🚨 14. Common Issues

| Issue              | Cause          | Fix                      |
| ------------------ | -------------- | ------------------------ |
| Cannot GET /       | Wrong endpoint | Use correct route        |
| No token           | Missing JWT    | Add Authorization header |
| Connection refused | Port blocked   | Open security group      |
| DB error           | Wrong DB       | Switch to correct DB     |

---

## ✅ 15. Success Criteria

System is working if:

* All containers running
* APIs respond correctly
* DB stores/retrieves data
* Frontend loads and interacts with backend

---

## 🎯 Conclusion

Successful testing confirms:

* Microservices communication works
* Database connectivity is valid
* System is production-ready
