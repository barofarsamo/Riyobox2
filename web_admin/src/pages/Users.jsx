import React, { useState, useEffect } from 'react';
import api from '../utils/api';

const Users = () => {
  const [users, setUsers] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetchUsers = async () => {
      try {
        const res = await api.get('/admin/users');
        setUsers(res.data);
      } catch (err) {
        console.error(err);
      } finally {
        setLoading(false);
      }
    };
    fetchUsers();
  }, []);

  return (
    <div>
      <div className="mb-8">
        <h1 className="text-3xl font-bold">User Management</h1>
        <p className="text-gray-400">View and manage application users.</p>
      </div>

      <div className="bg-[#1C1C1C] rounded-xl border border-white/5 overflow-hidden">
        <table className="w-full text-left">
          <thead>
            <tr className="bg-[#262626] text-gray-400 text-sm uppercase tracking-wider">
              <th className="px-6 py-4 font-medium">Name</th>
              <th className="px-6 py-4 font-medium">Email</th>
              <th className="px-6 py-4 font-medium">Role</th>
              <th className="px-6 py-4 font-medium">Joined</th>
              <th className="px-6 py-4 font-medium">Actions</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-white/5">
            {loading ? (
              <tr>
                <td colSpan="5" className="px-6 py-10 text-center text-gray-500 italic">Fetching user data...</td>
              </tr>
            ) : users.map((user) => (
              <tr key={user._id} className="hover:bg-white/[0.02] transition-colors">
                <td className="px-6 py-4 font-medium">{user.name}</td>
                <td className="px-6 py-4 text-gray-400">{user.email}</td>
                <td className="px-6 py-4">
                  <span className={`px-2 py-1 rounded text-[10px] font-bold uppercase ${
                    user.role === 'admin' ? 'bg-purple-500/20 text-purple-400' : 'bg-blue-500/20 text-blue-400'
                  }`}>
                    {user.role}
                  </span>
                </td>
                <td className="px-6 py-4 text-gray-500 text-sm">
                  {new Date(user.createdAt).toLocaleDateString()}
                </td>
                <td className="px-6 py-4">
                   <button className="text-gray-500 hover:text-white mr-4">Edit</button>
                   <button className="text-red-500/50 hover:text-red-500">Suspend</button>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
};

export default Users;
