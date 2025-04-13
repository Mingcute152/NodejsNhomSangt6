// 📁 middleware/verifyToken.js
const admin = require('firebase-admin');

// Middleware xác thực token Firebase
async function verifyToken(req, res, next) {
    try {
        const authHeader = req.headers['authorization'];
        if (!authHeader) {
            return res.status(403).json({ error: 'Không tìm thấy token' });
        }

        // Extract token from 'Bearer TOKEN' format
        const token = authHeader.split(' ')[1];
        if (!token) {
            return res.status(403).json({ error: 'Định dạng token không hợp lệ' });
        }

        // Verify Firebase token
        const decodedToken = await admin.auth().verifyIdToken(token);

        // Set user info in request object
        req.user = {
            uid: decodedToken.uid,
            email: decodedToken.email,
            name: decodedToken.name
        };

        next();
    } catch (error) {
        console.error('Token verification error:', error);
        return res.status(401).json({ error: 'Không thể xác thực: ' + error.message });
    }
}

// Middleware kiểm tra quyền admin
function isAdmin(req, res, next) {
    if (req.user?.email?.includes('admin')) {
        next();
    } else {
        res.status(403).json({ error: 'Bạn không có quyền admin' });
    }
}

module.exports = { verifyToken, isAdmin };
