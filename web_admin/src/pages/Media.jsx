import React, { useState, useEffect } from 'react';
import api from '../utils/api';
import { Video, Image as ImageIcon, Trash2, ExternalLink } from 'lucide-react';

const Media = () => {
  const [files, setFiles] = useState([]);
  const [loading, setLoading] = useState(true);

  const fetchFiles = async () => {
    setLoading(true);
    try {
      const res = await api.get('/upload');
      setFiles(res.data);
    } catch (err) {
      console.error(err);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchFiles();
  }, []);

  const handleDelete = async (key) => {
    if (!window.confirm('Delete this file from R2?')) return;
    try {
      await api.delete(`/upload/${key}`);
      fetchFiles();
    } catch (err) {
      alert('Delete failed');
    }
  };

  return (
    <div>
      <div className="mb-8">
        <h1 className="text-3xl font-bold">Media Library</h1>
        <p className="text-gray-400">Manage raw files in Cloudflare R2.</p>
      </div>

      <div className="bg-[#1C1C1C] rounded-xl border border-white/5 overflow-hidden">
        <table className="w-full text-left">
          <thead>
            <tr className="bg-[#262626] text-gray-400 text-sm uppercase tracking-wider">
              <th className="px-6 py-4 font-medium">File Name</th>
              <th className="px-6 py-4 font-medium">Size</th>
              <th className="px-6 py-4 font-medium">Last Modified</th>
              <th className="px-6 py-4 font-medium">Actions</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-white/5">
            {loading ? (
              <tr>
                <td colSpan="4" className="px-6 py-10 text-center text-gray-500 italic">Accessing storage...</td>
              </tr>
            ) : files.length === 0 ? (
              <tr>
                <td colSpan="4" className="px-6 py-10 text-center text-gray-500">No files found in R2.</td>
              </tr>
            ) : files.map((file) => (
              <tr key={file.key} className="hover:bg-white/[0.02] transition-colors">
                <td className="px-6 py-4">
                  <div className="flex items-center">
                    <div className="mr-4 p-2 bg-white/5 rounded">
                      {file.key.toString().toLowerCase().endsWith('.mp4') ? <Video size={18} /> : <ImageIcon size={18} />}
                    </div>
                    <div className="flex flex-col">
                      <span className="font-medium text-white truncate max-w-xs">{file.key}</span>
                      <a href={file.url} target="_blank" rel="noreferrer" className="text-purple-500 text-[10px] truncate max-w-xs hover:underline flex items-center">
                        View File <ExternalLink size={10} className="ml-1" />
                      </a>
                    </div>
                  </div>
                </td>
                <td className="px-6 py-4 text-gray-400 text-sm font-mono">
                  {(file.size / (1024 * 1024)).toFixed(2)} MB
                </td>
                <td className="px-6 py-4 text-gray-500 text-sm">
                  {new Date(file.lastModified).toLocaleDateString()}
                </td>
                <td className="px-6 py-4 text-right">
                   <button
                    onClick={() => handleDelete(file.key)}
                    className="p-2 text-red-500 hover:bg-red-500/10 rounded transition-colors"
                    title="Delete File"
                   >
                    <Trash2 size={18} />
                   </button>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
};

export default Media;
