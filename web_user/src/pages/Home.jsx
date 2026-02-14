import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import api from '../utils/api';
import { Play, Info, Plus, ChevronRight, ChevronLeft } from 'lucide-react';

const Home = () => {
  const [movies, setMovies] = useState([]);
  const [featured, setFeatured] = useState(null);
  const [loading, setLoading] = useState(true);
  const navigate = useNavigate();

  useEffect(() => {
    const fetchData = async () => {
      try {
        const res = await api.get('/movies');
        setMovies(res.data);
        if (res.data.length > 0) {
          setFeatured(res.data[Math.floor(Math.random() * res.data.length)]);
        }
      } catch (err) {
        console.error(err);
      } finally {
        setLoading(false);
      }
    };
    fetchData();
  }, []);

  if (loading) return <div className="h-screen flex items-center justify-center">
    <div className="w-12 h-12 border-4 border-purple-600 border-t-transparent rounded-full animate-spin"></div>
  </div>;

  return (
    <div className="pb-20">
      {/* Hero Section */}
      {featured && (
        <div className="relative h-[80vh] md:h-[95vh] w-full overflow-hidden">
          <div className="absolute inset-0">
            <img
              src={featured.backdropUrl || featured.posterUrl}
              className="w-full h-full object-cover"
              alt={featured.title}
            />
            <div className="absolute inset-0 hero-gradient"></div>
            <div className="absolute inset-0 bg-gradient-to-r from-[#141414] via-[#141414]/20 to-transparent"></div>
          </div>

          <div className="absolute bottom-20 md:bottom-40 left-4 md:left-12 max-w-2xl px-4">
            <h1 className="text-4xl md:text-7xl font-black mb-4 uppercase leading-tight tracking-tighter">
              {featured.title}
            </h1>
            <p className="text-sm md:text-lg text-gray-200 mb-8 line-clamp-3 md:line-clamp-none font-medium">
              {featured.description}
            </p>
            <div className="flex space-x-4">
              <button
                onClick={() => navigate(`/watch/${featured._id}`)}
                className="flex items-center space-x-3 bg-white text-black px-6 md:px-8 py-2 md:py-3 rounded hover:bg-white/90 transition-colors font-bold"
              >
                <Play fill="black" />
                <span>Play</span>
              </button>
              <button
                onClick={() => navigate(`/movie/${featured._id}`)}
                className="flex items-center space-x-3 bg-gray-500/50 text-white px-6 md:px-8 py-2 md:py-3 rounded hover:bg-gray-500/40 transition-colors font-bold backdrop-blur-md"
              >
                <Info />
                <span>More Info</span>
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Movie Rows */}
      <div className="mt-[-80px] md:mt-[-150px] relative z-10 space-y-12 pl-4 md:pl-12 overflow-x-hidden">
        <MovieRow title="Trending Now" movies={movies} />
        <MovieRow title="New Releases" movies={[...movies].reverse()} />
        <MovieRow title="Popular on RIYOBOX" movies={movies.filter(m => m.isTrending)} />
      </div>
    </div>
  );
};

const MovieRow = ({ title, movies }) => {
  const navigate = useNavigate();
  const rowRef = React.useRef(null);

  const slide = (direction) => {
    if (rowRef.current) {
      const { scrollLeft, clientWidth } = rowRef.current;
      const scrollTo = direction === 'left' ? scrollLeft - clientWidth : scrollLeft + clientWidth;
      rowRef.current.scrollTo({ left: scrollTo, behavior: 'smooth' });
    }
  };

  if (movies.length === 0) return null;

  return (
    <div className="group relative">
      <h2 className="text-xl md:text-2xl font-bold mb-4 flex items-center group-hover:text-white transition-colors cursor-pointer">
        {title}
        <ChevronRight size={20} className="ml-2 opacity-0 group-hover:opacity-100 transition-opacity" />
      </h2>

      <div className="relative">
        <button
          onClick={() => slide('left')}
          className="absolute left-[-40px] top-0 bottom-0 z-40 bg-black/50 hover:bg-black/80 px-2 opacity-0 group-hover:opacity-100 transition-opacity"
        >
          <ChevronLeft />
        </button>

        <div
          ref={rowRef}
          className="flex space-x-2 md:space-x-4 overflow-x-scroll scrollbar-hide pr-20"
          style={{ scrollbarWidth: 'none', msOverflowStyle: 'none' }}
        >
          {movies.map((movie) => (
            <div
              key={movie._id}
              onClick={() => navigate(`/movie/${movie._id}`)}
              className="flex-none w-32 md:w-56 aspect-[2/3] md:aspect-video relative rounded-md overflow-hidden cursor-pointer transform hover:scale-105 transition-transform duration-300 group/item shadow-lg"
            >
              <img
                src={movie.posterUrl}
                className="w-full h-full object-cover"
                alt={movie.title}
                loading="lazy"
              />
              <div className="absolute inset-0 bg-black/60 opacity-0 group-hover/item:opacity-100 transition-opacity flex flex-col justify-end p-4">
                <h3 className="font-bold text-sm md:text-base mb-1 truncate">{movie.title}</h3>
                <div className="flex items-center space-x-2 text-[10px] md:text-xs text-gray-300">
                  <span className="text-green-500 font-bold">98% Match</span>
                  <span>{movie.year}</span>
                  <span className="border border-white/40 px-1 rounded text-[8px]">{movie.contentRating || '13+'}</span>
                </div>
              </div>
            </div>
          ))}
        </div>

        <button
          onClick={() => slide('right')}
          className="absolute right-0 top-0 bottom-0 z-40 bg-black/50 hover:bg-black/80 px-2 opacity-0 group-hover:opacity-100 transition-opacity"
        >
          <ChevronRight />
        </button>
      </div>
    </div>
  );
};

export default Home;
