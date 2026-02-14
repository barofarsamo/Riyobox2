import React from 'react';
import { NavLink } from 'react-router-dom';
import { LayoutDashboard, Film, FolderOpen, Users, LogOut } from 'lucide-react';

const Sidebar = ({ onLogout }) => {
  const links = [
    { path: '/dashboard', label: 'Dashboard', icon: <LayoutDashboard size={20} /> },
    { path: '/movies', label: 'Movies', icon: <Film size={20} /> },
    { path: '/media', label: 'Media Library', icon: <FolderOpen size={20} /> },
    { path: '/users', label: 'Users', icon: <Users size={20} /> },
  ];

  return (
    <div className="w-64 bg-[#1C1C1C] border-r border-white/5 flex flex-col">
      <div className="p-8">
        <h1 className="text-2xl font-black text-purple-500 tracking-tighter">RIYOBOX</h1>
        <p className="text-[10px] text-gray-500 uppercase tracking-widest font-bold">Admin Panel</p>
      </div>

      <nav className="flex-1 px-4 space-y-2">
        {links.map((link) => (
          <NavLink
            key={link.path}
            to={link.path}
            className={({ isActive }) =>
              `flex items-center px-4 py-3 rounded-lg transition-colors ${
                isActive ? 'bg-purple-600/10 text-purple-500' : 'text-gray-400 hover:bg-white/5'
              }`
            }
          >
            <span className="mr-3">{link.icon}</span>
            <span className="font-medium">{link.label}</span>
          </NavLink>
        ))}
      </nav>

      <div className="p-4 border-t border-white/5">
        <button
          onClick={onLogout}
          className="w-full flex items-center px-4 py-3 text-gray-400 hover:text-red-500 hover:bg-red-500/5 rounded-lg transition-colors"
        >
          <LogOut size={20} className="mr-3" />
          <span className="font-medium">Logout</span>
        </button>
      </div>
    </div>
  );
};

export default Sidebar;
