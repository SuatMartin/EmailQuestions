require('dotenv').config();
const express = require('express');
const mysql = require('mysql2');
const bodyParser = require('body-parser');
const cors = require('cors');
const rateLimit = require("express-rate-limit");
const axios = require("axios");
const nodemailer = require('nodemailer');
const schedule = require('node-schedule');

const app = express();
const port = process.env.PORT;
app.use(bodyParser.json());
app.use(express.json());
app.use(cors());

// Rate limiter: Allow only 3 requests per 10 minutes per IP
const emailRateLimiter = rateLimit({
  windowMs: 10 * 60 * 1000, // 10 minutes
  max: 3, // Limit each IP to 3 requests per windowMs
  message: { error: "Too many requests, please try again later." },
  standardHeaders: true,
  legacyHeaders: false,
});


// Middleware to log requests
app.use((req, res, next) => {
  console.log(`Request from IP: ${req.ip}`);
  next();
});

// MySQL connection setup
const db = mysql.createConnection({
  host: process.env.DB_HOST,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,
});

db.connect(err => {
  if (err) {
    console.error('Error connecting to the database:', err);
    return;
  }
  console.log('Connected to the MySQL database.');
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


app.post(process.env.ENDPOINT_SEND_MAI, emailRateLimiter, async (req, res) => {
  try {
    const { topic, email, message, toEmail, name, question } = req.body;
    const directorEmail = process.env.DIRECTOR_EMAIL;

    // Email options for the recipient
    const recipientMailOptions = {
      from: process.env.EMAIL_USER,
      to: toEmail,
      subject: `Nueva Pregunta: ${topic}`,
      text: `Saludos,\n\nHa recibido una pregunta nueva.\n\nTema: ${topic}\nNombre de la persona que pregunto: ${name}\nAsunto: ${question}\nPregunta Detallada: ${message}\nDesde: ${email}\n\nMejores Deseos,`,
    };

    // Send first email (to the recipient)
    await transporter.sendMail(recipientMailOptions);
    console.log("First email sent successfully");

    // Email options for the director
    const directorMailOptions = {
      from: process.env.EMAIL_USER,
      to: directorEmail,
      subject: `Se ha enviado una nueva pregunta - ${topic}`,
      text: `Saludos Director,\n\nSe ha enviado una nueva pregunta.\n\nTema: ${topic}\nPregunta Detallada: ${message}\n\nMejores Deseos,`,
    };

    // Send second email (to the director)
    await transporter.sendMail(directorMailOptions);
    console.log("Second email (to director) sent successfully");

    // Increment the topic count
    const countUpdateResponse = await axios.post("http://localhost:3000/increment-email-count", { topic });

    if (countUpdateResponse.status === 200) {
      console.log("Topic count updated successfully");
      return res.json({ success: "Emails sent and topic count updated" });
    } else {
      console.error("Failed to update topic count:", countUpdateResponse.data);
      return res.status(500).json({ error: "Failed to update topic count" });
    }
  } catch (error) {
    console.error("Error:", error);
    return res.status(500).json({ error: "Internal server error" });
  }
});

app.post(process.env.ENDPOINT_INCREMENT_COUNT, async (req, res) => {
  try {
    const { topic } = req.body;

    if (!topic) {
      return res.status(400).json({ error: 'Topic is required' });
    }

    // Use the query from the .env file
    await db.promise().query(process.env.SQL_INCREMENT_COUNT, [topic]);

    res.status(200).json({ message: 'Count incremented successfully' });
  } catch (error) {
    console.error('Error incrementing email count:', error);
    res.status(500).json({ error: 'Internal Server Error' });
  }
});

const sendEmailWithStats = async () => {
  try {
    // Fetch topics and counts from the database
    const [rows] = await db.promise().query(process.env.SQL_SELECT_TOPICS);

    if (rows.length === 0) {
      console.log('No data to send.');
      return;
    }

    // Create email content
    let emailContent = 'Here are the topics and their counts:\n\n';
    rows.forEach(row => {
      emailContent += `Topic: ${row.topic}, Count: ${row.count}\n`;
    });

    // Send the email
    const mailOptions = {
      from: process.env.EMAIL_USER,
      to: process.env.EMAIL_RECIPIENT,
      subject: 'Monthly Topics and Counts Report',
      text: emailContent,
    };

    await transporter.sendMail(mailOptions);
    console.log('Email sent successfully!');

    // Reset all counts to 0 after the email is sent
    await db.promise().query(process.env.SQL_RESET_COUNTS);
    console.log('Counts reset to 0.');

  } catch (error) {
    console.error('Error sending email:', error);
  }
};

// Schedule the email to be sent on the 1st of each month at 8:00 AM
schedule.scheduleJob(process.env.CRON_SCHEDULE, () => {
  console.log('Running scheduled monthly email job...');
  sendEmailWithStats();
});

// Start the server
app.listen(port, () => {
  console.log(`Server is running on http://localhost:${port}`);
});