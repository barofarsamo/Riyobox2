import React, { useState, useEffect } from 'react';
import { Link, useNavigate, useLocation } from 'react-router-dom';
import { Search, Bell, User, LogOut, Menu, X } from 'lucide-react';

const Navbar = ({ onLogout }) => {
  const [isScrolled, setIsScrolled] = useState(false);
  const [isMobileMenuOpen, setIsMobileMenuOpen] = useState(false);
  const navigate = useNavigate();
  const location = useLocation();

  useEffect(() => {
    const handleScroll = () => {
      setIsScrolled(window.scrollY > 0);
    };
    window.addEventListener('scroll', handleScroll);
    return () => window.removeEventListener('scroll', handleScroll);
  }, []);

  const navLinks = [
    { name: 'Home', path: '/' },
    { name: 'TV Shows', path: '/?type=tv' },
    { name: 'Movies', path: '/?type=movie' },
    { name: 'New & Popular', path: '/' },
    { name: 'My List', path: '/my-list' },
  ];

  return (
    <nav className={`fixed top-0 w-full z-50 transition-colors duration-300 ${isScrolled ? 'bg-[#141414]' : 'bg-transparent bg-gradient-to-b from-black/70 to-transparent'}`}>
      <div className="max-w-7xl mx-auto px-4 md:px-8 h-16 md:h-20 flex items-center justify-between">
        <div className="flex items-center space-x-8">
          <Link to="/" className="text-2xl md:text-3xl font-black text-purple-600 tracking-tighter">RIYOBOX</Link>

          <div className="hidden md:flex space-x-6">
            {navLinks.map((link) => (
              <Link
                key={link.name}
                to={link.path}
                className={`text-sm transition-colors hover:text-gray-300 ${location.pathname === link.path ? 'font-bold text-white' : 'text-gray-200'}`}
              >
                {link.name}
              </Link>
            ))}
          </div>
        </div>

        <div className="flex items-center space-x-4">
          <button onClick={() => navigate('/search')} className="p-1 hover:text-gray-300">
            <Search size={20} />
          </button>

          <div className="hidden md:flex items-center space-x-4">
            <Bell size={20} className="cursor-pointer" />
            <div className="group relative">
              <div className="flex items-center space-x-2 cursor-pointer">
                <div className="w-8 h-8 bg-purple-600 rounded flex items-center justify-center font-bold">J</div>
                <span className="border-t-4 border-l-4 border-r-4 border-transparent border-t-white ml-1"></span>
              </div>

              <div className="absolute right-0 top-full pt-4 hidden group-hover:block">
                <div className="bg-[#141414] border border-white/10 p-4 w-48 shadow-xl">
                  <Link to="/my-list" className="flex items-center space-x-3 text-sm py-2 hover:underline">
                    <User size={16} />
                    <span>Profile</span>
                  </Link>
                  <button onClick={onLogout} className="flex items-center space-x-3 text-sm py-2 w-full text-left hover:underline text-red-500">
                    <LogOut size={16} />
                    <span>Sign out of RIYOBOX</span>
                  </button>
                </div>
              </div>
            </div>
          </div>

          <button className="md:hidden" onClick={() => setIsMobileMenuOpen(!isMobileMenuOpen)}>
            {isMobileMenuOpen ? <X /> : <Menu />}
          </button>
        </div>
      </div>

      {/* Mobile Menu */}
      {isMobileMenuOpen && (
        <div className="md:hidden bg-[#141414] border-b border-white/10 px-4 py-6 space-y-4">
          {navLinks.map((link) => (
            <Link
              key={link.name}
              to={link.path}
              onClick={() => setIsMobileMenuOpen(false)}
              className="block text-lg font-medium"
            >
              {link.name}
            </Link>
          ))}
          <button onClick={onLogout} className="block text-lg font-medium text-red-500">Sign out</button>
        </div>
      )}
    </nav>
  );
};

export default Navbar;
