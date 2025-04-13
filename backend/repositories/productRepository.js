const db = require('../config/firebase');

class ProductRepository {
    async getAllProducts() {
        const snapshot = await db.collection('products').get();
        return snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
    }

    async addProduct(data) {
        const docRef = await db.collection('products').add(data);
        return { id: docRef.id, ...data };
    }

    async deleteProduct(id) {
        await db.collection('products').doc(id).delete();
    }
}

module.exports = new ProductRepository();