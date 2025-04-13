// 📁 routes/orders.js
const express = require('express');
const router = express.Router();
const admin = require('firebase-admin');
const { verifyToken } = require('../middlewares/verifyToken');

// Create order
router.post('/', verifyToken, async (req, res) => {
    try {
        const { products, totalAmount, shippingAddress } = req.body;
        const userId = req.user.uid;

        const orderRef = await admin.firestore().collection('orders').add({
            userId,
            products,
            totalAmount,
            status: 'pending',
            orderDate: admin.firestore.FieldValue.serverTimestamp(),
            shippingAddress
        });

        // Clear user's cart after successful order
        await admin.firestore().collection('carts').doc(userId).update({
            products: []
        });

        res.status(201).json({
            success: true,
            orderId: orderRef.id,
            message: 'Order created successfully'
        });
    } catch (error) {
        console.error('Create order error:', error);
        res.status(500).json({
            success: false,
            error: error.message
        });
    }
});

// Get user orders
router.get('/user', verifyToken, async (req, res) => {
    try {
        const userId = req.user.uid;
        const ordersSnapshot = await admin.firestore()
            .collection('orders')
            .where('userId', '==', userId)
            .orderBy('orderDate', 'desc')
            .get();

        const orders = [];
        ordersSnapshot.forEach(doc => {
            orders.push({
                id: doc.id,
                ...doc.data()
            });
        });

        res.status(200).json(orders);
    } catch (error) {
        console.error('Get orders error:', error);
        res.status(500).json({
            success: false,
            error: error.message
        });
    }
});

module.exports = router;
