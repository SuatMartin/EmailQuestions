const express = require('express');
const path = require('path');
const cors = require('cors');

const app = express();
const PORT = 8000;

// Use middleware to parse JSON request bodies
app.use(cors());
app.use(express.json()); // Parse JSON body
app.use(express.static(path.join(__dirname, 'public')));

// Serve reCAPTCHA HTML page
app.get('/recaptcha', (req, res) => {
    res.sendFile(path.join(__dirname, 'public', 'recaptcha.html'));
});

// Endpoint to check CAPTCHA status (Mocked response for now)
app.get('/captcha-status', (req, res) => {
    res.json({ success: true }); // Change this logic later for real verification
});

// Endpoint to handle successful CAPTCHA verification
app.post('/captcha-success', (req, res) => {
    // Here you can mock the verification logic or integrate with Google reCAPTCHA
    const captchaVerified = true;  // Mocking success

    if (captchaVerified) {
        // Return a success message
        res.json({ success: true, message: 'CAPTCHA verified successfully!' });
    } else {
        // Return failure message
        res.json({ success: false, message: 'CAPTCHA verification failed.' });
    }
});

app.listen(PORT, () => {
    console.log(`✅ Server running on http://localhost:${PORT}`);
});