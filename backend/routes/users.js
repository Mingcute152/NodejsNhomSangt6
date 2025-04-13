const express = require('express');
const router = express.Router();
const admin = require('firebase-admin');
const db = admin.firestore();
const { verifyToken } = require('../middlewares/verifyToken');

// Lấy thông tin user
router.get('/profile', verifyToken, async (req, res) => {
    try {
        const userDoc = await db.collection('users').doc(req.user.uid).get();
        if (!userDoc.exists) {
            return res.status(404).json({ message: 'User not found' });
        }
        res.status(200).json(userDoc.data());
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// Cập nhật thông tin user
router.put('/profile', verifyToken, async (req, res) => {
    try {
        await db.collection('users').doc(req.user.uid).update(req.body);
        res.status(200).json({ message: 'Profile updated successfully' });
    } catch (err) {
        res.status(400).json({ error: err.message });
    }
});
router.post('/logout', verifyToken, async (req, res) => {
    try {
        await admin.auth().revokeRefreshTokens(req.user.uid);
        res.status(200).json({ message: 'Logged out successfully' });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});
router.delete('/delete-account', verifyToken, async (req, res) => {
    try {
        await admin.auth().deleteUser(req.user.uid);
        await admin.firestore().collection('users').doc(req.user.uid).delete();
        res.status(200).json({ message: 'Account deleted successfully' });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

module.exports = router;