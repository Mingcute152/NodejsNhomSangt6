// Use dynamic import for node-fetch v3
const { default: fetch } = await import('node-fetch');

// Configuration
const API_BASE_URL = 'http://localhost:3000/api';
const TEST_PRODUCT_ID = 'test-product-123';

// Test functions
async function testGetRatings() {
    try {
        console.log(`\n📋 Testing GET ratings for product ${TEST_PRODUCT_ID}...`);
        const response = await fetch(`${API_BASE_URL}/ratings/product/${TEST_PRODUCT_ID}`);

        console.log(`Status: ${response.status}`);

        const data = await response.json();
        console.log('Response data:', JSON.stringify(data, null, 2));

        return data;
    } catch (error) {
        console.error('❌ Error getting ratings:', error.message);
    }
}

async function testGetAverageRating() {
    try {
        console.log(`\n⭐ Testing GET average rating for product ${TEST_PRODUCT_ID}...`);
        const response = await fetch(`${API_BASE_URL}/ratings/product/${TEST_PRODUCT_ID}/average`);

        console.log(`Status: ${response.status}`);

        const data = await response.json();
        console.log('Response data:', JSON.stringify(data, null, 2));

        return data;
    } catch (error) {
        console.error('❌ Error getting average rating:', error.message);
    }
}

async function testAddRating() {
    try {
        console.log(`\n➕ Testing POST new rating for product ${TEST_PRODUCT_ID}...`);
        console.log('Note: This will fail without a valid Firebase auth token');

        const testRating = {
            productId: TEST_PRODUCT_ID,
            rating: 4.5,
            comment: 'This is a test rating from the API tester',
            userName: 'Test User'
        };

        const response = await fetch(`${API_BASE_URL}/ratings`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'Authorization': 'Bearer YOUR_FIREBASE_TOKEN_HERE' // This will fail without a valid token
            },
            body: JSON.stringify(testRating)
        });

        console.log(`Status: ${response.status}`);

        const data = await response.json();
        console.log('Response data:', JSON.stringify(data, null, 2));

        return data;
    } catch (error) {
        console.error('❌ Error adding rating:', error.message);
    }
}

// Health check
async function testHealthCheck() {
    try {
        console.log('\n🏥 Testing health check endpoint...');
        const response = await fetch(`http://localhost:3000/health`);

        console.log(`Status: ${response.status}`);

        const data = await response.json();
        console.log('Response data:', JSON.stringify(data, null, 2));

        return data;
    } catch (error) {
        console.error('❌ Error with health check:', error.message);
    }
}

// Run tests
async function runTests() {
    console.log('🧪 Starting API tests...');

    // First check if server is running
    await testHealthCheck();

    // Then test the ratings endpoints
    await testGetRatings();
    await testGetAverageRating();
    await testAddRating();

    console.log('\n✅ Tests completed');
}

runTests(); 