import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:riyobox/providers/download_provider.dart';
import 'package:riyobox/models/movie.dart';
import 'package:riyobox/presentation/widgets/state_widgets.dart';

class DownloadsScreen extends StatefulWidget {
  const DownloadsScreen({super.key});

  @override
  State<DownloadsScreen> createState() => _DownloadsScreenState();
}

class _DownloadsScreenState extends State<DownloadsScreen> {
  bool _isEditing = false;

  @override
  Widget build(BuildContext context) {
    final downloadProvider = Provider.of<DownloadProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF141414),
      appBar: AppBar(
        backgroundColor: const Color(0xFF141414),
        title: const Text('MY DOWNLOADS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        actions: [
          TextButton(
            onPressed: () => setState(() => _isEditing = !_isEditing),
            child: Text(_isEditing ? 'DONE' : 'EDIT', style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSummaryHeader(downloadProvider),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                if (downloadProvider.downloadingMovies.isNotEmpty) ...[
                  ...downloadProvider.downloadingMovies.map((movie) => _buildDownloadingCard(movie, downloadProvider)),
                ],
                if (downloadProvider.downloadedMovies.isNotEmpty) ...[
                  ...downloadProvider.downloadedMovies.map((movie) => _buildDownloadedCard(movie, downloadProvider)),
                ],
                if (downloadProvider.downloadingMovies.isEmpty && downloadProvider.downloadedMovies.isEmpty)
                  NoDownloadsState(
                    onBrowse: () => context.go('/home'),
                    onHowTo: () {},
                  ),
              ],
            ),
          ),
          _buildFooter(downloadProvider),
        ],
      ),
    );
  }

  Widget _buildSummaryHeader(DownloadProvider provider) {
    final totalVideos = provider.downloadedMovies.length + provider.downloadingMovies.length;
    return Container(
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      child: Text(
        '$totalVideos videos | 5h 17min | ${provider.downloadsSizeGB} GB',
        style: const TextStyle(color: Colors.grey, fontSize: 14),
      ),
    );
  }

  Widget _buildDownloadingCard(Movie movie, DownloadProvider provider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1C),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 100,
                height: 60,
                color: const Color(0xFF262626),
                child: const Icon(Icons.movie, color: Colors.grey),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${movie.title} - Season 1', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('${movie.downloadedEpisodesCount} episode | ${movie.fileSize}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: movie.downloadProgress,
              backgroundColor: Colors.white10,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.deepPurpleAccent),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${(movie.downloadProgress * 100).toInt()}% Downloading...', style: const TextStyle(color: Colors.grey, fontSize: 12)),
              Row(
                children: [
                  TextButton(onPressed: () {}, child: const Text('PAUSE', style: TextStyle(color: Colors.white, fontSize: 12))),
                  TextButton(onPressed: () => provider.cancelDownload(movie.id), child: const Text('CANCEL', style: TextStyle(color: Colors.red, fontSize: 12))),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDownloadedCard(Movie movie, DownloadProvider provider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1C),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Container(
            width: 100,
            height: 60,
            color: const Color(0xFF262626),
            child: const Icon(Icons.check_circle, color: Colors.green),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(movie.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('${movie.isTvShow ? '1 episode' : '2h 3min'} | ${movie.fileSize} | Downloaded', style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(icon: const Icon(Icons.play_arrow, color: Colors.white), onPressed: () {}),
              if (_isEditing)
                IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red), onPressed: () => provider.deleteDownload(movie.id))
              else
                IconButton(icon: const Icon(Icons.settings_outlined, color: Colors.white, size: 20), onPressed: () {}),
            ],
          ),
        ],
      ),
    );
  }


  Widget _buildFooter(DownloadProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Color(0xFF1C1C1C),
        border: Border(top: BorderSide(color: Colors.white10)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Storage: ${provider.usedStorageGB} GB of ${provider.totalStorageGB} GB used', style: const TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(13),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Row(
                children: [
                  Icon(Icons.speed, color: Colors.white, size: 16),
                  SizedBox(width: 8),
                  Text('Download Queue: 3 pending', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Text('Auto Downloads: ', style: TextStyle(color: Colors.grey, fontSize: 13)),
                    Text(provider.autoDownloadEpisodes ? 'ON' : 'OFF', style: TextStyle(color: provider.autoDownloadEpisodes ? Colors.green : Colors.red, fontWeight: FontWeight.bold, fontSize: 13)),
                  ],
                ),
                TextButton(
                  onPressed: () => context.push('/settings'),
                  child: const Text('MANAGE', style: TextStyle(color: Colors.deepPurpleAccent, fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
