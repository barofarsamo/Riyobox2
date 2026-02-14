import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:riyobox/providers/settings_provider.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);

    final List<Map<String, String>> genres = [
      {'name': 'Action', 'image': 'https://picsum.photos/seed/action/400/200'},
      {'name': 'Comedy', 'image': 'https://picsum.photos/seed/comedy/400/200'},
      {'name': 'Drama', 'image': 'https://picsum.photos/seed/drama/400/200'},
      {'name': 'Horror', 'image': 'https://picsum.photos/seed/horror/400/200'},
      {'name': 'Sci-Fi', 'image': 'https://picsum.photos/seed/scifi/400/200'},
      {'name': 'Romance', 'image': 'https://picsum.photos/seed/romance/400/200'},
      {'name': 'Anime', 'image': 'https://picsum.photos/seed/anime/400/200'},
      {'name': 'Documentary', 'image': 'https://picsum.photos/seed/documentary/400/200'},
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF141414),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: const Color(0xFF141414),
            title: Row(
              children: [
                const Text('RIYOBOX', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(width: 12),
                if (!settings.isOffline) ...[
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text('Online', style: TextStyle(color: Colors.green, fontSize: 12)),
                ] else
                   const Text('Offline', style: TextStyle(color: Colors.redAccent, fontSize: 12)),
              ],
            ),
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
            floating: true,
            pinned: true,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: _buildFeaturedCategoryCard(context),
            ),
          ),
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
              child: Text('BROWSE GENRES', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.1)),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16.0),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.6,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final genre = genres[index]['name']!;
                  return InkWell(
                    onTap: () {
                      // Navigate to a screen showing movies of this genre
                      // For now, we reuse search or a new route
                      context.push('/genre/$genre');
                    },
                    child: _buildGenreCard(genre, genres[index]['image']!),
                  );
                },
                childCount: genres.length,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedCategoryCard(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      child: Stack(
        alignment: Alignment.bottomLeft,
        children: [
          Image.network(
            'https://picsum.photos/seed/van/800/400',
            height: 180,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
          Container(
            height: 180,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.black87, Colors.transparent],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('FEATURED CATEGORY', style: TextStyle(color: Colors.deepPurpleAccent, fontSize: 11, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                const Text('ANIME HUB', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  ),
                  child: const Text('EXPLORE', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildGenreCard(String name, String imageUrl) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        image: DecorationImage(
          image: NetworkImage(imageUrl),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(Colors.black.withAlpha(100), BlendMode.darken),
        ),
      ),
      child: Center(
        child: Text(
          name.toUpperCase(),
          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.2),
        ),
      ),
    );
  }
}
