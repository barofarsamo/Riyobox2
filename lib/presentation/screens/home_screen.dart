
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:riyobox/providers/auth_provider.dart';
import 'package:riyobox/providers/playback_provider.dart';
import 'package:riyobox/providers/settings_provider.dart';
import 'package:riyobox/models/movie.dart';
import 'package:riyobox/services/api_service.dart';
import 'package:riyobox/presentation/widgets/movie_card.dart';
import 'package:riyobox/presentation/widgets/shimmer_loading.dart';
import 'package:riyobox/presentation/widgets/state_widgets.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _apiService = ApiService();
  int _currentCarouselIndex = 0;

  final List<String> _filters = [
    "All",
    "Movies",
    "TV Shows",
    "Anime",
    "Kids",
    "My List"
  ];
  String _selectedFilter = "All";

  Future<List<Movie>> _getFilteredMovies(String? token, bool isOffline) async {
    List<Movie> movies;
    if (_selectedFilter == "My List") {
      movies = await _apiService.getWatchlist(token ?? "");
    } else {
      movies = await _apiService.getTrendingMovies(token: token);
    }

    if (isOffline) {
      movies = movies.where((m) => m.isDownloaded).toList();
    }

    if (_selectedFilter == "Movies") {
      movies = movies.where((m) => !m.isTvShow).toList();
    } else if (_selectedFilter == "TV Shows") {
      movies = movies.where((m) => m.isTvShow).toList();
    }

    return movies;
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF141414),
      body: RefreshIndicator(
        onRefresh: () async {
           setState(() {});
        },
        color: Colors.deepPurpleAccent,
        backgroundColor: const Color(0xFF1C1C1C),
        child: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              backgroundColor: const Color(0xFF141414),
              title: const Text('RIYOBOX',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: Colors.white)),
              actions: [
                if (settings.isOffline)
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Chip(
                      label: Text('OFFLINE MODE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
                      backgroundColor: Colors.redAccent,
                    ),
                  ),
                IconButton(
                    icon: const Icon(Icons.cast, color: Colors.white),
                    onPressed: () => context.push('/cast')),
                IconButton(
                    icon: const Icon(Icons.settings, color: Colors.white),
                    onPressed: () => context.push('/settings')),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GestureDetector(
                    onTap: () => context.push('/profile'),
                    child: const CircleAvatar(
                      backgroundImage: NetworkImage(
                          'https://picsum.photos/seed/avatar/100/100'),
                    ),
                  ),
                ),
              ],
              pinned: true,
              floating: true,
              forceElevated: innerBoxIsScrolled,
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(50.0),
                child: SizedBox(
                  height: 50.0,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _filters.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: ChoiceChip(
                          label: Text(_filters[index]),
                          selected: _selectedFilter == _filters[index],
                          onSelected: (bool selected) {
                            setState(() {
                              _selectedFilter = _filters[index];
                            });
                          },
                          backgroundColor: const Color(0xFF262626),
                          selectedColor: Colors.deepPurpleAccent,
                          labelStyle: TextStyle(
                            color: _selectedFilter == _filters[index] ? Colors.white : Colors.grey[400],
                            fontSize: 12,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ];
        },
        body: FutureBuilder<List<Movie>>(
          future: _getFilteredMovies(auth.token, settings.isOffline),
          builder: (context, snapshot) {
            if (settings.isOffline && snapshot.hasData && snapshot.data!.isEmpty) {
              return NoInternetState(
                onRetry: () => settings.setOfflineMode(false),
                onGoOffline: () => context.push('/downloads'),
              );
            }

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: settings.isOffline
                  ? [
                      const Padding(
                        padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
                        child: Text('MY DOWNLOADS', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                      ),
                      _buildMovieCategory("Available Offline", Future.value(snapshot.data ?? [])),
                      const SizedBox(height: 400),
                    ]
                  : [
                      _buildCarouselSlider(auth.token),
                      _buildContinueWatchingSection(auth.token),
                      const SizedBox(height: 20),
                      _buildMovieCategory("Trending Now", _apiService.getTrendingMovies(token: auth.token)),
                      _buildMovieCategory("Popular on RIYOBOX", _apiService.getTopRatedMovies(token: auth.token)),
                      _buildMovieCategory("New Releases", _apiService.getNowPlayingMovies(token: auth.token)),
                      const SizedBox(height: 40),
                    ],
              ),
            );
          },
        ),
      ),
    ),
  );
}

  Widget _buildCarouselSlider(String? token) {
    return FutureBuilder<List<Movie>>(
      future: _apiService.getTrendingMovies(token: token),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const ShimmerLoading.rectangular(height: 250);
        }
        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox(
            height: 250,
            child: Center(child: Text('Lama soo rari karin filimada la soo bandhigay.', style: TextStyle(color: Colors.white))),
          );
        }

        final movies = snapshot.data!;

        return Column(
          children: [
            CarouselSlider(
              options: CarouselOptions(
                height: 250.0,
                autoPlay: true,
                viewportFraction: 1.0,
                onPageChanged: (index, reason) {
                  setState(() {
                    _currentCarouselIndex = index;
                  });
                },
              ),
              items: movies.map((movie) {
                return Builder(
                  builder: (BuildContext context) {
                    return GestureDetector(
                      onTap: () {
                        final id = movie.backendId ?? movie.id.toString();
                        context.push('/movie/$id');
                      },
                      child: Stack(
                        children: [
                          Image.network(
                            movie.posterPath.startsWith('http') ? movie.posterPath : 'https://image.tmdb.org/t/p/w500${movie.posterPath}',
                            fit: BoxFit.cover,
                            height: 250.0,
                            width: double.infinity,
                            loadingBuilder: (context, child, progress) {
                              return progress == null
                                  ? child
                                  : const ShimmerLoading.rectangular(height: 250);
                            },
                            errorBuilder: (context, error, stackTrace) =>
                                const Center(child: Icon(Icons.error)),
                          ),
                        Container(
                          height: 250.0,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [Colors.black.withAlpha(204), Colors.transparent],
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 20,
                          left: 20,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                movie.title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                  },
                );
              }).toList(),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: movies.asMap().entries.map((entry) {
                return GestureDetector(
                  onTap: () => setState(() => _currentCarouselIndex = entry.key),
                  child: Container(
                    width: 6.0,
                    height: 6.0,
                    margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white
                          .withAlpha(_currentCarouselIndex == entry.key ? 230 : 102),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildContinueWatchingSection(String? token) {
    return Consumer<PlaybackProvider>(
      builder: (context, playback, child) {
        return FutureBuilder<List<Movie>>(
          future: _apiService.getTrendingMovies(token: token),
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data!.isEmpty) return const SizedBox();
            final moviesWithProgress = snapshot.data!.where((m) => playback.getProgress(m.id.toString()) > Duration.zero).toList();
            if (moviesWithProgress.isEmpty) return const SizedBox();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
                  child: Text('CONTINUE WATCHING', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                SizedBox(
                  height: 160,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    itemCount: moviesWithProgress.length,
                    itemBuilder: (context, index) {
                      final movie = moviesWithProgress[index];
                      return Container(
                        width: 240,
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        child: GestureDetector(
                          onTap: () {
                             final id = movie.backendId ?? movie.id.toString();
                             context.push('/movie/$id/play');
                          },
                          child: Stack(
                            alignment: Alignment.bottomCenter,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  (movie.backdropPath ?? movie.posterPath).startsWith('http')
                                      ? (movie.backdropPath ?? movie.posterPath)
                                      : 'https://image.tmdb.org/t/p/w500${movie.backdropPath ?? movie.posterPath}',
                                  fit: BoxFit.cover,
                                  width: 240,
                                  height: 135,
                                ),
                              ),
                              Container(
                                width: 240,
                                height: 4,
                                color: Colors.white24,
                              ),
                              Positioned(
                                left: 0,
                                child: Container(
                                  width: 120, // Mock progress
                                  height: 4,
                                  color: Colors.deepPurpleAccent,
                                ),
                              ),
                              Positioned(
                                top: 0,
                                left: 0,
                                right: 0,
                                bottom: 0,
                                child: Icon(Icons.play_circle_fill, color: Colors.white.withAlpha(204), size: 48),
                              ),
                              Positioned(
                                bottom: 8,
                                left: 8,
                                child: Text(movie.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildMovieCategory(String title, Future<List<Movie>> future) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 14),
            ],
          ),
        ),
        SizedBox(
          height: 220,
          child: FutureBuilder<List<Movie>>(
            future: future,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return _buildMovieShimmerList();
              }
              if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('Cilad ayaa ka dhacday soo rarida filimada.', style: TextStyle(color: Colors.white)));
              }
              final movies = snapshot.data!;
              return ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: movies.length,
                itemBuilder: (context, index) {
                  final movie = movies[index];
                  return SizedBox(
                    width: 140,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          MovieCard(movie: movie, height: 160),
                          const SizedBox(height: 8),
                          Text(
                            movie.title,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            movie.releaseDate.split('-')[0],
                            style: const TextStyle(color: Colors.grey, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMovieShimmerList() {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: 5,
      itemBuilder: (context, index) {
        return const SizedBox(
          width: 140,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerLoading.rectangular(height: 160),
                SizedBox(height: 8),
                ShimmerLoading.rectangular(height: 14, width: 100),
                SizedBox(height: 4),
                ShimmerLoading.rectangular(height: 12, width: 40),
              ],
            ),
          ),
        );
      },
    );
  }
}
