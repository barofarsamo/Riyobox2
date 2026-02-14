class Movie {
  final int id;
  final String? backendId; // MongoDB _id
  final String title;
  final String overview;
  final String posterPath;
  final String? backdropPath;
  final String releaseDate;
  final double voteAverage;
  final int? runtime;
  final List<String>? genres;
  final List<String>? cast;
  final String? director;
  final String? contentRating;
  final bool isTvShow;
  final List<Season>? seasons;
  final String? videoUrl;

  // Download related fields
  final bool isDownloaded;
  final bool isDownloading;
  final double downloadProgress;
  final String fileSize;
  final int downloadedEpisodesCount;

  Movie({
    required this.id,
    this.backendId,
    required this.title,
    required this.overview,
    required this.posterPath,
    this.backdropPath,
    required this.releaseDate,
    this.voteAverage = 0.0,
    this.runtime,
    this.genres,
    this.cast,
    this.director,
    this.contentRating,
    this.isTvShow = false,
    this.seasons,
    this.videoUrl,
    this.isDownloaded = false,
    this.isDownloading = false,
    this.downloadProgress = 0.0,
    this.fileSize = '0 MB',
    this.downloadedEpisodesCount = 0,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'] ?? (json['_id'] != null ? json['_id'].toString().hashCode : 0),
      backendId: json['_id']?.toString(),
      title: json['title'] ?? '',
      overview: json['overview'] ?? json['description'] ?? '',
      posterPath: json['poster_path'] ?? json['posterUrl'] ?? '',
      backdropPath: json['backdrop_path'] ?? json['backdropUrl'] ?? json['posterUrl'],
      releaseDate: json['release_date'] ?? json['year']?.toString() ?? json['createdAt']?.toString().split('T')[0] ?? '',
      voteAverage: (json['vote_average'] as num?)?.toDouble() ?? (json['rating'] as num?)?.toDouble() ?? 0.0,
      runtime: json['runtime'] ?? (json['duration'] != null ? _parseDuration(json['duration']) : null),
      genres: json['genre'] != null ? List<String>.from(json['genre']) : null,
      contentRating: json['contentRating'],
      isTvShow: json['is_tv_show'] ?? false,
      videoUrl: json['videoUrl'],
      isDownloaded: json['is_downloaded'] ?? false,
      isDownloading: json['is_downloading'] ?? false,
      downloadProgress: (json['download_progress'] as num?)?.toDouble() ?? 0.0,
      fileSize: json['file_size'] ?? '0 MB',
      downloadedEpisodesCount: json['downloaded_episodes_count'] ?? 0,
    );
  }

  static int? _parseDuration(String duration) {
    try {
      if (duration.contains('h')) {
        final parts = duration.split('h');
        int hours = int.parse(parts[0].trim());
        int minutes = 0;
        if (parts[1].contains('m')) {
          minutes = int.parse(parts[1].replaceAll('m', '').trim());
        }
        return (hours * 60) + minutes;
      }
      return int.tryParse(duration.replaceAll('min', '').trim());
    } catch (_) {
      return null;
    }
  }

  Movie copyWith({
    bool? isDownloaded,
    bool? isDownloading,
    double? downloadProgress,
    int? downloadedEpisodesCount,
  }) {
    return Movie(
      id: id,
      title: title,
      overview: overview,
      posterPath: posterPath,
      backdropPath: backdropPath,
      releaseDate: releaseDate,
      voteAverage: voteAverage,
      runtime: runtime,
      genres: genres,
      cast: cast,
      director: director,
      contentRating: contentRating,
      isTvShow: isTvShow,
      seasons: seasons,
      isDownloaded: isDownloaded ?? this.isDownloaded,
      isDownloading: isDownloading ?? this.isDownloading,
      downloadProgress: downloadProgress ?? this.downloadProgress,
      fileSize: fileSize,
      downloadedEpisodesCount: downloadedEpisodesCount ?? this.downloadedEpisodesCount,
    );
  }
}

class Season {
  final int number;
  final String title;
  final List<Episode> episodes;

  Season({required this.number, required this.title, required this.episodes});
}

class Episode {
  final int number;
  final String title;
  final String duration;
  final String? videoUrl;

  Episode({required this.number, required this.title, required this.duration, this.videoUrl});
}
