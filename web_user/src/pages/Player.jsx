import React, { useState, useEffect, useRef } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import api from '../utils/api';
import { ArrowLeft, Play, Pause, Volume2, Maximize, Settings, RotateCcw, RotateCw } from 'lucide-react';

const Player = () => {
  const { id } = useParams();
  const navigate = useNavigate();
  const [movie, setMovie] = useState(null);
  const [isPlaying, setIsPlaying] = useState(false);
  const [progress, setProgress] = useState(0);
  const [duration, setDuration] = useState(0);
  const [showControls, setShowControls] = useState(true);
  const videoRef = useRef(null);
  const controlsTimerRef = useRef(null);

  useEffect(() => {
    const fetchMovie = async () => {
      try {
        const res = await api.get(`/movies/${id}`);
        setMovie(res.data);
      } catch (err) {
        console.error(err);
      }
    };
    fetchMovie();
  }, [id]);

  const handleMouseMove = () => {
    setShowControls(true);
    if (controlsTimerRef.current) clearTimeout(controlsTimerRef.current);
    controlsTimerRef.current = setTimeout(() => {
      if (isPlaying) setShowControls(false);
    }, 3000);
  };

  const togglePlay = () => {
    if (videoRef.current.paused) {
      videoRef.current.play();
      setIsPlaying(true);
    } else {
      videoRef.current.pause();
      setIsPlaying(false);
    }
  };

  const onTimeUpdate = () => {
    setProgress((videoRef.current.currentTime / videoRef.current.duration) * 100);
  };

  const onLoadedMetadata = () => {
    setDuration(videoRef.current.duration);
  };

  const handleSeek = (e) => {
    const seekTime = (e.target.value / 100) * videoRef.current.duration;
    videoRef.current.currentTime = seekTime;
    setProgress(e.target.value);
  };

  const formatTime = (time) => {
    const minutes = Math.floor(time / 60);
    const seconds = Math.floor(time % 60);
    return `${minutes}:${seconds < 10 ? '0' : ''}${seconds}`;
  };

  if (!movie) return <div className="h-screen bg-black flex items-center justify-center">Loading...</div>;

  return (
    <div
      className="fixed inset-0 z-[100] bg-black group"
      onMouseMove={handleMouseMove}
    >
      {/* Video element */}
      <video
        ref={videoRef}
        src={movie.videoUrl}
        className="w-full h-full cursor-none"
        onTimeUpdate={onTimeUpdate}
        onLoadedMetadata={onLoadedMetadata}
        onClick={togglePlay}
        autoPlay
      />

      {/* Back Button */}
      <div className={`absolute top-0 left-0 p-8 z-10 transition-opacity duration-300 ${showControls ? 'opacity-100' : 'opacity-0'}`}>
        <button
          onClick={() => navigate(-1)}
          className="flex items-center space-x-2 text-white hover:text-gray-300 font-bold uppercase tracking-widest text-sm"
        >
          <ArrowLeft size={32} />
          <span>{movie.title}</span>
        </button>
      </div>

      {/* Controls Overlay */}
      <div className={`absolute inset-0 bg-gradient-to-t from-black/80 via-transparent to-black/20 flex flex-col justify-end p-8 transition-opacity duration-300 ${showControls ? 'opacity-100' : 'opacity-0'}`}>

        {/* Progress Bar */}
        <div className="w-full mb-6">
          <input
            type="range"
            min="0"
            max="100"
            value={progress}
            onChange={handleSeek}
            className="w-full h-1 bg-gray-600 rounded-lg appearance-none cursor-pointer accent-purple-600 hover:h-2 transition-all"
          />
          <div className="flex justify-between text-xs mt-2 font-bold font-mono">
            <span>{formatTime(videoRef.current?.currentTime || 0)}</span>
            <span>{formatTime(duration)}</span>
          </div>
        </div>

        {/* Action Buttons */}
        <div className="flex items-center justify-between">
          <div className="flex items-center space-x-8">
            <button onClick={togglePlay} className="text-white hover:scale-110 transition-transform">
              {isPlaying ? <Pause size={36} fill="white" /> : <Play size={36} fill="white" />}
            </button>
            <button onClick={() => videoRef.current.currentTime -= 10} className="text-white hover:scale-110 transition-transform">
              <RotateCcw size={28} />
            </button>
            <button onClick={() => videoRef.current.currentTime += 10} className="text-white hover:scale-110 transition-transform">
              <RotateCw size={28} />
            </button>
            <div className="flex items-center space-x-3 group/vol">
               <Volume2 size={24} />
               <input type="range" className="w-0 group-hover/vol:w-20 transition-all accent-white h-1 appearance-none bg-white/30" />
            </div>
          </div>

          <div className="flex items-center space-x-6">
            <button className="text-white hover:rotate-90 transition-transform">
              <Settings size={24} />
            </button>
            <button
              onClick={() => videoRef.current.requestFullscreen()}
              className="text-white hover:scale-110 transition-transform"
            >
              <Maximize size={24} />
            </button>
          </div>
        </div>
      </div>
    </div>
  );
};

export default Player;
