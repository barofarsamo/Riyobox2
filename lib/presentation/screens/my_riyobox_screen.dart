
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riyobox/presentation/widgets/shimmer_loading.dart';
import 'package:riyobox/models/movie.dart';
import 'package:riyobox/services/api_service.dart';
import 'package:riyobox/presentation/widgets/state_widgets.dart';
import 'package:riyobox/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class MyRiyoboxScreen extends StatelessWidget {
  const MyRiyoboxScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final apiService = ApiService();

    return Scaffold(
      backgroundColor: const Color(0xFF141414),
      appBar: AppBar(
        backgroundColor: const Color(0xFF141414),
        elevation: 0,
        title: const Text('MY RIYOBOX', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.cast, color: Colors.white),
            onPressed: () => context.push('/cast'),
          ),
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () => context.push('/settings'),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: GestureDetector(
              onTap: () => context.push('/profile'),
              child: const CircleAvatar(
                radius: 16,
                backgroundImage: NetworkImage('https://picsum.photos/seed/profile/100/100'),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildProfileHeader(context),
            const SizedBox(height: 32),
            _buildStatsSection(context, auth.token),
            const SizedBox(height: 40),
            _buildSectionHeader('MY WATCHLIST', onTap: () {}),
            const SizedBox(height: 16),
            FutureBuilder<List<Movie>>(
              future: auth.token != null ? apiService.getWatchlist(auth.token!) : Future.value([]),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                return _buildMovieHorizontalList(context, snapshot.data!);
              }
            ),
            const SizedBox(height: 40),
            _buildSectionHeader('ACCOUNT SETTINGS', showArrow: false),
            const SizedBox(height: 16),
            _buildAccountSettings(context),
            const SizedBox(height: 48),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () => context.push('/profile'),
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.bottomRight,
            children: [
              const CircleAvatar(
                radius: 45,
                backgroundColor: Color(0xFF262626),
                child: Icon(Icons.person, color: Colors.grey, size: 50),
              ),
              Positioned(
                right: -2,
                bottom: -2,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.deepPurpleAccent,
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF141414), width: 2),
                  ),
                  padding: const EdgeInsets.all(6),
                  child: const Icon(Icons.edit, color: Colors.white, size: 16),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Text('Jules Engineer', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.deepPurpleAccent.withAlpha(40),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.deepPurpleAccent, width: 1),
          ),
          child: const Text('PREMIUM MEMBER', style: TextStyle(color: Colors.deepPurpleAccent, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.1)),
        ),
      ],
    );
  }

  Widget _buildStatsSection(BuildContext context, String? token) {
    final apiService = ApiService();
    return FutureBuilder<List<Movie>>(
      future: token != null ? apiService.getWatchlist(token) : Future.value([]),
      builder: (context, snapshot) {
        final watchlistCount = snapshot.data?.length ?? 0;
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildStatItem(context, watchlistCount.toString(), 'WATCHLIST', () {}),
            _buildStatItem(context, '0', 'HISTORY', () {}),
            _buildStatItem(context, '0', 'DOWNLOADS', () => context.go('/downloads')),
          ],
        );
      }
    );
  }

  Widget _buildStatItem(BuildContext context, String value, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.1)),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, {bool showArrow = true, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.1)),
          if (showArrow)
            const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 14),
        ],
      ),
    );
  }

  Widget _buildMovieHorizontalList(BuildContext context, List<Movie> movies) {
    if (movies.isEmpty) {
      return const Center(child: Text('Your list is empty', style: TextStyle(color: Colors.white54)));
    }

    return SizedBox(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: movies.length,
        itemBuilder: (context, index) {
          final movie = movies[index];
          return GestureDetector(
            onTap: () {
              final id = movie.backendId ?? movie.id.toString();
              context.push('/movie/$id');
            },
            child: Container(
              width: 130,
              margin: const EdgeInsets.only(right: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Image.network(
                        movie.posterPath.startsWith('http') ? movie.posterPath : 'https://image.tmdb.org/t/p/w500${movie.posterPath}',
                        fit: BoxFit.cover,
                        width: double.infinity,
                         loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return const ShimmerLoading.rectangular(height: 180);
                        },
                        errorBuilder: (context, error, stackTrace) => Container(color: const Color(0xFF262626), child: const Icon(Icons.movie, color: Colors.white10)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(movie.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text('${movie.releaseDate.split('-')[0]} | ${movie.genres?.first ?? "N/A"}', style: const TextStyle(color: Colors.grey, fontSize: 11)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAccountSettings(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    return Column(
      children: [
        if (auth.role == 'admin')
           _buildSettingsButton(
            context,
            icon: Icons.admin_panel_settings_outlined,
            text: 'Admin Panel',
            onTap: () => context.push('/admin'),
          ),
        if (auth.role == 'admin')
          const SizedBox(height: 8),
        _buildSettingsButton(
          context,
          icon: Icons.person_outline,
          text: 'Profile Information',
          onTap: () => context.push('/profile'),
        ),
        const SizedBox(height: 8),
        _buildSettingsButton(
          context,
          icon: Icons.settings_outlined,
          text: 'App Settings',
          onTap: () => context.push('/settings'),
        ),
        const SizedBox(height: 8),
         _buildSettingsButton(
          context,
          icon: Icons.subscriptions_outlined,
          text: 'Subscription Plans',
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildSettingsButton(BuildContext context, {required IconData icon, required String text, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF1C1C1C),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 16),
            Expanded(child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500))),
            const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        const Text('RIYOBOX PREMIUM V2.4.0', style: TextStyle(color: Colors.white24, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.1)),
        const SizedBox(height: 4),
        const Text('CLOUD ID: 9L6K4D38', style: TextStyle(color: Colors.white24, fontSize: 10, letterSpacing: 1.1)),
      ],
    );
  }
}
