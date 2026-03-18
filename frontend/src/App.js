import React, { useState, useEffect } from 'react';
import './App.css';
import Dashboard from './pages/Dashboard';
import Users from './pages/Users';
import Orders from './pages/Orders';
import Shipments from './pages/Shipments';
import Inventory from './pages/Inventory';

function App() {
  const [currentPage, setCurrentPage] = useState('dashboard');
  const [authToken, setAuthToken] = useState(localStorage.getItem('authToken'));

  useEffect(() => {
    if (!authToken) {
      setCurrentPage('login');
    }
  }, [authToken]);

  const handleLogout = () => {
    localStorage.removeItem('authToken');
    setAuthToken(null);
    setCurrentPage('login');
  };

  if (!authToken && currentPage === 'login') {
    return <Login setAuthToken={setAuthToken} setCurrentPage={setCurrentPage} />;
  }

  return (
    <div className="app">
      <nav className="navbar">
        <div className="navbar-brand">Logistics Platform</div>
        <ul className="nav-links">
          <li><button onClick={() => setCurrentPage('dashboard')} className={currentPage === 'dashboard' ? 'active' : ''}>Dashboard</button></li>
          <li><button onClick={() => setCurrentPage('users')} className={currentPage === 'users' ? 'active' : ''}>Users</button></li>
          <li><button onClick={() => setCurrentPage('orders')} className={currentPage === 'orders' ? 'active' : ''}>Orders</button></li>
          <li><button onClick={() => setCurrentPage('shipments')} className={currentPage === 'shipments' ? 'active' : ''}>Shipments</button></li>
          <li><button onClick={() => setCurrentPage('inventory')} className={currentPage === 'inventory' ? 'active' : ''}>Inventory</button></li>
          <li><button onClick={handleLogout}>Logout</button></li>
        </ul>
      </nav>
      <div className="content">
        {currentPage === 'dashboard' && <Dashboard />}
        {currentPage === 'users' && <Users />}
        {currentPage === 'orders' && <Orders />}
        {currentPage === 'shipments' && <Shipments />}
        {currentPage === 'inventory' && <Inventory />}
      </div>
    </div>
  );
}

function Login({ setAuthToken, setCurrentPage }) {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');

  const handleLogin = async (e) => {
    e.preventDefault();
    try {
      const response = await fetch(process.env.REACT_APP_USERS_SERVICE_URL + '/auth/login', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ email, password })
      });
      
      if (response.ok) {
        const data = await response.json();
        localStorage.setItem('authToken', data.token);
        setAuthToken(data.token);
        setCurrentPage('dashboard');
      } else {
        setError('Invalid credentials');
      }
    } catch (err) {
      setError('Connection error');
    }
  };

  return (
    <div className="login-container">
      <div className="login-box">
        <h2>Logistics Platform Login</h2>
        {error && <div className="error">{error}</div>}
        <form onSubmit={handleLogin}>
          <input
            type="email"
            placeholder="Email"
            value={email}
            onChange={(e) => setEmail(e.target.value)}
            required
          />
          <input
            type="password"
            placeholder="Password"
            value={password}
            onChange={(e) => setPassword(e.target.value)}
            required
          />
          <button type="submit">Login</button>
        </form>
      </div>
    </div>
  );
}

export default App;
