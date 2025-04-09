// 📁 routes/orders.js
const express = require('express');
const router = express.Router();
const admin = require('firebase-admin');
const db = admin.firestore();
const { verifyToken, isAdmin } = require('../middleware/verifyToken');

// Tạo đơn hàng mới
router.post('/', verifyToken, async (req, res) => {
    try {
        const data = {
            ...req.body,
            userId: req.user.uid,
            status: 'pending',
            createdAt: new Date().toISOString(),
        };
        const doc = await db.collection('orders').add(data);
        res.status(201).json({ id: doc.id });
    } catch (err) {
        res.status(400).json({ error: err.message });
    }
});

// Lấy đơn hàng theo user
router.get('/my', verifyToken, async (req, res) => {
    try {
        const snapshot = await db.collection('orders').where('userId', '==', req.user.uid).get();
        const orders = snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
        res.status(200).json(orders);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// Lấy tất cả đơn hàng (admin)
router.get('/', verifyToken, isAdmin, async (req, res) => {
    try {
        const snapshot = await db.collection('orders').get();
        const orders = snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
        res.status(200).json(orders);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// Cập nhật trạng thái đơn hàng (admin)
router.put('/:id/status', verifyToken, isAdmin, async (req, res) => {
    try {
        await db.collection('orders').doc(req.params.id).update({ status: req.body.status });
        res.status(200).json({ message: 'Cập nhật trạng thái thành công' });
    } catch (err) {
        res.status(400).json({ error: err.message });
    }
});

module.exports = router;
