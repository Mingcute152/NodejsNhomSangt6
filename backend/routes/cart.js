// 📁 routes/cart.js
const express = require('express');
const router = express.Router();
const admin = require('firebase-admin');
const db = admin.firestore();
const { verifyToken } = require('../middleware/verifyToken');

// Lấy giỏ hàng của user
router.get('/', verifyToken, async (req, res) => {
    try {
        const doc = await db.collection('carts').doc(req.user.uid).get();
        if (!doc.exists) return res.status(200).json({ items: [] });
        res.status(200).json(doc.data());
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// Cập nhật giỏ hàng
router.post('/', verifyToken, async (req, res) => {
    try {
        const cartData = req.body; // { items: [{ productId, quantity }] }
        await db.collection('carts').doc(req.user.uid).set(cartData);
        res.status(200).json({ message: 'Cập nhật giỏ hàng thành công' });
    } catch (err) {
        res.status(400).json({ error: err.message });
    }
});

// Xóa giỏ hàng
router.delete('/', verifyToken, async (req, res) => {
    try {
        await db.collection('carts').doc(req.user.uid).delete();
        res.status(200).json({ message: 'Xóa giỏ hàng thành công' });
    } catch (err) {
        res.status(400).json({ error: err.message });
    }
});

module.exports = router;
