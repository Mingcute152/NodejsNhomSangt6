// Simple test for the ratings API using ES modules
import fetch from 'node-fetch';

// Test the health check endpoint
async function testHealthCheck() {
    try {
        console.log('Testing health check endpoint...');
        const response = await fetch('http://localhost:3000/health');
        const data = await response.json();
        console.log('Health check successful:', data);
        return response.ok;
    } catch (error) {
        console.error('Health check failed:', error.message);
        return false;
    }
}

// Test getting ratings for a product
async function testGetRatings() {
    const productId = 'test-product';

    try {
        console.log(`Testing GET ratings for product: ${productId}`);
        console.log(`URL: http://localhost:3000/api/ratings/product/${productId}`);

        const response = await fetch(`http://localhost:3000/api/ratings/product/${productId}`);
        console.log('Response status:', response.status);

        const contentType = response.headers.get('content-type');
        console.log('Content-Type:', contentType);

        if (contentType && contentType.includes('application/json')) {
            const data = await response.json();
            console.log('Response data:', JSON.stringify(data, null, 2));
        } else {
            const text = await response.text();
            console.log('Response text:', text.substring(0, 500) + (text.length > 500 ? '...' : ''));
        }

        return response.ok;
    } catch (error) {
        console.error('Error testing ratings:', error);
        return false;
    }
}

async function testAddRating() {
    const testRating = {
        productId: 'test-product',
        rating: 4.5,
        comment: 'Test rating from Node.js script',
        userName: 'Test User'
    };

    try {
        console.log('Testing POST rating with data:', JSON.stringify(testRating, null, 2));
        // Note: This will fail without authentication, but we're checking the error format
        const response = await fetch('http://localhost:3000/api/ratings', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(testRating)
        });

        console.log('Response status:', response.status);

        const contentType = response.headers.get('content-type');
        console.log('Content-Type:', contentType);

        if (contentType && contentType.includes('application/json')) {
            const data = await response.json();
            console.log('Response data:', JSON.stringify(data, null, 2));
        } else {
            const text = await response.text();
            console.log('Response text:', text.substring(0, 500) + (text.length > 500 ? '...' : ''));
        }

        // We expect a 401 error due to lack of authentication
        return response.status === 401;
    } catch (error) {
        console.error('Error testing add rating:', error);
        return false;
    }
}

async function checkFirestore() {
    try {
        console.log('\nTesting Firestore connection endpoint...');
        const response = await fetch('http://localhost:3000/api/debug/firestore');
        console.log('Response status:', response.status);

        const contentType = response.headers.get('content-type');
        if (contentType && contentType.includes('application/json')) {
            const data = await response.json();
            console.log('Response data:', JSON.stringify(data, null, 2));
        } else {
            const text = await response.text();
            console.log('Response text:', text.substring(0, 500));
        }
    } catch (error) {
        console.error('Error testing Firestore connection:', error);
    }
}

// Run tests
async function runTests() {
    console.log('=== Starting API tests ===');

    // Test health first to make sure server is running
    const serverRunning = await testHealthCheck();
    if (!serverRunning) {
        console.error('Server health check failed - skipping remaining tests');
        return;
    }

    console.log('\n--- Testing ratings endpoints ---');
    await testGetRatings();

    console.log('\n--- Testing add rating endpoint ---');
    await testAddRating();

    // Check Firestore connection
    await checkFirestore();

    console.log('\n=== Tests completed ===');
}

runTests(); 