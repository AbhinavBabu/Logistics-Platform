import React, { useState, useEffect } from 'react';
import axios from 'axios';

function Dashboard() {
  const [stats, setStats] = useState({
    totalUsers: 0,
    totalOrders: 0,
    totalShipments: 0,
    inventoryItems: 0
  });
  const [loading, setLoading] = useState(true);
  const token = localStorage.getItem('authToken');

  useEffect(() => {
    fetchDashboardStats();
  }, []);

  const fetchDashboardStats = async () => {
    try {
      const headers = { 'Authorization': `Bearer ${token}` };
      
      const [usersRes, ordersRes, shipmentsRes, inventoryRes] = await Promise.all([
        axios.get(`${process.env.REACT_APP_USERS_SERVICE_URL}/users/count`, { headers }),
        axios.get(`${process.env.REACT_APP_ORDERS_SERVICE_URL}/orders/count`, { headers }),
        axios.get(`${process.env.REACT_APP_SHIPMENTS_SERVICE_URL}/shipments/count`, { headers }),
        axios.get(`${process.env.REACT_APP_INVENTORY_SERVICE_URL}/inventory/count`, { headers })
      ]);

      setStats({
        totalUsers: usersRes.data.count || 0,
        totalOrders: ordersRes.data.count || 0,
        totalShipments: shipmentsRes.data.count || 0,
        inventoryItems: inventoryRes.data.count || 0
      });
    } catch (err) {
      console.error('Error fetching stats:', err);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="page-container">
      <h1>Dashboard</h1>
      {loading ? (
        <p>Loading...</p>
      ) : (
        <div className="stats-grid">
          <div className="stat-card">
            <h3>Total Users</h3>
            <p className="stat-value">{stats.totalUsers}</p>
          </div>
          <div className="stat-card">
            <h3>Total Orders</h3>
            <p className="stat-value">{stats.totalOrders}</p>
          </div>
          <div className="stat-card">
            <h3>Total Shipments</h3>
            <p className="stat-value">{stats.totalShipments}</p>
          </div>
          <div className="stat-card">
            <h3>Inventory Items</h3>
            <p className="stat-value">{stats.inventoryItems}</p>
          </div>
        </div>
      )}
      <style>{`
        .stats-grid {
          display: grid;
          grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
          gap: 1rem;
          margin-top: 2rem;
        }
        .stat-card {
          background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
          color: white;
          padding: 2rem;
          border-radius: 8px;
          text-align: center;
          box-shadow: 0 4px 6px rgba(0,0,0,0.1);
        }
        .stat-card h3 {
          font-size: 0.9rem;
          margin-bottom: 1rem;
          opacity: 0.9;
        }
        .stat-value {
          font-size: 2rem;
          font-weight: bold;
        }
      `}</style>
    </div>
  );
}

export default Dashboard;
