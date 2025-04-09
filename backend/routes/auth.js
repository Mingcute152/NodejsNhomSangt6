// 📁 routes/auth.js
const express = require('express');
const jwt = require('jsonwebtoken');
const router = express.Router();
const admin = require('firebase-admin');

const db = admin.firestore();
const JWT_SECRET = 'your_jwt_secret_key'; // ❗ Replace this with env var in production

// Đăng ký user
router.post('/register', async (req, res) => {
    const { email, password, name } = req.body;
    try {
        // Tạo user trên Firebase Auth
        const userRecord = await admin.auth().createUser({
            email,
            password,
            displayName: name,
        });

        // Lưu vào Firestore
        await db.collection('users').doc(userRecord.uid).set({
            email,
            name,
            role: 'user',
            createdAt: new Date().toISOString(),
        });

        res.status(201).json({ message: 'Đăng ký thành công', uid: userRecord.uid });
    } catch (error) {
        res.status(400).json({ error: error.message });
    }
});

// Đăng nhập user
router.post('/login', async (req, res) => {
    const { email } = req.body;

    try {
        // Lấy user từ Firebase Auth (cần xử lý xác thực ở client)
        const user = await admin.auth().getUserByEmail(email);

        // Tạo JWT token
        const token = jwt.sign({ uid: user.uid, email: user.email }, JWT_SECRET, { expiresIn: '7d' });

        res.status(200).json({ token, uid: user.uid });
    } catch (error) {
        res.status(401).json({ error: 'Tài khoản không tồn tại hoặc sai email' });
    }
});

module.exports = router;
