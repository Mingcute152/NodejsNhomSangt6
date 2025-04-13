const db = require('../config/firebase');

class OrderRepository {
    async createOrder(orderData) {
        const docRef = await db.collection('orders').add(orderData);
        return { id: docRef.id, ...orderData };
    }

    async getOrdersByUserId(userId) {
        const snapshot = await db.collection('orders').where('userId', '==', userId).get();
        return snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
    }
}

module.exports = new OrderRepository();