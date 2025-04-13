const express = require('express');
const router = express.Router();
const admin = require('firebase-admin');
const { verifyToken } = require('../middlewares/verifyToken');
const db = admin.firestore();

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

// Thêm sản phẩm mới (cần đăng nhập)
router.post('/', verifyToken, async (req, res) => {
    try {
        const data = req.body;

        // Validate required fields
        if (!data.title || !data.image || !data.price || data.price <= 0) {
            return res.status(400).json({
                error: 'Thiếu thông tin sản phẩm cần thiết hoặc giá không hợp lệ'
            });
        }

        // Add timestamp and userId
        const productData = {
            ...data,
            createdAt: admin.firestore.FieldValue.serverTimestamp(),
            createdBy: req.user.uid,
        };

        const docRef = await db.collection('products').add(productData);

        // Update with ID
        await docRef.update({ id: docRef.id });

        res.status(201).json({
            id: docRef.id,
            ...productData,
            message: 'Thêm sản phẩm thành công'
        });
    } catch (err) {
        console.error('Error adding product:', err);
        res.status(400).json({ error: err.message });
    }
});

// Xóa sản phẩm (cần đăng nhập)
router.delete('/:id', verifyToken, async (req, res) => {
    try {
        const { id } = req.params;
        console.log(`Attempting to delete product with ID: ${id}`);

        // Kiểm tra tồn tại sản phẩm
        const productRef = db.collection('products').doc(id);
        const productDoc = await productRef.get();

        if (!productDoc.exists) {
            console.log(`Product not found: ${id}`);
            return res.status(404).json({ message: 'Sản phẩm không tồn tại' });
        }

        // Xóa sản phẩm
        await productRef.delete();

        console.log(`Product deleted successfully: ${id}`);

        // Trả về response đơn giản
        return res.status(200).json({ message: 'Xóa sản phẩm thành công' });
    } catch (err) {
        console.error(`Error: ${err.message}`);
        return res.status(500).json({ message: 'Lỗi khi xóa sản phẩm' });
    }
});

// Cập nhật sản phẩm (cần đăng nhập)
router.put('/:id', verifyToken, async (req, res) => {
    try {
        const { id } = req.params;
        const data = req.body;

        // Validate required fields
        if (data.price && data.price <= 0) {
            return res.status(400).json({ error: 'Giá không hợp lệ' });
        }

        // Check if product exists
        const productRef = db.collection('products').doc(id);
        const productDoc = await productRef.get();

        if (!productDoc.exists) {
            return res.status(404).json({ error: 'Sản phẩm không tồn tại' });
        }

        // Update product
        const updateData = {
            ...data,
            updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        };

        await productRef.update(updateData);

        res.status(200).json({
            id,
            ...updateData,
            message: 'Cập nhật sản phẩm thành công'
        });
    } catch (err) {
        console.error('Error updating product:', err);
        res.status(500).json({ error: err.message });
    }
});

// Tìm kiếm sản phẩm
router.get('/search', async (req, res) => {
    try {
        const { query } = req.query;

        if (!query) {
            return res.status(400).json({ error: 'Thiếu từ khóa tìm kiếm' });
        }

        const snapshot = await db.collection('products').get();
        const products = snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));

        // Simple search in title and description
        const searchResults = products.filter(product =>
            product.title.toLowerCase().includes(query.toLowerCase()) ||
            (product.description && product.description.toLowerCase().includes(query.toLowerCase()))
        );

        res.status(200).json(searchResults);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

module.exports = router;