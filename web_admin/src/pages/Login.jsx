import React, { useState } from 'react';
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
      if (response.data.role !== 'admin') {
        setError('Unauthorized: Only admins can access this panel.');
        setLoading(false);
        return;
      }
      onLogin(response.data.token, response.data.role);
    } catch (err) {
      setError(err.response?.data?.message || 'Login failed. Please try again.');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen flex items-center justify-center bg-[#141414] px-4">
      <div className="max-w-md w-full bg-[#1C1C1C] p-8 rounded-lg shadow-xl border border-white/5">
        <div className="text-center mb-10">
          <h1 className="text-4xl font-black text-purple-500 tracking-tighter">RIYOBOX</h1>
          <p className="text-gray-400 mt-2">Admin Control Center</p>
        </div>

        {error && (
          <div className="bg-red-500/10 border border-red-500/50 text-red-500 p-3 rounded mb-6 text-sm">
            {error}
          </div>
        )}

        <form onSubmit={handleSubmit} className="space-y-6">
          <div>
            <label className="block text-sm font-medium text-gray-400 mb-2">Email Address</label>
            <input
              type="email"
              required
              className="w-full bg-[#262626] border border-white/10 rounded px-4 py-3 focus:outline-none focus:border-purple-500 transition-colors"
              placeholder="admin@example.com"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
            />
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-400 mb-2">Password</label>
            <input
              type="password"
              required
              className="w-full bg-[#262626] border border-white/10 rounded px-4 py-3 focus:outline-none focus:border-purple-500 transition-colors"
              placeholder="••••••••"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
            />
          </div>

          <button
            type="submit"
            disabled={loading}
            className="w-full bg-purple-600 hover:bg-purple-700 text-white font-bold py-3 rounded transition-all transform active:scale-[0.98] disabled:opacity-50"
          >
            {loading ? 'SIGNING IN...' : 'SIGN IN'}
          </button>
        </form>

        <p className="mt-8 text-center text-xs text-gray-500">
          Secure access only. Unauthorized attempts are logged.
        </p>
      </div>
    </div>
  );
};

export default Login;
