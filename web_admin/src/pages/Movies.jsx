import React, { useState, useEffect } from 'react';
import api from '../utils/api';

const Movies = () => {
  const [movies, setMovies] = useState([]);
  const [r2Files, setR2Files] = useState([]);
  const [loading, setLoading] = useState(true);
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [videoSource, setVideoSource] = useState('upload'); // upload, url, storage
  const [uploadProgress, setUploadProgress] = useState({ poster: 0, video: 0 });
  const [isUploading, setIsUploading] = useState(false);
  const [formData, setFormData] = useState({
    title: '',
    description: '',
    posterUrl: '',
    backdropUrl: '',
    videoUrl: '',
    year: '',
    duration: '',
    genre: '',
    contentRating: ''
  });

  const fetchMovies = async () => {
    setLoading(true);
    try {
      const [movieRes, r2Res] = await Promise.all([
        api.get('/admin/movies'),
        api.get('/upload')
      ]);
      setMovies(movieRes.data);
      setR2Files(r2Res.data);
    } catch (err) {
      console.error(err);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchMovies();
  }, []);

  const handleDelete = async (id) => {
    if (!window.confirm('Are you sure you want to delete this movie?')) return;
    try {
      await api.delete(`/admin/movies/${id}`);
      fetchMovies();
    } catch (err) {
      alert('Delete failed');
    }
  };

  const handleFileUpload = async (file, type) => {
    const formData = new FormData();
    formData.append('file', file);

    try {
      setIsUploading(true);
      const res = await api.post('/upload', formData, {
        onUploadProgress: (progressEvent) => {
          const progress = Math.round((progressEvent.loaded * 100) / progressEvent.total);
          setUploadProgress(prev => ({ ...prev, [type]: progress }));
        }
      });

      setFormData(prev => ({
        ...prev,
        [type === 'poster' ? 'posterUrl' : 'videoUrl']: res.data.url
      }));
    } catch (err) {
      alert(`${type} upload failed: ${err.message}`);
    } finally {
      setIsUploading(false);
    }
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (!formData.posterUrl || !formData.videoUrl) {
      alert('Please upload poster and video first');
      return;
    }

    const data = {
      ...formData,
      year: parseInt(formData.year) || new Date().getFullYear(),
      genre: formData.genre.split(',').map(g => g.trim()),
      isTrending: true
    };

    try {
      await api.post('/admin/movies', data);
      setIsModalOpen(false);
      setFormData({
        title: '', description: '', posterUrl: '',
        backdropUrl: '', videoUrl: '', year: '',
        duration: '', genre: '', contentRating: ''
      });
      setUploadProgress({ poster: 0, video: 0 });
      fetchMovies();
    } catch (err) {
      alert('Movie creation failed');
    }
  };

  return (
    <div>
      <div className="flex justify-between items-center mb-8">
        <div>
          <h1 className="text-3xl font-bold">Movies</h1>
          <p className="text-gray-400">Manage your content library.</p>
        </div>
        <button
          onClick={() => setIsModalOpen(true)}
          className="bg-purple-600 hover:bg-purple-700 px-6 py-2 rounded-lg font-bold transition-colors"
        >
          Add New Movie
        </button>
      </div>

      {loading ? (
        <div className="text-center py-20 text-gray-500 italic">Loading content...</div>
      ) : (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {movies.map((movie) => (
            <div key={movie._id} className="bg-[#1C1C1C] rounded-xl overflow-hidden border border-white/5 group">
              <div className="h-48 overflow-hidden relative">
                <img
                  src={movie.posterUrl}
                  alt={movie.title}
                  className="w-full h-full object-cover transition-transform group-hover:scale-105"
                  onError={(e) => { e.target.src = 'https://via.placeholder.com/300x450?text=No+Image' }}
                />
                <div className="absolute top-2 right-2 flex space-x-2">
                   <button
                    onClick={() => handleDelete(movie._id)}
                    className="p-2 bg-red-600 rounded-full hover:bg-red-700 shadow-lg"
                   >
                    🗑️
                   </button>
                </div>
              </div>
              <div className="p-5">
                <h3 className="text-lg font-bold truncate">{movie.title}</h3>
                <p className="text-gray-500 text-sm mt-1 line-clamp-2">{movie.description}</p>
                <div className="mt-4 pt-4 border-t border-white/5 flex items-center text-xs text-gray-400 italic">
                  URL: {movie.videoUrl.substring(0, 30)}...
                </div>
              </div>
            </div>
          ))}
        </div>
      )}

      {/* Upload Modal */}
      {isModalOpen && (
        <div className="fixed inset-0 bg-black/80 backdrop-blur-sm flex items-center justify-center p-4 z-50">
          <div className="bg-[#1C1C1C] max-w-lg w-full rounded-2xl border border-white/10 shadow-2xl overflow-hidden">
            <div className="p-6 border-b border-white/5 flex justify-between items-center">
              <h2 className="text-xl font-bold">Upload New Content</h2>
              <button onClick={() => setIsModalOpen(false)} className="text-gray-500 hover:text-white">✕</button>
            </div>
            <form onSubmit={handleSubmit} className="p-6 space-y-4 max-h-[70vh] overflow-y-auto custom-scrollbar">
              <div>
                <label className="block text-sm font-medium text-gray-400 mb-1">Movie Title</label>
                <input
                  required
                  className="w-full bg-[#262626] border border-white/10 rounded px-4 py-2 focus:outline-none focus:border-purple-500"
                  value={formData.title}
                  onChange={(e) => setFormData({...formData, title: e.target.value})}
                />
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-400 mb-1">Description</label>
                <textarea
                  required
                  rows="3"
                  className="w-full bg-[#262626] border border-white/10 rounded px-4 py-2 focus:outline-none focus:border-purple-500"
                  value={formData.description}
                  onChange={(e) => setFormData({...formData, description: e.target.value})}
                />
              </div>
              <div className="bg-[#262626] p-4 rounded-xl border border-white/5">
                <label className="block text-xs font-black text-gray-500 mb-3 uppercase tracking-widest">Video Content Source</label>
                <div className="flex space-x-2 mb-4">
                   {['upload', 'url', 'storage'].map(type => (
                     <button
                        key={type}
                        type="button"
                        onClick={() => setVideoSource(type)}
                        className={`flex-1 py-2 text-xs font-bold rounded-lg transition-all ${
                          videoSource === type ? 'bg-purple-600 text-white shadow-lg' : 'bg-white/5 text-gray-400 hover:bg-white/10'
                        }`}
                     >
                       {type.toUpperCase()}
                     </button>
                   ))}
                </div>

                {videoSource === 'upload' && (
                  <div>
                    <input
                      type="file"
                      accept="video/*"
                      className="w-full bg-[#141414] border border-white/10 rounded px-4 py-2 text-sm"
                      onChange={(e) => handleFileUpload(e.target.files[0], 'video')}
                    />
                    {uploadProgress.video > 0 && (
                      <div className="w-full bg-gray-700 h-1 mt-2 rounded-full overflow-hidden">
                        <div className="bg-blue-500 h-full" style={{ width: `${uploadProgress.video}%` }}></div>
                      </div>
                    )}
                  </div>
                )}

                {videoSource === 'url' && (
                  <input
                    placeholder="Paste direct MP4/HLS link"
                    className="w-full bg-[#141414] border border-white/10 rounded px-4 py-2 text-sm focus:border-purple-500"
                    value={formData.videoUrl}
                    onChange={(e) => setFormData({...formData, videoUrl: e.target.value})}
                  />
                )}

                {videoSource === 'storage' && (
                  <select
                    className="w-full bg-[#141414] border border-white/10 rounded px-4 py-2 text-sm outline-none focus:border-purple-500"
                    value={formData.videoUrl}
                    onChange={(e) => setFormData({...formData, videoUrl: e.target.value})}
                  >
                    <option value="">Select a file from R2 Storage</option>
                    {r2Files.filter(f => f.key.toLowerCase().endsWith('.mp4')).map(file => (
                      <option key={file.key} value={file.url}>{file.key} ({(file.size/1024/1024).toFixed(2)}MB)</option>
                    ))}
                  </select>
                )}
              </div>

              <div className="grid grid-cols-1 gap-4 bg-[#262626] p-4 rounded-xl border border-white/5">
                <label className="block text-xs font-black text-gray-500 mb-1 uppercase tracking-widest">Poster & Visuals</label>
                <div>
                  <label className="block text-[10px] text-gray-400 mb-1 font-bold">POSTER IMAGE FILE</label>
                  <input
                    type="file"
                    accept="image/*"
                    className="w-full bg-[#141414] border border-white/10 rounded px-4 py-2 text-sm"
                    onChange={(e) => handleFileUpload(e.target.files[0], 'poster')}
                  />
                  {uploadProgress.poster > 0 && (
                    <div className="w-full bg-gray-700 h-1 mt-2 rounded-full overflow-hidden">
                      <div className="bg-purple-500 h-full" style={{ width: `${uploadProgress.poster}%` }}></div>
                    </div>
                  )}
                </div>
                <div>
                  <label className="block text-[10px] text-gray-400 mb-1 font-bold">BACKDROP URL (OPTIONAL)</label>
                  <input
                    className="w-full bg-[#141414] border border-white/10 rounded px-4 py-2 text-sm focus:border-purple-500"
                    value={formData.backdropUrl}
                    onChange={(e) => setFormData({...formData, backdropUrl: e.target.value})}
                  />
                </div>
              </div>
              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="block text-sm font-medium text-gray-400 mb-1">Year</label>
                  <input
                    type="number"
                    className="w-full bg-[#262626] border border-white/10 rounded px-4 py-2 focus:outline-none focus:border-purple-500"
                    value={formData.year}
                    onChange={(e) => setFormData({...formData, year: e.target.value})}
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-400 mb-1">Duration (e.g. 2h 10m)</label>
                  <input
                    className="w-full bg-[#262626] border border-white/10 rounded px-4 py-2 focus:outline-none focus:border-purple-500"
                    value={formData.duration}
                    onChange={(e) => setFormData({...formData, duration: e.target.value})}
                  />
                </div>
              </div>
              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="block text-sm font-medium text-gray-400 mb-1">Genres (Comma separated)</label>
                  <input
                    className="w-full bg-[#262626] border border-white/10 rounded px-4 py-2 focus:outline-none focus:border-purple-500"
                    value={formData.genre}
                    onChange={(e) => setFormData({...formData, genre: e.target.value})}
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-400 mb-1">Rating (e.g. 13+, R)</label>
                  <input
                    className="w-full bg-[#262626] border border-white/10 rounded px-4 py-2 focus:outline-none focus:border-purple-500"
                    value={formData.contentRating}
                    onChange={(e) => setFormData({...formData, contentRating: e.target.value})}
                  />
                </div>
              </div>
              <div className="pt-4">
                <button
                  type="submit"
                  disabled={isUploading}
                  className="w-full bg-purple-600 hover:bg-purple-700 py-3 rounded-lg font-bold transition-all disabled:opacity-50"
                >
                  {isUploading ? 'Uploading Files...' : 'Confirm Upload'}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
};

export default Movies;
