import React, { useState, useEffect } from 'react';
import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import Login from './pages/Login';
import Dashboard from './pages/Dashboard';
import Movies from './pages/Movies';
import Media from './pages/Media';
import Users from './pages/Users';
import Sidebar from './components/Sidebar';

function App() {
  const [isAuthenticated, setIsAuthenticated] = useState(!!localStorage.getItem('token'));
  const [role, setRole] = useState(localStorage.getItem('role'));

  const handleLogin = (token, userRole) => {
    localStorage.setItem('token', token);
    localStorage.setItem('role', userRole);
    setIsAuthenticated(true);
    setRole(userRole);
  };

  const handleLogout = () => {
    localStorage.removeItem('token');
    localStorage.removeItem('role');
    setIsAuthenticated(false);
    setRole(null);
  };

  if (!isAuthenticated) {
    return (
      <BrowserRouter>
        <Routes>
          <Route path="/login" element={<Login onLogin={handleLogin} />} />
          <Route path="*" element={<Navigate to="/login" />} />
        </Routes>
      </BrowserRouter>
    );
  }

  if (role !== 'admin') {
    return (
      <div className="h-screen flex items-center justify-center bg-[#141414] text-white">
        <div className="text-center">
          <h1 className="text-4xl font-bold mb-4">Access Denied</h1>
          <p className="text-gray-400 mb-6">You do not have permission to access the admin panel.</p>
          <button onClick={handleLogout} className="px-6 py-2 bg-purple-600 rounded">Logout</button>
        </div>
      </div>
    );
  }

  return (
    <BrowserRouter>
      <div className="flex min-h-screen bg-[#141414]">
        <Sidebar onLogout={handleLogout} />
        <main className="flex-1 p-8 overflow-y-auto">
          <Routes>
            <Route path="/dashboard" element={<Dashboard />} />
            <Route path="/movies" element={<Movies />} />
            <Route path="/media" element={<Media />} />
            <Route path="/users" element={<Users />} />
            <Route path="*" element={<Navigate to="/dashboard" />} />
          </Routes>
        </main>
      </div>
    </BrowserRouter>
  );
}

export default App;
