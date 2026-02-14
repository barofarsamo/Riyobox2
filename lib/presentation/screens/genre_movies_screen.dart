import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:riyobox/models/movie.dart';
import 'package:riyobox/services/api_service.dart';
import 'package:riyobox/providers/auth_provider.dart';
import 'package:riyobox/presentation/widgets/movie_card.dart';
import 'package:riyobox/presentation/widgets/shimmer_loading.dart';

class GenreMoviesScreen extends StatelessWidget {
  final String genreName;
  final ApiService _apiService = ApiService();

  GenreMoviesScreen({super.key, required this.genreName});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF141414),
      appBar: AppBar(
        backgroundColor: const Color(0xFF141414),
        title: Text(genreName.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<List<Movie>>(
        future: _apiService.getTrendingMovies(token: auth.token, genre: genreName),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingGrid();
          }
          if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.movie_outlined, size: 80, color: Colors.white10),
                  const SizedBox(height: 16),
                  Text('No movies found in $genreName', style: const TextStyle(color: Colors.white70)),
                ],
              ),
            );
          }

          final movies = snapshot.data!;
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 0.65,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: movies.length,
            itemBuilder: (context, index) {
              return MovieCard(movie: movies[index], height: 160);
            },
          );
        },
      ),
    );
  }

  Widget _buildLoadingGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.65,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: 9,
      itemBuilder: (context, index) => const ShimmerLoading.rectangular(height: 160),
    );
  }
}
