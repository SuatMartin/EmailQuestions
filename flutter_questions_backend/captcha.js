require('dotenv').config();
const express = require('express');
const path = require('path');
const cors = require('cors');
const axios = require('axios');

const app = express();
const PORT = process.env.PORT2;

// Load endpoint names from .env
const ENDPOINT_RECAPTCHA = process.env.ENDPOINT_RECAPTCHA;
const ENDPOINT_GET_SITE_KEY = process.env.ENDPOINT_GET_SITE_KEY;
const ENDPOINT_VERIFY_CAPTCHA = process.env.ENDPOINT_VERIFY_CAPTCHA;
const ENDPOINT_CAPTCHA_STATUS = process.env.ENDPOINT_CAPTCHA_STATUS;
const ENDPOINT_CAPTCHA_SUCCESS = process.env.ENDPOINT_CAPTCHA_SUCCESS;

let captchaVerified = false; // Store CAPTCHA verification status

app.use(cors());
app.use(express.json());
app.use(express.static(path.join(__dirname, 'public')));

// ✅ Serve reCAPTCHA HTML page
app.get(ENDPOINT_RECAPTCHA, (req, res) => {
    res.sendFile(path.join(__dirname, 'public', 'recaptcha.html'));
});

// ✅ Send reCAPTCHA Site Key to Frontend Securely
app.get(ENDPOINT_GET_SITE_KEY, (req, res) => {
    res.json({ siteKey: process.env.RECAPTCHA_SITE_KEY });
});

// ✅ Verify reCAPTCHA on Backend
app.post(ENDPOINT_VERIFY_CAPTCHA, async (req, res) => {
    const { token } = req.body;

    if (!token) {
        return res.status(400).json({ success: false, message: 'CAPTCHA token is required.' });
    }

    try {
        const response = await axios.post(`https://www.google.com/recaptcha/api/siteverify`, null, {
            params: {
                secret: process.env.RECAPTCHA_SECRET_KEY,
                response: token
            }
        });

        if (response.data.success) {
            captchaVerified = true;
            res.json({ success: true, message: 'CAPTCHA verified successfully!' });
        } else {
            res.json({ success: false, message: 'CAPTCHA verification failed.', error: response.data });
        }
    } catch (error) {
        res.status(500).json({ success: false, message: 'Error verifying CAPTCHA.', error: error.message });
    }
});

// ✅ Check CAPTCHA Status
app.get(ENDPOINT_CAPTCHA_STATUS, (req, res) => {
    res.json({ success: captchaVerified });
});

// ✅ Handle Successful CAPTCHA Verification
app.post(ENDPOINT_CAPTCHA_SUCCESS, (req, res) => {
    captchaVerified = true; // Mark CAPTCHA as verified

    res.json({ success: true, message: 'CAPTCHA verified successfully!' });
});

// ✅ General Catch-All Route for Static Files
app.get('*', (req, res) => {
    res.sendFile(path.join(__dirname, 'public', 'index.html'));
});

// ✅ Start the Server
app.listen(PORT, () => {
    console.log(`✅ Server running on http://localhost:${PORT}`);
});