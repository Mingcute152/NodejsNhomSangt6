const express = require('express');
const cors = require('cors');
const admin = require('firebase-admin');

const app = express();
const port = 3000;

admin.initializeApp({
  credential: admin.credential.applicationDefault(), // hoặc dùng key từ file nếu có
});

const db = admin.firestore();

app.use(cors());
app.use(express.json());

// Import các router
const authRoutes = require('./routes/auth');
const productRoutes = require('./routes/products');
const orderRoutes = require('./routes/orders');
const cartRoutes = require('./routes/cart');

// Use routes
app.use('/api/auth', authRoutes);
app.use('/api/products', productRoutes);
app.use('/api/orders', orderRoutes);
app.use('/api/cart', cartRoutes);

app.get('/', (req, res) => {
  res.send('Hello from Node.js + Express + Firebase!');
});

app.listen(port, () => {
  console.log(`Server is running at http://localhost:${port}`);
});
