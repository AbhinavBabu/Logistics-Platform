const express = require('express');
const pkg = require('pg');
const cors = require('cors');
require('dotenv').config();

const { Pool } = pkg;

const app = express();
app.use(cors());
app.use(express.json());

const pool = new Pool({
  user: process.env.DB_USER || 'postgres',
  password: process.env.DB_PASSWORD || 'postgres',
  host: process.env.DB_HOST || 'notifications-db',
  port: process.env.DB_PORT || 5432,
  database: process.env.DB_NAME || 'notifications_db'
});

app.post('/notify', async (req, res) => {
  const { user_id, type, message } = req.body;
  try {
    const result = await pool.query(
      'INSERT INTO notifications (user_id, type, message, read) VALUES ($1, $2, $3, $4) RETURNING *',
      [user_id, type, message, false]
    );
    res.status(201).json(result.rows[0]);
  } catch (err) {
    console.error('Error creating notification:', err);
    res.status(500).json({ error: err.message });
  }
});

app.get('/notifications/:user_id', async (req, res) => {
  try {
    const result = await pool.query(
      'SELECT * FROM notifications WHERE user_id = $1 ORDER BY created_at DESC',
      [req.params.user_id]
    );
    res.json(result.rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.put('/notifications/:id/read', async (req, res) => {
  try {
    const result = await pool.query(
      'UPDATE notifications SET read = true WHERE id = $1 RETURNING *',
      [req.params.id]
    );
    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Notification not found' });
    }
    res.json(result.rows[0]);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.get('/health', (req, res) => {
  res.json({ status: 'Notifications service is running' });
});

const PORT = process.env.PORT || 3005;
app.listen(PORT, () => {
  console.log(`Notifications service running on port ${PORT}`);
});
