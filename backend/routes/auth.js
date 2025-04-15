// 📁 routes/auth.js
const express = require('express');
const jwt = require('jsonwebtoken');
const router = express.Router();
const admin = require('firebase-admin');
const { verifyToken } = require('../middlewares/verifyToken');
const { body, validationResult } = require('express-validator');

const db = admin.firestore();
const JWT_SECRET = 'your_jwt_secret_key'; // ❗ Replace this with env var in production

// Middleware kiểm tra role admin
const isAdmin = async (req, res, next) => {
    try {
        const userDoc = await db.collection('users').doc(req.user.uid).get();
        const userData = userDoc.data();

        if (userData && userData.role === 'admin') {
            next();
        } else {
            res.status(403).json({
                success: false,
                error: 'Không có quyền truy cập'
            });
        }
    } catch (error) {
        res.status(500).json({
            success: false,
            error: 'Lỗi server: ' + error.message
        });
    }
};

// Validation middleware
const validateRegister = [
    body('email').isEmail().withMessage('Email không hợp lệ'),
    body('password').isLength({ min: 6 }).withMessage('Mật khẩu phải có ít nhất 6 ký tự'),
    body('name').notEmpty().withMessage('Tên không được để trống')
];

const validateLogin = [
    body('email').isEmail().withMessage('Email không hợp lệ'),
    body('password').notEmpty().withMessage('Mật khẩu không được để trống')
];

// Đăng ký user
router.post('/register', validateRegister, async (req, res) => {
    try {
        const errors = validationResult(req);
        if (!errors.isEmpty()) {
            return res.status(400).json({ errors: errors.array() });
        }

        const { email, password, name } = req.body;

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
        console.error('Register error:', error);
        res.status(400).json({
            success: false,
            error: error.message
        });
    }
});

// Đăng nhập user
router.post('/login', validateLogin, async (req, res) => {
    try {
        const errors = validationResult(req);
        if (!errors.isEmpty()) {
            return res.status(400).json({ errors: errors.array() });
        }

        const { email, password } = req.body;

        // Xác thực user với Firebase Admin
        const userCredential = await admin.auth().getUserByEmail(email);

        // Kiểm tra role từ Firestore
        const userDoc = await db.collection('users').doc(userCredential.uid).get();
        const userData = userDoc.data();

        // Tạo custom token
        const customToken = await admin.auth().createCustomToken(userCredential.uid);

        res.status(200).json({
            success: true,
            token: customToken,
            user: {
                uid: userCredential.uid,
                email: userCredential.email,
                displayName: userCredential.displayName,
                role: userData.role
            }
        });
    } catch (error) {
        console.error('Login error:', error);
        res.status(401).json({
            success: false,
            error: 'Đăng nhập thất bại: ' + error.message
        });
    }
});

// Đăng nhập admin
router.post('/admin/login', validateLogin, async (req, res) => {
    try {
        const errors = validationResult(req);
        if (!errors.isEmpty()) {
            return res.status(400).json({ errors: errors.array() });
        }

        const { email, password } = req.body;

        // Xác thực user với Firebase Admin
        const userCredential = await admin.auth().getUserByEmail(email);

        // Kiểm tra role từ Firestore
        const userDoc = await db.collection('users').doc(userCredential.uid).get();
        const userData = userDoc.data();

        if (!userData || userData.role !== 'admin') {
            return res.status(403).json({
                success: false,
                error: 'Tài khoản không có quyền admin'
            });
        }

        // Tạo custom token
        const customToken = await admin.auth().createCustomToken(userCredential.uid);

        res.status(200).json({
            success: true,
            token: customToken,
            user: {
                uid: userCredential.uid,
                email: userCredential.email,
                displayName: userCredential.displayName,
                role: 'admin'
            }
        });
    } catch (error) {
        console.error('Admin login error:', error);
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
        console.error('Logout error:', err);
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
