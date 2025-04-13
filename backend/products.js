// 📁 routes/products.js
const express = require('express');
const router = express.Router();
const admin = require('firebase-admin');
const db = admin.firestore();
const { verifyToken, isAdmin } = require('../middleware/verifyToken');

// Lấy tất cả sản phẩm
router.get('/', async (req, res) => {
    try {
        const snapshot = await db.collection('products').get();
        const products = snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
        res.status(200).json(products);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// Thêm route tìm kiếm sản phẩm
router.get('/search', async (req, res) => {
    try {
        const searchQuery = req.query.query?.toLowerCase() || '';
        const snapshot = await db.collection('products').get();

        const products = snapshot.docs
            .map(doc => ({ id: doc.id, ...doc.data() }))
            .filter(product => {
                const title = product.title.toLowerCase();
                // Tìm kiếm không phân biệt chữ hoa/thường và dấu
                const normalizedTitle = title.normalize('NFD')
                    .replace(/[\u0300-\u036f]/g, '')
                    .replace(/đ/g, 'd')
                    .replace(/Đ/g, 'D');
                const normalizedQuery = searchQuery.normalize('NFD')
                    .replace(/[\u0300-\u036f]/g, '')
                    .replace(/đ/g, 'd')
                    .replace(/Đ/g, 'D');

                return normalizedTitle.includes(normalizedQuery);
            });

        res.status(200).json(products);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// Thêm sản phẩm (admin)
router.post('/', verifyToken, isAdmin, async (req, res) => {
    try {
        const data = req.body;
        const docRef = await db.collection('products').add(data);
        res.status(201).json({ id: docRef.id, ...data });
    } catch (err) {
        res.status(400).json({ error: err.message });
    }
});

// Cập nhật sản phẩm (admin)
router.put('/:id', verifyToken, isAdmin, async (req, res) => {
    try {
        await db.collection('products').doc(req.params.id).update(req.body);
        res.status(200).json({ message: 'Cập nhật thành công' });
    } catch (err) {
        res.status(400).json({ error: err.message });
    }
});

// Xóa sản phẩm (admin)
router.delete('/:id', verifyToken, isAdmin, async (req, res) => {
    try {
        await db.collection('products').doc(req.params.id).delete();
        res.status(200).json({ message: 'Xóa thành công' });
    } catch (err) {
        res.status(400).json({ error: err.message });
    }
});

module.exports = router;
