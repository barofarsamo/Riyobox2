import React, { useState } from 'react';
import { Link } from 'react-router-dom';
import api from '../utils/api';

const Signup = ({ onLogin }) => {
  const [name, setName] = useState('');
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);

  const handleSubmit = async (e) => {
    e.preventDefault();
    setLoading(true);
    setError('');
    try {
      const response = await api.post('/auth/register', { name, email, password });
      onLogin(response.data.token, response.data);
    } catch (err) {
      setError(err.response?.data?.message || 'Registration failed. Please try again.');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="relative min-h-screen w-full flex items-center justify-center bg-black">
      <div className="absolute inset-0 z-0">
        <img
          src="https://picsum.photos/seed/riyobox-reg/1920/1080"
          className="w-full h-full object-cover opacity-50 grayscale"
          alt="background"
        />
        <div className="absolute inset-0 bg-gradient-to-t from-black via-black/40 to-black"></div>
      </div>

      <div className="relative z-10 w-full max-w-md p-10 bg-black/75 rounded-lg border border-white/5 backdrop-blur-sm">
        <h1 className="text-3xl font-black text-purple-600 mb-8 tracking-tighter">RIYOBOX</h1>
        <h2 className="text-2xl font-bold mb-8">Sign Up</h2>

        {error && <div className="bg-red-500/20 border border-red-500/50 text-red-500 p-3 rounded mb-6 text-sm">{error}</div>}

        <form onSubmit={handleSubmit} className="space-y-6">
          <input
            type="text"
            placeholder="Full Name"
            required
            className="w-full bg-[#333] border-none rounded px-4 py-3 focus:ring-2 focus:ring-purple-600 outline-none transition-all"
            value={name}
            onChange={(e) => setName(e.target.value)}
          />
          <input
            type="email"
            placeholder="Email address"
            required
            className="w-full bg-[#333] border-none rounded px-4 py-3 focus:ring-2 focus:ring-purple-600 outline-none transition-all"
            value={email}
            onChange={(e) => setEmail(e.target.value)}
          />
          <input
            type="password"
            placeholder="Create password"
            required
            className="w-full bg-[#333] border-none rounded px-4 py-3 focus:ring-2 focus:ring-purple-600 outline-none transition-all"
            value={password}
            onChange={(e) => setPassword(e.target.value)}
          />
          <button
            type="submit"
            disabled={loading}
            className="w-full bg-purple-600 hover:bg-purple-700 py-3 rounded font-bold transition-colors disabled:opacity-50 uppercase tracking-widest text-sm"
          >
            {loading ? 'Creating account...' : 'Start Watching'}
          </button>
        </form>

        <p className="mt-12 text-gray-500">
          Already have an account? <Link to="/login" className="text-white font-bold hover:underline">Sign in.</Link>
        </p>
      </div>
    </div>
  );
};

export default Signup;
