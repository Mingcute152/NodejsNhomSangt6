const orderRepository = require('../repositories/orderRepository');

class OrderService {
    async createOrder(orderData) {
        if (!orderData.userId || !orderData.products) {
            throw new Error('Dữ liệu đơn hàng không hợp lệ');
        }
        return await orderRepository.createOrder(orderData);
    }

    async getOrdersByUserId(userId) {
        return await orderRepository.getOrdersByUserId(userId);
    }
}

module.exports = new OrderService();