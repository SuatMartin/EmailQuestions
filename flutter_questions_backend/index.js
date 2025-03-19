require('dotenv').config();
const { JWT } = require('google-auth-library');
const express = require('express');
const bodyParser = require('body-parser');
const cors = require('cors');
const rateLimit = require("express-rate-limit");
const axios = require("axios");
const nodemailer = require('nodemailer');
const schedule = require('node-schedule');
const { GoogleSpreadsheet } = require('google-spreadsheet');

const SHEET_ID = process.env.SHEET_ID;
const serviceAccountAuth = new JWT({
  email: process.env.GOOGLE_SERVICE_ACCOUNT_EMAIL,
  key: process.env.GOOGLE_PRIVATE_KEY.replace(/\\n/g, '\n'),
  scopes: [
      'https://www.googleapis.com/auth/spreadsheets',
  ],
});

const doc = new GoogleSpreadsheet(SHEET_ID, serviceAccountAuth);

const app = express();
const port = process.env.PORT;
app.use(bodyParser.json());
app.use(express.json());
app.use(cors());

// In-memory store to track requests by IP
const requestCountByIP = {};

// In-memory blacklist of abusive IPs
const blacklistedIPs = new Set();

// Rate limiter: Allow only 3 requests per 10 minutes per IP
const emailRateLimiter = rateLimit({
  windowMs: 10 * 60 * 1000, // 10 minutes
  max: 3, // Limit each IP to 3 requests per windowMs
  message: { error: "Too many requests, please try again later." },
  standardHeaders: true,
  legacyHeaders: false,
});

// Middleware to log requests, track requests per IP, and check blacklist
app.use((req, res, next) => {
  const ip = req.ip;

  // Check if the IP is blacklisted
  if (blacklistedIPs.has(ip)) {
    return res.status(403).json({ error: "Your IP is blacklisted due to suspicious activity." });
  }

  // Increment the count for the IP
  if (!requestCountByIP[ip]) {
    requestCountByIP[ip] = 0;
  }
  requestCountByIP[ip]++;

  // Log the number of requests from this IP
  console.log(`IP: ${ip}, Requests received: ${requestCountByIP[ip]}`);

  next();
});

// Nodemailer transporter setup
const transporter = nodemailer.createTransport({
  service: 'gmail',
  auth: {
    user: process.env.EMAIL_USER,
    pass: process.env.EMAIL_PASSWORD,
  },
});

async function sendEmail(serviceId, templateId, userId, templateParams) {
  return axios.post("https://api.emailjs.com/api/v1.0/email/send", {
    service_id: serviceId,
    template_id: templateId,
    user_id: userId,
    template_params: templateParams,
  });
}

app.post(process.env.ENDPOINT_SEND_MAIL, emailRateLimiter, async (req, res) => {
  try {
    const { topic, email, message, toEmail, name, question } = req.body;
    const directorEmail = process.env.DIRECTOR_EMAIL;

    const recipientMailOptions = {
      from: process.env.EMAIL_USER,
      to: toEmail,
      subject: `Nueva Pregunta: ${topic}`,
      text: `Saludos,\n\nHa recibido una pregunta nueva.\n\nTema: ${topic}\nNombre de la persona que pregunto: ${name}\nAsunto: ${question}\nPregunta Detallada: ${message}\nDesde: ${email}\n\nMejores Deseos,`,
    };

    await transporter.sendMail(recipientMailOptions);
    console.log("First email sent successfully");

    const directorMailOptions = {
      from: process.env.EMAIL_USER,
      to: directorEmail,
      subject: `Se ha enviado una nueva pregunta - ${topic}`,
      text: `Saludos Director,\n\nSe ha enviado una nueva pregunta.\n\nTema: ${topic}\nPregunta Detallada: ${message}\n\nMejores Deseos,`,
    };

    await transporter.sendMail(directorMailOptions);
    console.log("Second email (to director) sent successfully");

    return res.json({ success: "Emails sent and topic count updated" });
  } catch (error) {
    console.error("Error:", error);
    return res.status(500).json({ error: "Internal server error" });
  }
});

async function incrementCount(topic) {
  try {
    await doc.loadInfo();
    const sheet = doc.sheetsByIndex[0];

    await sheet.loadHeaderRow();
    console.log("Sheet Headers:", sheet.headerValues);

    let rows = await sheet.getRows();
    let topicIndex = sheet.headerValues.indexOf("Topic");
    let countIndex = sheet.headerValues.indexOf("Count");

    if (topicIndex === -1 || countIndex === -1) {
      console.error("Error: 'Topic' or 'Count' column not found.");
      return;
    }

    let topics = rows.map(row => row._rawData[topicIndex]?.trim() || "[Empty]");
    console.log("Sheet rows (Topics):", topics);

    let topicRow = rows.find(row =>
      row._rawData[topicIndex]?.trim().toLowerCase() === topic.trim().toLowerCase()
    );

    if (topicRow) {
      let currentCount = parseInt(topicRow.get("Count")) || 0; // Read properly
      topicRow.set("Count", currentCount + 1); // Update count properly
      await topicRow.save();
      console.log(`Updated count for topic: ${topic}`);
    } else {
      await sheet.addRow({ Topic: topic, Count: 1 });
      console.log(`Added new topic: ${topic}`);
    }
  } catch (error) {
    console.error("Error updating Google Sheet:", error);
  }
}

app.post(process.env.ENDPOINT_INCREMENT_COUNT, async (req, res) => {
  try {
    const { topic } = req.body;
    if (!topic) return res.status(400).json({ error: 'Topic is required' });

    await incrementCount(topic);
    res.status(200).json({ message: 'Count incremented successfully' });
  } catch (error) {
    console.error('Error incrementing count:', error);
    res.status(500).json({ error: 'Internal Server Error' });
  }
});

// Admin route to add an IP to the blacklist
app.post('/admin/blacklist', (req, res) => {
  const { ip } = req.body;
  if (!ip) return res.status(400).json({ error: 'IP is required' });

  blacklistedIPs.add(ip);
  console.log(`IP ${ip} has been blacklisted.`);
  res.status(200).json({ message: `IP ${ip} has been blacklisted.` });
});

app.listen(port, () => {
  console.log(`Server is running on http://localhost:${port}`);
});