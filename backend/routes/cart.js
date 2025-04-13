// 📁 routes/cart.js
const express = require('express');
const router = express.Router();
const admin = require('firebase-admin');
const db = admin.firestore();
const { verifyToken } = require('../middlewares/verifyToken');

// Lấy giỏ hàng của user
router.get('/', verifyToken, async (req, res) => {
    try {
        const snapshot = await db.collection('carts').doc(req.user.uid).get();
        if (!snapshot.exists) {
            return res.status(404).json({ message: 'Giỏ hàng trống' });
        }
        res.status(200).json(snapshot.data());
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
