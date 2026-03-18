const express = require('express');
const pkg = require('pg');
const jwt = require('jsonwebtoken');
const cors = require('cors');
require('dotenv').config();

const { Pool } = pkg;

const app = express();
app.use(cors());
app.use(express.json());

const pool = new Pool({
  user: process.env.DB_USER || 'postgres',
  password: process.env.DB_PASSWORD || 'postgres',
  host: process.env.DB_HOST || 'shipments-db',
  port: process.env.DB_PORT || 5432,
  database: process.env.DB_NAME || 'shipments_db'
});

const JWT_SECRET = process.env.JWT_SECRET || 'your-secret-key';

const verifyToken = (req, res, next) => {
  const token = req.headers.authorization?.split(' ')[1];
  if (!token) return res.status(401).json({ error: 'No token' });
  
  try {
    const decoded = jwt.verify(token, JWT_SECRET);
    req.userId = decoded.id;
    next();
  } catch (err) {
    res.status(401).json({ error: 'Invalid token' });
  }
};

app.get('/shipments', verifyToken, async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM shipments ORDER BY created_at DESC');
    res.json(result.rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.get('/shipments/:id', verifyToken, async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM shipments WHERE id = $1', [req.params.id]);
    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Shipment not found' });
    }
    res.json(result.rows[0]);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.post('/shipments', verifyToken, async (req, res) => {
  const { order_id, origin, destination, carrier } = req.body;
  try {
    const trackingNumber = 'TRK' + Date.now();
    const result = await pool.query(
      'INSERT INTO shipments (order_id, origin, destination, carrier, tracking_number, status) VALUES ($1, $2, $3, $4, $5, $6) RETURNING *',
      [order_id, origin, destination, carrier, trackingNumber, 'pending']
    );
    res.status(201).json(result.rows[0]);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.put('/shipments/:id', verifyToken, async (req, res) => {
  const { status } = req.body;
  try {
    const result = await pool.query(
      'UPDATE shipments SET status = $1 WHERE id = $2 RETURNING *',
      [status, req.params.id]
    );
    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Shipment not found' });
    }
    res.json(result.rows[0]);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.get('/shipments/track/:tracking_number', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM shipments WHERE tracking_number = $1', [req.params.tracking_number]);
    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Shipment not found' });
    }
    res.json(result.rows[0]);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.delete('/shipments/:id', verifyToken, async (req, res) => {
  try {
    const result = await pool.query('DELETE FROM shipments WHERE id = $1 RETURNING id', [req.params.id]);
    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Shipment not found' });
    }
    res.json({ message: 'Shipment deleted' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.get('/shipments/count', verifyToken, async (req, res) => {
  try {
    const result = await pool.query('SELECT COUNT(*) as count FROM shipments');
    res.json({ count: parseInt(result.rows[0].count) });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.get('/health', (req, res) => {
  res.json({ status: 'Shipments service is running' });
});

const PORT = process.env.PORT || 3003;
app.listen(PORT, () => {
  console.log(`Shipments service running on port ${PORT}`);
});
