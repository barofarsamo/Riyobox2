import React, { useState, useEffect } from 'react';
import api from '../utils/api';

const Dashboard = () => {
  const [stats, setStats] = useState({
    movies: 0,
    users: 0,
    genres: 0
  });

  useEffect(() => {
    const fetchStats = async () => {
      try {
        const movieRes = await api.get('/admin/movies');
        // Assuming we might have a users endpoint later, or just mock for now
        setStats({
          movies: movieRes.data.length,
          users: 'Active', // Placeholder
          genres: 12 // Placeholder
        });
      } catch (err) {
        console.error(err);
      }
    };
    fetchStats();
  }, []);

  const cards = [
    { label: 'Total Movies', value: stats.movies, icon: '🎬', color: 'bg-blue-500' },
    { label: 'System Status', value: stats.users, icon: '✅', color: 'bg-green-500' },
    { label: 'Active Categories', value: stats.genres, icon: '📂', color: 'bg-purple-500' },
  ];

  return (
    <div>
      <div className="mb-8">
        <h1 className="text-3xl font-bold">Dashboard</h1>
        <p className="text-gray-400">Welcome to RIYOBOX control center.</p>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mb-12">
        {cards.map((card) => (
          <div key={card.label} className="bg-[#1C1C1C] p-6 rounded-xl border border-white/5">
            <div className="flex items-center justify-between mb-4">
              <span className={`p-3 rounded-lg ${card.color} bg-opacity-20 text-xl`}>
                {card.icon}
              </span>
            </div>
            <p className="text-gray-400 text-sm font-medium">{card.label}</p>
            <h2 className="text-3xl font-bold mt-1">{card.value}</h2>
          </div>
        ))}
      </div>

      <div className="bg-[#1C1C1C] rounded-xl border border-white/5 overflow-hidden">
        <div className="p-6 border-b border-white/5">
          <h2 className="text-xl font-bold">System Health</h2>
        </div>
        <div className="p-6">
          <div className="flex items-center justify-between p-4 bg-[#262626] rounded-lg mb-4">
             <div className="flex items-center">
                <div className="w-3 h-3 bg-green-500 rounded-full mr-4 animate-pulse"></div>
                <span>Backend API: https://riyobox1-1.onrender.com</span>
             </div>
             <span className="text-green-500 text-sm font-bold uppercase">Online</span>
          </div>
          <div className="flex items-center justify-between p-4 bg-[#262626] rounded-lg">
             <div className="flex items-center">
                <div className="w-3 h-3 bg-green-500 rounded-full mr-4"></div>
                <span>Database Status: MongoDB Atlas</span>
             </div>
             <span className="text-green-500 text-sm font-bold uppercase">Connected</span>
          </div>
        </div>
      </div>
    </div>
  );
};

export default Dashboard;
