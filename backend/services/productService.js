const productRepository = require('../repositories/productRepository');

class ProductService {
    async getAllProducts() {
        return await productRepository.getAllProducts();
    }

    async addProduct(data) {
        if (!data.name || !data.price) {
            throw new Error('Tên sản phẩm và giá là bắt buộc');
        }
        return await productRepository.addProduct(data);
    }

    async deleteProduct(id) {
        return await productRepository.deleteProduct(id);
    }
}

module.exports = new ProductService();