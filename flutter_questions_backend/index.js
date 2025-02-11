require('dotenv').config();
const express = require('express');
const mysql = require('mysql2');
const bodyParser = require('body-parser');
const cors = require('cors');
const nodemailer = require('nodemailer');
const schedule = require('node-schedule');

const app = express();
const port = process.env.PORT;

app.use(bodyParser.json());
app.use(cors());

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