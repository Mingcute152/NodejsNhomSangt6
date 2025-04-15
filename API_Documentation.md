# API Documentation - Pharmacy App

## Table of Contents
1. [Authentication APIs](#authentication-apis)
2. [Product APIs](#product-apis)
3. [Rating APIs](#rating-apis)
4. [Cart APIs](#cart-apis)
5. [Order APIs](#order-apis)
6. [User APIs](#user-apis)
7. [Postman Setup Guide](#postman-setup-guide)

## Authentication APIs

### Admin Login
```http
POST http://localhost:3001/api/auth/admin/login
Content-Type: application/json

{
    "email": "admin@gmail.com",
    "password": "123456"
}
```

### User Login
```http
POST http://localhost:3001/api/auth/login
Content-Type: application/json

{
    "email": "user@gmail.com",
    "password": "123456"
}
```

### User Registration
```http
POST http://localhost:3001/api/auth/register
Content-Type: application/json

{
    "email": "newuser@gmail.com",
    "password": "123456",
    "name": "New User"
}
```

### Logout
```http
POST http://localhost:3001/api/auth/logout
Authorization: Bearer {{token}}
```

## Product APIs

### Get All Products
```http
GET http://localhost:3001/api/products
```

### Add New Product (Admin only)
```http
POST http://localhost:3001/api/products
Authorization: Bearer {{token}}
Content-Type: application/json

{
    "title": "Sức Miệng",
    "image": "assets/sucmieng.png",
    "price": 100000,
    "description": "Nước súc miệng diệt khuẩn",
    "category": "Chăm sóc răng miệng",
    "quantity": 50
}
```

### Update Product (Admin only)
```http
PUT http://localhost:3001/api/products/:id
Authorization: Bearer {{token}}
Content-Type: application/json

{
    "title": "Sức Miệng Updated",
    "price": 120000
}
```

### Delete Product (Admin only)
```http
DELETE http://localhost:3001/api/products/:id
Authorization: Bearer {{token}}
```

### Search Products
```http
GET http://localhost:3001/api/products/search?query=suc mieng
```

## Rating APIs

### Get Product Ratings
```http
GET http://localhost:3001/api/ratings/:productId
```

### Add Rating (User only)
```http
POST http://localhost:3001/api/ratings
Authorization: Bearer {{token}}
Content-Type: application/json

{
    "productId": "product_id",
    "rating": 5,
    "comment": "Sản phẩm rất tốt"
}
```

### Update Rating
```http
PUT http://localhost:3001/api/ratings/:id
Authorization: Bearer {{token}}
Content-Type: application/json

{
    "rating": 4,
    "comment": "Sản phẩm khá tốt"
}
```

### Delete Rating
```http
DELETE http://localhost:3001/api/ratings/:id
Authorization: Bearer {{token}}
```

## Cart APIs

### Get Cart
```http
GET http://localhost:3001/api/cart
Authorization: Bearer {{token}}
```

### Add to Cart
```http
POST http://localhost:3001/api/cart
Authorization: Bearer {{token}}
Content-Type: application/json

{
    "productId": "product_id",
    "quantity": 2
}
```

### Update Cart Item
```http
PUT http://localhost:3001/api/cart/:productId
Authorization: Bearer {{token}}
Content-Type: application/json

{
    "quantity": 3
}
```

### Remove from Cart
```http
DELETE http://localhost:3001/api/cart/:productId
Authorization: Bearer {{token}}
```

## Order APIs

### Create Order
```http
POST http://localhost:3001/api/orders
Authorization: Bearer {{token}}
Content-Type: application/json

{
    "items": [
        {
            "productId": "product_id",
            "quantity": 2
        }
    ],
    "shippingAddress": {
        "street": "123 ABC",
        "city": "Ho Chi Minh",
        "phone": "0123456789"
    }
}
```

### Get Orders List
```http
GET http://localhost:3001/api/orders
Authorization: Bearer {{token}}
```

### Get Order Details
```http
GET http://localhost:3001/api/orders/:id
Authorization: Bearer {{token}}
```

### Update Order Status (Admin only)
```http
PUT http://localhost:3001/api/orders/:id
Authorization: Bearer {{token}}
Content-Type: application/json

{
    "status": "shipped"
}
```

## User APIs

### Get User Profile
```http
GET http://localhost:3001/api/users/profile
Authorization: Bearer {{token}}
```

### Update User Profile
```http
PUT http://localhost:3001/api/users/profile
Authorization: Bearer {{token}}
Content-Type: application/json

{
    "name": "Updated Name",
    "phone": "0987654321",
    "address": "456 XYZ"
}
```

### Delete User Account
```http
DELETE http://localhost:3001/api/users/profile
Authorization: Bearer {{token}}
```

## Postman Setup Guide

### Environment Variables
```
baseUrl: http://localhost:3001/api
authToken: [token sau khi đăng nhập]
```

### Collection Structure
- Auth
- Products
- Ratings
- Cart
- Orders
- Users

### Pre-request Script (Collection Level)
```javascript
// Kiểm tra token hết hạn
if (pm.environment.get('authToken')) {
    // Thêm logic check token expiry
}
```

### Tests Script (Login Request)
```javascript
if (pm.response.code === 200) {
    var jsonData = pm.response.json();
    pm.environment.set("authToken", jsonData.token);
}
```

### Important Notes
1. Tất cả các request yêu cầu xác thực phải có header `Authorization: Bearer {{token}}`
2. Content-Type phải được set là `application/json` cho các request có body
3. Token có thời hạn 1 giờ
4. Các route Admin yêu cầu tài khoản có role admin
5. Các response sẽ trả về định dạng JSON 