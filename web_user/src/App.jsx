import React, { useState, useEffect } from 'react';
import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import Home from './pages/Home';
import Login from './pages/Login';
import Signup from './pages/Signup';
import MovieDetails from './pages/MovieDetails';
import Player from './pages/Player';
import Search from './pages/Search';
import MyList from './pages/MyList';
import Navbar from './components/Navbar';

function App() {
  const [isAuthenticated, setIsAuthenticated] = useState(!!localStorage.getItem('token'));
  const [user, setUser] = useState(null);

  useEffect(() => {
    if (isAuthenticated) {
      // Potentially fetch user profile here
    }
  }, [isAuthenticated]);

  const handleLogin = (token, userData) => {
    localStorage.setItem('token', token);
    setIsAuthenticated(true);
    setUser(userData);
  };

  const handleLogout = () => {
    localStorage.removeItem('token');
    setIsAuthenticated(false);
    setUser(null);
  };

  return (
    <BrowserRouter>
      <div className="min-h-screen bg-[#141414] text-white">
        {isAuthenticated && <Navbar onLogout={handleLogout} />}
        <Routes>
          <Route path="/login" element={!isAuthenticated ? <Login onLogin={handleLogin} /> : <Navigate to="/" />} />
          <Route path="/signup" element={!isAuthenticated ? <Signup onLogin={handleLogin} /> : <Navigate to="/" />} />

          <Route path="/" element={isAuthenticated ? <Home /> : <Navigate to="/login" />} />
          <Route path="/movie/:id" element={isAuthenticated ? <MovieDetails /> : <Navigate to="/login" />} />
          <Route path="/watch/:id" element={isAuthenticated ? <Player /> : <Navigate to="/login" />} />
          <Route path="/search" element={isAuthenticated ? <Search /> : <Navigate to="/login" />} />
          <Route path="/my-list" element={isAuthenticated ? <MyList /> : <Navigate to="/login" />} />

          <Route path="*" element={<Navigate to="/" />} />
        </Routes>
      </div>
    </BrowserRouter>
  );
}

export default App;
