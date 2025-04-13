const express = require('express');
const cors = require('cors');
const admin = require('firebase-admin');
const serviceAccount = require('./firebase-service-account.json');
require('dotenv').config();

const app = express();

// Cấu hình CORS chi tiết
app.use(cors({
    origin: '*', // Cho phép tất cả các origin trong quá trình phát triển
    methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
    allowedHeaders: ['Content-Type', 'Authorization'],
    credentials: true,
    maxAge: 86400 // 24 giờ
}));

// Cấu hình body parser với giới hạn lớn hơn
app.use(express.json({ limit: '50mb' }));
app.use(express.urlencoded({ extended: true, limit: '50mb' }));

// Middleware để ghi log request
app.use((req, res, next) => {
    console.log(`${new Date().toISOString()} - ${req.method} ${req.url}`);
    next();
});

// Khởi tạo Firebase Admin SDK
try {
    admin.initializeApp({
        credential: admin.credential.cert(serviceAccount),
        storageBucket: "doanchuyennganh-857ed.appspot.com"
    });
    console.log('Firebase Admin SDK initialized successfully');
} catch (error) {
    console.error('Error initializing Firebase Admin SDK:', error);
}

// Routes
app.use('/api/products', require('./routes/products'));
app.use('/api/ratings', require('./routes/ratings'));
app.use('/api/debug', require('./routes/debug'));
app.use('/api/auth', require('./routes/auth'));
app.use('/api/orders', require('./routes/orders'));
app.use('/api/users', require('./routes/users'));
app.use('/api/cart', require('./routes/cart'));

// Health check route
app.get('/health', (req, res) => {
    res.status(200).json({ status: 'Server is running' });
});

// Khởi động server
const PORT = process.env.PORT || 3001;
app.listen(PORT, '0.0.0.0', () => {
    console.log(`Server running on port ${PORT}`);
    console.log(`Health check available at: http://localhost:${PORT}/health`);
    console.log(`API base URL: http://localhost:${PORT}/api`);
}); 