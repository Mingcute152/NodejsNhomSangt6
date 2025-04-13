// 📁 routes/auth.js
const express = require('express');
const jwt = require('jsonwebtoken');
const router = express.Router();
const admin = require('firebase-admin');
const { verifyToken } = require('../middlewares/verifyToken');

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

        // Lưu thông tin user vào Firestore
        await db.collection('users').doc(userRecord.uid).set({
            email,
            name,
            role: 'user',
            createdAt: new Date().toISOString(),
        });

        res.status(201).json({
            success: true,
            message: 'Đăng ký thành công',
            user: {
                uid: userRecord.uid,
                email: userRecord.email,
                displayName: userRecord.displayName
            }
        });
    } catch (error) {
        res.status(400).json({
            success: false,
            error: error.message
        });
    }
});

// Đăng nhập user
router.post('/login', async (req, res) => {
    const { email, password } = req.body;
    try {
        // Xác thực user với Firebase Admin
        const userCredential = await admin.auth().getUserByEmail(email);

        // Tạo custom token
        const customToken = await admin.auth().createCustomToken(userCredential.uid);

        res.status(200).json({
            success: true,
            token: customToken,
            user: {
                uid: userCredential.uid,
                email: userCredential.email,
                displayName: userCredential.displayName
            }
        });
    } catch (error) {
        res.status(401).json({
            success: false,
            error: 'Đăng nhập thất bại: ' + error.message
        });
    }
});

// Logout endpoint
router.post('/logout', verifyToken, async (req, res) => {
    try {
        await admin.auth().revokeRefreshTokens(req.user.uid);
        res.status(200).json({ message: 'Logged out successfully' });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// Delete account endpoint
router.delete('/delete-account', verifyToken, async (req, res) => {
    try {
        const uid = req.user.uid;

        // Xóa dữ liệu user từ Firestore
        await admin.firestore().collection('users').doc(uid).delete();

        // Xóa giỏ hàng của user
        await admin.firestore().collection('carts').doc(uid).delete();

        // Xóa tài khoản Firebase Auth
        await admin.auth().deleteUser(uid);

        res.status(200).json({
            success: true,
            message: 'Tài khoản đã được xóa thành công'
        });
    } catch (err) {
        console.error('Delete account error:', err);
        res.status(500).json({
            success: false,
            error: err.message
        });
    }
});

module.exports = router;
