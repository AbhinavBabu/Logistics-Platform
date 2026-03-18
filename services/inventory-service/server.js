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
  host: process.env.DB_HOST || 'inventory-db',
  port: process.env.DB_PORT || 5432,
  database: process.env.DB_NAME || 'inventory_db'
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

app.get('/inventory', verifyToken, async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM inventory_items ORDER BY updated_at DESC');
    res.json(result.rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.get('/inventory/:id', verifyToken, async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM inventory_items WHERE id = $1', [req.params.id]);
    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Item not found' });
    }
    res.json(result.rows[0]);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.post('/inventory', verifyToken, async (req, res) => {
  const { sku, name, quantity, warehouse, unit_price } = req.body;
  try {
    const result = await pool.query(
      'INSERT INTO inventory_items (sku, name, quantity, warehouse, unit_price) VALUES ($1, $2, $3, $4, $5) RETURNING *',
      [sku, name, quantity, warehouse, unit_price]
    );
    res.status(201).json(result.rows[0]);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.put('/inventory/:id', verifyToken, async (req, res) => {
  const { quantity, warehouse, unit_price } = req.body;
  try {
    const result = await pool.query(
      'UPDATE inventory_items SET quantity = COALESCE($1, quantity), warehouse = COALESCE($2, warehouse), unit_price = COALESCE($3, unit_price) WHERE id = $4 RETURNING *',
      [quantity, warehouse, unit_price, req.params.id]
    );
    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Item not found' });
    }
    res.json(result.rows[0]);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.post('/inventory/:id/adjust', verifyToken, async (req, res) => {
  const { adjustment } = req.body;
  try {
    const result = await pool.query(
      'UPDATE inventory_items SET quantity = quantity + $1 WHERE id = $2 RETURNING *',
      [adjustment, req.params.id]
    );
    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Item not found' });
    }
    res.json(result.rows[0]);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.delete('/inventory/:id', verifyToken, async (req, res) => {
  try {
    const result = await pool.query('DELETE FROM inventory_items WHERE id = $1 RETURNING id', [req.params.id]);
    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Item not found' });
    }
    res.json({ message: 'Item deleted' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.get('/inventory/count', verifyToken, async (req, res) => {
  try {
    const result = await pool.query('SELECT COUNT(*) as count FROM inventory_items');
    res.json({ count: parseInt(result.rows[0].count) });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.get('/health', (req, res) => {
  res.json({ status: 'Inventory service is running' });
});

const PORT = process.env.PORT || 3004;
app.listen(PORT, () => {
  console.log(`Inventory service running on port ${PORT}`);
});
