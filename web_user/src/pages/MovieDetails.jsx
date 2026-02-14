import React, { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import api from '../utils/api';
import { Play, Plus, ThumbsUp, X, Check } from 'lucide-react';

const MovieDetails = () => {
  const { id } = useParams();
  const navigate = useNavigate();
  const [movie, setMovie] = useState(null);
  const [loading, setLoading] = useState(true);
  const [isInWatchlist, setIsInWatchlist] = useState(false);

  useEffect(() => {
    const fetchMovie = async () => {
      try {
        const res = await api.get(`/movies/${id}`);
        setMovie(res.data);

        // Check watchlist
        const profileRes = await api.get('/users/profile');
        setIsInWatchlist(profileRes.data.watchlist.some(m => m._id === id));
      } catch (err) {
        console.error(err);
      } finally {
        setLoading(false);
      }
    };
    fetchMovie();
  }, [id]);

  const toggleWatchlist = async () => {
    try {
      const res = await api.post(`/users/watchlist/${id}`);
      setIsInWatchlist(res.data.isAdded);
    } catch (err) {
      console.error(err);
    }
  };

  if (loading) return <div className="h-screen flex items-center justify-center">
    <div className="w-12 h-12 border-4 border-purple-600 border-t-transparent rounded-full animate-spin"></div>
  </div>;

  if (!movie) return <div className="h-screen flex items-center justify-center">Movie not found</div>;

  return (
    <div className="pt-20 min-h-screen bg-[#141414]">
      <div className="max-w-6xl mx-auto px-4 py-8">
        <div className="grid grid-cols-1 md:grid-cols-3 gap-12">
          <div className="md:col-span-1">
            <img
              src={movie.posterUrl}
              alt={movie.title}
              className="w-full rounded-lg shadow-2xl border border-white/5"
            />
          </div>

          <div className="md:col-span-2">
            <h1 className="text-4xl md:text-6xl font-black mb-4 uppercase tracking-tighter">{movie.title}</h1>

            <div className="flex items-center space-x-4 mb-8 text-sm md:text-base font-medium">
              <span className="text-green-500 font-bold">98% Match</span>
              <span className="text-gray-400">{movie.year}</span>
              <span className="border border-white/40 px-2 rounded text-xs py-0.5 uppercase tracking-wider">{movie.contentRating || '13+'}</span>
              <span className="text-gray-400">{movie.duration}</span>
              <span className="bg-white/10 px-2 py-0.5 rounded text-[10px] font-bold">HD</span>
            </div>

            <div className="flex flex-wrap gap-4 mb-10">
              <button
                onClick={() => navigate(`/watch/${movie._id}`)}
                className="flex items-center space-x-3 bg-white text-black px-10 py-3 rounded hover:bg-white/90 transition-colors font-bold uppercase tracking-wider"
              >
                <Play fill="black" size={24} />
                <span>Play</span>
              </button>

              <button
                onClick={toggleWatchlist}
                className="p-3 border-2 border-white/30 rounded-full hover:border-white transition-colors"
                title="Add to My List"
              >
                {isInWatchlist ? <Check /> : <Plus />}
              </button>

              <button className="p-3 border-2 border-white/30 rounded-full hover:border-white transition-colors">
                <ThumbsUp />
              </button>
            </div>

            <p className="text-lg text-gray-200 leading-relaxed mb-10 font-medium">
              {movie.description}
            </p>

            <div className="grid grid-cols-1 md:grid-cols-2 gap-8 pt-8 border-t border-white/10">
              <div>
                <span className="text-gray-500 block text-xs font-bold uppercase mb-2">Genres</span>
                <p className="text-sm font-medium">{movie.genre?.join(', ') || 'Action, Drama'}</p>
              </div>
              <div>
                <span className="text-gray-500 block text-xs font-bold uppercase mb-2">Audio</span>
                <p className="text-sm font-medium">English, Somali, Arabic</p>
              </div>
              <div>
                <span className="text-gray-500 block text-xs font-bold uppercase mb-2">Subtitles</span>
                <p className="text-sm font-medium">English, Arabic</p>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default MovieDetails;
