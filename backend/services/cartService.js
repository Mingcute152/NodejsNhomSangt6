const cartRepository = require('../repositories/cartRepository');

class CartService {
    async getCart(userId) {
        return await cartRepository.getCartByUserId(userId);
    }

    async updateCart(userId, cartData) {
        return await cartRepository.updateCart(userId, cartData);
    }

    async deleteCart(userId) {
        return await cartRepository.deleteCart(userId);
    }
}

module.exports = new CartService();