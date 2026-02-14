
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riyobox/models/movie.dart';
import 'package:riyobox/presentation/widgets/shimmer_loading.dart';

class MovieCard extends StatelessWidget {
  final Movie movie;
  final double height;

  const MovieCard({super.key, required this.movie, this.height = 200});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final id = movie.backendId ?? movie.id.toString();
        context.push('/movie/$id');
      },
      child: Stack(
        children: [
          Card(
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            child: SizedBox(
              height: height,
              width: double.infinity,
              child: Image.network(
                movie.posterPath.isNotEmpty
                  ? (movie.posterPath.startsWith('http') ? movie.posterPath : 'https://image.tmdb.org/t/p/w500${movie.posterPath}')
                  : 'https://picsum.photos/seed/${movie.id}/200/300',
                fit: BoxFit.cover,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return ShimmerLoading.rectangular(height: height);
                },
                errorBuilder: (context, error, stackTrace) =>
                    const Center(child: Icon(Icons.movie, color: Colors.white24)),
              ),
            ),
          ),
          if (movie.isDownloaded)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle, color: Colors.green, size: 16),
              ),
            ),
          if (movie.isDownloading)
            Positioned(
              bottom: 4,
              left: 4,
              right: 4,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(
                  value: movie.downloadProgress,
                  backgroundColor: Colors.white10,
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.deepPurpleAccent),
                  minHeight: 3,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
