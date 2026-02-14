import React, { useState } from 'react';
import { Link } from 'react-router-dom';
import api from '../utils/api';

const Login = ({ onLogin }) => {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);

  const handleSubmit = async (e) => {
    e.preventDefault();
    setLoading(true);
    setError('');
    try {
      const response = await api.post('/auth/login', { email, password });
      onLogin(response.data.token, response.data);
    } catch (err) {
      setError(err.response?.data?.message || 'Login failed. Please check your credentials.');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="relative min-h-screen w-full flex items-center justify-center bg-black">
      <div className="absolute inset-0 z-0">
        <img
          src="https://picsum.photos/seed/riyobox/1920/1080"
          className="w-full h-full object-cover opacity-50 grayscale"
          alt="background"
        />
        <div className="absolute inset-0 bg-gradient-to-t from-black via-black/40 to-black"></div>
      </div>

      <div className="relative z-10 w-full max-w-md p-10 bg-black/75 rounded-lg border border-white/5 backdrop-blur-sm">
        <h1 className="text-3xl font-black text-purple-600 mb-8 tracking-tighter">RIYOBOX</h1>
        <h2 className="text-2xl font-bold mb-8">Sign In</h2>

        {error && <div className="bg-red-500/20 border border-red-500/50 text-red-500 p-3 rounded mb-6 text-sm">{error}</div>}

        <form onSubmit={handleSubmit} className="space-y-6">
          <input
            type="email"
            placeholder="Email or phone number"
            required
            className="w-full bg-[#333] border-none rounded px-4 py-3 focus:ring-2 focus:ring-purple-600 outline-none transition-all"
            value={email}
            onChange={(e) => setEmail(e.target.value)}
          />
          <input
            type="password"
            placeholder="Password"
            required
            className="w-full bg-[#333] border-none rounded px-4 py-3 focus:ring-2 focus:ring-purple-600 outline-none transition-all"
            value={password}
            onChange={(e) => setPassword(e.target.value)}
          />
          <button
            type="submit"
            disabled={loading}
            className="w-full bg-purple-600 hover:bg-purple-700 py-3 rounded font-bold transition-colors disabled:opacity-50"
          >
            {loading ? 'Signing in...' : 'Sign In'}
          </button>
        </form>

        <div className="mt-8 flex items-center justify-between text-xs text-gray-400 font-medium">
          <div className="flex items-center">
            <input type="checkbox" className="mr-2 rounded bg-gray-500 border-none" />
            <span>Remember me</span>
          </div>
          <span className="hover:underline cursor-pointer">Need help?</span>
        </div>

        <p className="mt-12 text-gray-500">
          New to RIYOBOX? <Link to="/signup" className="text-white font-bold hover:underline">Sign up now.</Link>
        </p>
      </div>
    </div>
  );
};

export default Login;
