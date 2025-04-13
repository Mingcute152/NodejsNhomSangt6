const express = require('express');
const router = express.Router();
const admin = require('firebase-admin');

// Debug endpoint for testing Firestore connection
router.get('/firestore', async (req, res) => {
    try {
        // Simple test query to Firestore
        const db = admin.firestore();
        const testRef = db.collection('debug_tests').doc('connection_test');

        // Write a test document with timestamp
        const timestamp = new Date().toISOString();
        await testRef.set({
            lastChecked: timestamp,
            status: 'success'
        });

        // Read the document back
        const docSnapshot = await testRef.get();

        // Return status info
        return res.status(200).json({
            success: true,
            message: 'Firestore connection successful',
            data: docSnapshot.data(),
            timestamp: timestamp
        });
    } catch (error) {
        console.error('Firestore debug test failed:', error);
        return res.status(500).json({
            success: false,
            message: 'Firestore connection failed',
            error: error.message,
            stack: process.env.NODE_ENV === 'development' ? error.stack : undefined
        });
    }
});

module.exports = router; 