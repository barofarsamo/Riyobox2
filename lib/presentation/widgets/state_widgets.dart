import 'package:flutter/material.dart';

class StateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final List<Widget>? bulletPoints;
  final String? primaryActionText;
  final VoidCallback? onPrimaryAction;
  final String? secondaryActionText;
  final VoidCallback? onSecondaryAction;

  const StateWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.bulletPoints,
    this.primaryActionText,
    this.onPrimaryAction,
    this.secondaryActionText,
    this.onSecondaryAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 80, color: Colors.deepPurpleAccent),
            const SizedBox(height: 24),
            Text(
              title.toUpperCase(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              description,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey, fontSize: 16),
            ),
            if (bulletPoints != null && bulletPoints!.isNotEmpty) ...[
              const SizedBox(height: 24),
              Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: bulletPoints!,
                ),
              ),
            ],
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (primaryActionText != null)
                  ElevatedButton(
                    onPressed: onPrimaryAction,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    ),
                    child: Text(primaryActionText!.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                if (primaryActionText != null && secondaryActionText != null)
                  const SizedBox(width: 16),
                if (secondaryActionText != null)
                  OutlinedButton(
                    onPressed: onSecondaryAction,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white24),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    ),
                    child: Text(secondaryActionText!.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class BulletPoint extends StatelessWidget {
  final String text;
  const BulletPoint({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 32),
      child: Row(
        children: [
          const Icon(Icons.circle, size: 6, color: Colors.deepPurpleAccent),
          const SizedBox(width: 12),
          Text(text, style: const TextStyle(color: Colors.white70, fontSize: 14)),
        ],
      ),
    );
  }
}

// Pre-defined states
class NoInternetState extends StatelessWidget {
  final VoidCallback onRetry;
  final VoidCallback onGoOffline;

  const NoInternetState({super.key, required this.onRetry, required this.onGoOffline});

  @override
  Widget build(BuildContext context) {
    return StateWidget(
      icon: Icons.public_off,
      title: 'No Internet Connection',
      description: "You're currently offline.",
      bulletPoints: const [
        BulletPoint(text: '12 downloaded movies'),
        BulletPoint(text: 'Watch history'),
        BulletPoint(text: 'My List'),
        BulletPoint(text: 'Profile settings'),
      ],
      primaryActionText: 'Retry Connection',
      onPrimaryAction: onRetry,
      secondaryActionText: 'Go Offline',
      onSecondaryAction: onGoOffline,
    );
  }
}

class NoDownloadsState extends StatelessWidget {
  final VoidCallback onBrowse;
  final VoidCallback onHowTo;

  const NoDownloadsState({super.key, required this.onBrowse, required this.onHowTo});

  @override
  Widget build(BuildContext context) {
    return StateWidget(
      icon: Icons.download_for_offline_outlined,
      title: 'No Downloads Yet',
      description: 'Movies you download will appear here. Downloading lets you watch offline when you don\'t have internet.',
      primaryActionText: 'Browse Movies',
      onPrimaryAction: onBrowse,
      secondaryActionText: 'How to Download',
      onSecondaryAction: onHowTo,
    );
  }
}

class NoHistoryState extends StatelessWidget {
  final VoidCallback onStartWatching;

  const NoHistoryState({super.key, required this.onStartWatching});

  @override
  Widget build(BuildContext context) {
    return StateWidget(
      icon: Icons.history,
      title: 'No Watch History',
      description: 'Movies and shows you watch will appear here. Start watching to get personalized recommendations!',
      primaryActionText: 'Start Watching',
      onPrimaryAction: onStartWatching,
    );
  }
}

class NoSearchResultsState extends StatelessWidget {
  final String query;
  final VoidCallback onBack;

  const NoSearchResultsState({super.key, required this.query, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return StateWidget(
      icon: Icons.search_off,
      title: 'No Results Found',
      description: 'We couldn\'t find any matches for "$query".',
      bulletPoints: const [
        BulletPoint(text: 'Check your spelling'),
        BulletPoint(text: 'Try different keywords'),
        BulletPoint(text: 'Browse by category'),
        BulletPoint(text: 'Contact support for help'),
      ],
      primaryActionText: 'Back to Search',
      onPrimaryAction: onBack,
    );
  }
}
