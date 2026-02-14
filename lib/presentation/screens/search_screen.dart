import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:riyobox/models/movie.dart';
import 'package:riyobox/services/api_service.dart';
import 'package:riyobox/providers/auth_provider.dart';
import 'package:riyobox/providers/settings_provider.dart';
import 'package:riyobox/presentation/widgets/movie_card.dart';
import 'package:riyobox/presentation/widgets/shimmer_loading.dart';
import 'package:riyobox/presentation/widgets/state_widgets.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ApiService _apiService = ApiService();
  List<Movie> _searchResults = [];
  bool _isLoading = false;
  bool _hasSearched = false;

  void _onSearchChanged(String query, bool isOffline, {String? token}) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isLoading = false;
        _hasSearched = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _hasSearched = true;
    });

    try {
      final movies = await _apiService.getTrendingMovies(token: token);
      var filteredMovies = movies.where((movie) =>
        movie.title.toLowerCase().contains(query.toLowerCase())).toList();

      if (isOffline) {
        filteredMovies = filteredMovies.where((m) => m.isDownloaded).toList();
      }

      setState(() {
        _searchResults = filteredMovies;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF141414),
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchHeader(settings.isOffline, token: auth.token),
            Expanded(
              child: _isLoading
                ? _buildLoadingGrid()
                : (_hasSearched ? _buildSearchResults() : _buildInitialContent()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchHeader(bool isOffline, {String? token}) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (val) => _onSearchChanged(val, isOffline, token: token),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: isOffline ? 'Search downloads...' : 'Search movies, TV shows...',
                hintStyle: const TextStyle(color: Colors.white54, fontSize: 14),
                prefixIcon: const Icon(Icons.search, color: Colors.deepPurpleAccent),
                filled: true,
                fillColor: const Color(0xFF1C1C1C),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4.0),
                  borderSide: BorderSide.none,
                ),
                suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: Colors.white54),
                      onPressed: () {
                        _searchController.clear();
                      _onSearchChanged('', isOffline, token: token);
                      },
                    )
                  : null,
              ),
            ),
          ),
          if (_searchController.text.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: GestureDetector(
                onTap: () {
                  _searchController.clear();
                  _onSearchChanged('', isOffline, token: token);
                  FocusScope.of(context).unfocus();
                },
                child: const Text(
                  'CANCEL',
                  style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInitialContent() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      children: [
        const Text(
          'TOP SEARCHES',
          style: TextStyle(
              color: Colors.white,
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.1),
        ),
        const SizedBox(height: 16.0),
        _buildTrendingSearch('Inception'),
        _buildTrendingSearch('Interstellar'),
        _buildTrendingSearch('The Dark Knight'),
        _buildTrendingSearch('Pulp Fiction'),
        const SizedBox(height: 32.0),
        const Text(
          'CATEGORIES',
          style: TextStyle(
              color: Colors.white,
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.1),
        ),
        const SizedBox(height: 16.0),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12.0,
          crossAxisSpacing: 12.0,
          childAspectRatio: 2.2,
          children: [
            _buildCategoryChip('Action', Colors.redAccent),
            _buildCategoryChip('Comedy', Colors.orangeAccent),
            _buildCategoryChip('Drama', Colors.blueAccent),
            _buildCategoryChip('Horror', Colors.deepPurpleAccent),
          ],
        ),
      ],
    );
  }

  Widget _buildSearchResults() {
    if (_searchResults.isEmpty) {
      return NoSearchResultsState(
        query: _searchController.text,
        onBack: () {
          _searchController.clear();
          _onSearchChanged('', false);
        },
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.7,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        return MovieCard(movie: _searchResults[index]);
      },
    );
  }

  Widget _buildLoadingGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.7,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: 6,
      itemBuilder: (context, index) => const ShimmerLoading.rectangular(height: 150),
    );
  }

  Widget _buildTrendingSearch(String title) {
    return ListTile(
      leading: const Icon(Icons.trending_up, color: Colors.white24),
      title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 14)),
      trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white24, size: 14.0),
      onTap: () {
        _searchController.text = title;
        // Logic to trigger search
      },
    );
  }

  Widget _buildCategoryChip(String label, Color color) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4.0),
        color: const Color(0xFF1C1C1C),
        border: Border.all(color: color.withAlpha(50)),
      ),
      child: Center(
        child: Text(
          label.toUpperCase(),
          style: const TextStyle(color: Colors.white, fontSize: 14.0, fontWeight: FontWeight.bold, letterSpacing: 1.1),
        ),
      ),
    );
  }
}
