const express = require('express');
const router = express.Router();
const admin = require('firebase-admin');
const db = admin.firestore();

// Middleware to verify Firebase authentication token
const verifyToken = async (req, res, next) => {
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
        return res.status(401).json({ error: 'Unauthorized - No token provided' });
    }

    const token = authHeader.split(' ')[1];
    try {
        const decodedToken = await admin.auth().verifyIdToken(token);
        req.user = decodedToken;
        next();
    } catch (error) {
        console.error('Error verifying token:', error);
        return res.status(401).json({ error: 'Unauthorized - Invalid token' });
    }
};

// Get all ratings for a product
router.get('/product/:productId', async (req, res) => {
    try {
        const { productId } = req.params;
        console.log(`Getting ratings for product: ${productId}`);

        const snapshot = await db.collection('ratings')
            .where('productId', '==', productId)
            .orderBy('createdAt', 'desc')
            .get();

        const ratings = snapshot.docs.map(doc => ({
            id: doc.id,
            ...doc.data(),
            createdAt: doc.data().createdAt ? doc.data().createdAt.toDate().toISOString() : new Date().toISOString()
        }));

        res.status(200).json(ratings);
    } catch (err) {
        console.error('Error getting ratings:', err);
        res.status(500).json({ error: err.message });
    }
});

// Get average rating for a product
router.get('/product/:productId/average', async (req, res) => {
    try {
        const { productId } = req.params;

        const snapshot = await db.collection('ratings')
            .where('productId', '==', productId)
            .get();

        if (snapshot.empty) {
            return res.status(200).json({ averageRating: 0, count: 0 });
        }

        let totalRating = 0;
        snapshot.forEach(doc => {
            totalRating += doc.data().rating;
        });

        const averageRating = totalRating / snapshot.size;

        res.status(200).json({
            averageRating: parseFloat(averageRating.toFixed(1)),
            count: snapshot.size
        });
    } catch (err) {
        console.error('Error calculating average rating:', err);
        res.status(500).json({ error: err.message });
    }
});

// Add a new rating (requires authentication)
router.post('/', verifyToken, async (req, res) => {
    try {
        const ratingData = req.body;
        const userId = req.user.uid;

        // Check if rating data has required fields
        if (!ratingData.productId || !ratingData.rating) {
            return res.status(400).json({ error: 'Missing required rating information' });
        }

        // Check if user has already rated this product
        const existingRatings = await db.collection('ratings')
            .where('productId', '==', ratingData.productId)
            .where('userId', '==', userId)
            .get();

        if (!existingRatings.empty) {
            return res.status(400).json({ error: 'You have already rated this product. Please edit your existing rating.' });
        }

        // Create new rating
        const newRating = {
            ...ratingData,
            userId,
            createdAt: admin.firestore.FieldValue.serverTimestamp(),
        };

        const docRef = await db.collection('ratings').add(newRating);

        // Update with ID
        await docRef.update({ id: docRef.id });

        res.status(201).json({
            id: docRef.id,
            ...newRating,
            message: 'Rating added successfully'
        });
    } catch (err) {
        console.error('Error adding rating:', err);
        res.status(500).json({ error: err.message });
    }
});

// Delete a rating (requires authentication and must be the rating creator)
router.delete('/:id', verifyToken, async (req, res) => {
    try {
        const { id } = req.params;
        const userId = req.user.uid;

        // Check if rating exists
        const ratingRef = db.collection('ratings').doc(id);
        const rating = await ratingRef.get();

        if (!rating.exists) {
            return res.status(404).json({ error: 'Rating not found' });
        }

        // Check if user has permission to delete (only the creator can delete)
        if (rating.data().userId !== userId) {
            return res.status(403).json({ error: 'You do not have permission to delete this rating' });
        }

        // Delete the rating
        await ratingRef.delete();

        res.status(200).json({ message: 'Rating deleted successfully' });
    } catch (err) {
        console.error('Error deleting rating:', err);
        res.status(500).json({ error: err.message });
    }
});

// Update a rating (requires authentication and must be the rating creator)
router.put('/:id', verifyToken, async (req, res) => {
    try {
        const { id } = req.params;
        const userId = req.user.uid;
        const updateData = req.body;

        // Check if rating exists
        const ratingRef = db.collection('ratings').doc(id);
        const rating = await ratingRef.get();

        if (!rating.exists) {
            return res.status(404).json({ error: 'Rating not found' });
        }

        // Check if user has permission to update (only the creator can update)
        if (rating.data().userId !== userId) {
            return res.status(403).json({ error: 'You do not have permission to update this rating' });
        }

        // Update the rating
        const newData = {
            ...updateData,
            updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        };

        await ratingRef.update(newData);

        res.status(200).json({
            id,
            ...newData,
            message: 'Rating updated successfully'
        });
    } catch (err) {
        console.error('Error updating rating:', err);
        res.status(500).json({ error: err.message });
    }
});

module.exports = router; 