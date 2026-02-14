import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import api from '../utils/api';
import { Search as SearchIcon } from 'lucide-react';

const Search = () => {
  const [query, setQuery] = useState('');
  const [results, setResults] = useState([]);
  const [loading, setLoading] = useState(false);
  const navigate = useNavigate();

  useEffect(() => {
    if (query.trim() === '') {
      setResults([]);
      return;
    }

    const delayDebounceFn = setTimeout(async () => {
      setLoading(true);
      try {
        const res = await api.get('/movies');
        const filtered = res.data.filter(m =>
          m.title.toLowerCase().includes(query.toLowerCase()) ||
          m.genre?.some(g => g.toLowerCase().includes(query.toLowerCase()))
        );
        setResults(filtered);
      } catch (err) {
        console.error(err);
      } finally {
        setLoading(false);
      }
    }, 500);

    return () => clearTimeout(delayDebounceFn);
  }, [query]);

  return (
    <div className="pt-24 min-h-screen bg-[#141414] px-4 md:px-12">
      <div className="max-w-2xl mx-auto mb-12">
        <div className="relative">
          <SearchIcon className="absolute left-4 top-1/2 -translate-y-1/2 text-gray-500" />
          <input
            autoFocus
            type="text"
            placeholder="Search titles, genres, people..."
            className="w-full bg-[#333] border-none rounded-md py-4 pl-12 pr-4 text-lg focus:ring-2 focus:ring-purple-600 outline-none transition-all"
            value={query}
            onChange={(e) => setQuery(e.target.value)}
          />
        </div>
      </div>

      {loading ? (
        <div className="text-center py-20 italic text-gray-500">Searching library...</div>
      ) : results.length > 0 ? (
        <div className="grid grid-cols-2 md:grid-cols-4 lg:grid-cols-6 gap-4">
          {results.map((movie) => (
            <div
              key={movie._id}
              onClick={() => navigate(`/movie/${movie._id}`)}
              className="relative aspect-[2/3] rounded-md overflow-hidden cursor-pointer transform hover:scale-105 transition-transform duration-300 shadow-xl"
            >
              <img src={movie.posterUrl} className="w-full h-full object-cover" alt={movie.title} />
            </div>
          ))}
        </div>
      ) : query && (
        <div className="text-center py-20 text-gray-500">
           No results found for "{query}".
        </div>
      )}
    </div>
  );
};

export default Search;
