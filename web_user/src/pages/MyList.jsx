import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import api from '../utils/api';

const MyList = () => {
  const [movies, setMovies] = useState([]);
  const [loading, setLoading] = useState(true);
  const navigate = useNavigate();

  useEffect(() => {
    const fetchWatchlist = async () => {
      try {
        const res = await api.get('/users/profile');
        setMovies(res.data.watchlist);
      } catch (err) {
        console.error(err);
      } finally {
        setLoading(false);
      }
    };
    fetchWatchlist();
  }, []);

  if (loading) return <div className="h-screen flex items-center justify-center">
    <div className="w-12 h-12 border-4 border-purple-600 border-t-transparent rounded-full animate-spin"></div>
  </div>;

  return (
    <div className="pt-24 min-h-screen bg-[#141414] px-4 md:px-12">
      <h1 className="text-3xl font-bold mb-8">My List</h1>

      {movies.length === 0 ? (
        <div className="text-center py-20">
           <p className="text-gray-500 mb-6">You haven't added any titles to your list yet.</p>
           <button onClick={() => navigate('/')} className="bg-white text-black px-8 py-2 rounded font-bold">Browse Content</button>
        </div>
      ) : (
        <div className="grid grid-cols-2 md:grid-cols-4 lg:grid-cols-6 gap-4">
          {movies.map((movie) => (
            <div
              key={movie._id}
              onClick={() => navigate(`/movie/${movie._id}`)}
              className="relative aspect-[2/3] rounded-md overflow-hidden cursor-pointer transform hover:scale-105 transition-transform duration-300 shadow-xl group"
            >
              <img src={movie.posterUrl} className="w-full h-full object-cover" alt={movie.title} />
              <div className="absolute inset-0 bg-black/60 opacity-0 group-hover:opacity-100 transition-opacity flex items-center justify-center p-4 text-center">
                 <span className="font-bold text-sm uppercase tracking-tighter">{movie.title}</span>
              </div>
            </div>
          ))}
        </div>
      )}
    </div>
  );
};

export default MyList;
