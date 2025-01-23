require('dotenv').config(); // Load environment variables from a .env file
const express = require('express');
const mysql = require('mysql2');
const bodyParser = require('body-parser');
const cors = require('cors');

const app = express();
const port = 3000;

app.use(bodyParser.json());
app.use(cors());

// MySQL connection setup using environment variables
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

// Route to increment email count
app.post('/increment-email-count', async (req, res) => {
  const { topic } = req.body;

  // Validate input
  if (!topic) {
    return res.status(400).json({ error: 'Topic is required' });
  }

  try {
    // Use the correct column names and table name
    const [results] = await db.promise().query(
      'UPDATE email_counts SET count = count + 1 WHERE topic = ?',
      [topic]
    );

    // Check if the topic was updated
    if (results.affectedRows === 0) {
      console.error(`Topic "${topic}" not found in the database.`);
      return res.status(404).json({ error: `Topic "${topic}" not found` });
    }

    console.log(`Count for topic "${topic}" incremented.`);
    res.status(200).json({ message: `Count for topic "${topic}" incremented.` });
  } catch (error) {
    console.error('Database error:', error);
    res.status(500).json({ error: 'Database error occurred.' });
  }
});

// Start the server
app.listen(port, () => {
  console.log(`Server is running on http://localhost:${port}`);
});