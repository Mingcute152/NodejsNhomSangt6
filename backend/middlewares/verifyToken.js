// 📁 middleware/verifyToken.js
const jwt = require('jsonwebtoken');
const JWT_SECRET = 'your_jwt_secret_key'; // ❗ Replace this with env var in production

// Middleware xác thực token
function verifyToken(req, res, next) {
    const token = req.headers.authorization?.split(' ')[1];
    if (!token) return res.status(401).json({ error: 'Token không được cung cấp' });

    try {
        const decoded = jwt.verify(token, JWT_SECRET);
        req.user = decoded; // Gắn info user vào request
        next();
    } catch (error) {
        res.status(403).json({ error: 'Token không hợp lệ' });
    }
}

// Middleware kiểm tra quyền admin
function isAdmin(req, res, next) {
    if (req.user?.email === 'admin@gmail.com') {
        next();
    } else {
        res.status(403).json({ error: 'Bạn không có quyền admin' });
    }
}

module.exports = { verifyToken, isAdmin };
