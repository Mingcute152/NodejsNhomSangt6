const db = require('../config/firebase');

class CartRepository {
    async getCartByUserId(userId) {
        const snapshot = await db.collection('carts').doc(userId).get();
        return snapshot.exists ? { id: snapshot.id, ...snapshot.data() } : null;
    }

    async updateCart(userId, cartData) {
        await db.collection('carts').doc(userId).set(cartData);
    }

    async deleteCart(userId) {
        await db.collection('carts').doc(userId).delete();
    }
}

module.exports = new CartRepository();