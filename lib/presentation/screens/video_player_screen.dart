import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:flutter_volume_controller/flutter_volume_controller.dart';
import 'dart:async';
import 'dart:developer' as developer;
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:riyobox/providers/playback_provider.dart';
import 'package:riyobox/providers/auth_provider.dart';
import 'package:riyobox/services/api_service.dart';
import 'package:riyobox/models/movie.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String? movieId;
  final String? videoUrl;

  const VideoPlayerScreen({super.key, this.movieId, this.videoUrl});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  VideoPlayerController? _controller;
  bool _isControlsVisible = true;
  Timer? _hideControlsTimer;
  double _currentVolume = 0.5;
  double _currentBrightness = 0.5;
  double _playbackSpeed = 1.0;
  String _selectedQuality = 'Auto';
  String _selectedAudio = 'English';
  String _selectedSubtitle = 'Off';
  bool _isBuffering = false;

  @override
  void initState() {
    super.initState();
    WakelockPlus.enable();
    _initPlayer();
    _initVolume();
    _initBrightness();
  }

  Future<void> _initPlayer() async {
    String? url = widget.videoUrl;

    if (url == null && widget.movieId != null) {
      try {
        final token = Provider.of<AuthProvider>(context, listen: false).token;
        final movie = await ApiService().getMovieDetails(widget.movieId!, token: token);
        url = movie.videoUrl;
      } catch (e) {
        developer.log('Error fetching movie details: $e');
      }
    }

    url ??= 'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4';

    _controller = VideoPlayerController.networkUrl(Uri.parse(url))
      ..initialize().then((_) {
        if (mounted) {
          setState(() {});
          final progress = Provider.of<PlaybackProvider>(context, listen: false).getProgress(widget.movieId ?? '');
          if (progress > Duration.zero) {
            _showResumeDialog(progress);
          } else {
            _controller!.play();
          }
          _startHideControlsTimer();
        }
      });

    _controller!.addListener(() {
      if (mounted) {
        final isBuffering = _controller!.value.isBuffering;
        if (isBuffering != _isBuffering) {
           setState(() => _isBuffering = isBuffering);
        } else {
           setState(() {});
        }
      }
    });
  }

  Future<void> _initVolume() async {
    _currentVolume = await FlutterVolumeController.getVolume() ?? 0.5;
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _initBrightness() async {
    try {
      _currentBrightness = await ScreenBrightness().application;
    } catch (e) {
      developer.log('Failed to get current brightness: $e', name: 'video_player_screen');
      _currentBrightness = 0.5;
    }
    if (mounted) {
      setState(() {});
    }
  }

  void _toggleControls() {
    setState(() {
      _isControlsVisible = !_isControlsVisible;
    });
    if (_isControlsVisible) {
      _startHideControlsTimer();
    }
  }

  void _showResumeDialog(Duration progress) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A3A),
        title: const Text('CONTINUE WATCHING', style: TextStyle(color: Colors.yellow, fontSize: 16)),
        content: Text('Resume from ${_formatDuration(progress)}?', style: const TextStyle(color: Colors.white)),
        actions: [
          TextButton(
            onPressed: () {
              Provider.of<PlaybackProvider>(context, listen: false).resetProgress(widget.movieId ?? '');
              _controller?.play();
              Navigator.pop(dialogContext);
            },
            child: const Text('Restart', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              _controller?.seekTo(progress);
              _controller?.play();
              Navigator.pop(dialogContext);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.yellow),
            child: const Text('Resume', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  void _startHideControlsTimer() {
    _hideControlsTimer?.cancel();
    _hideControlsTimer = Timer(const Duration(seconds: 3), () {
      if (mounted && _controller != null && _controller!.value.isPlaying) {
        setState(() {
          _isControlsVisible = false;
        });
      }
    });
  }

  @override
  void dispose() {
    if (widget.movieId != null && _controller != null) {
      Provider.of<PlaybackProvider>(context, listen: false).updateProgress(widget.movieId!, _controller!.value.position);
    }
    WakelockPlus.disable();
    _controller?.dispose();
    _hideControlsTimer?.cancel();
    super.dispose();
  }

  void _seekRelative(Duration duration) {
    if (_controller == null) return;
    final newPosition = _controller!.value.position + duration;
    _controller!.seekTo(newPosition);
    _startHideControlsTimer();

    // Show a quick visual indicator
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(duration.isNegative ? 'Seek -10s' : 'Seek +10s'),
        duration: const Duration(milliseconds: 500),
        behavior: SnackBarBehavior.floating,
        width: 100,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _toggleControls,
        onDoubleTapDown: (details) {
          if (details.localPosition.dx < MediaQuery.of(context).size.width / 2) {
             _seekRelative(const Duration(seconds: -10));
          } else {
             _seekRelative(const Duration(seconds: 10));
          }
        },
        onVerticalDragUpdate: (details) {
          if (details.localPosition.dx < MediaQuery.of(context).size.width / 2) {
            // Brightness
            _currentBrightness = (_currentBrightness - details.delta.dy / 100).clamp(0.0, 1.0);
            ScreenBrightness().setApplicationScreenBrightness(_currentBrightness);
          } else {
            // Volume
            _currentVolume = (_currentVolume - details.delta.dy / 100).clamp(0.0, 1.0);
            FlutterVolumeController.setVolume(_currentVolume);
          }
          setState(() {});
          _startHideControlsTimer();
        },
        child: Stack(
          children: <Widget>[
            Center(
              child: (_controller != null && _controller!.value.isInitialized)
                  ? AspectRatio(
                      aspectRatio: _controller!.value.aspectRatio,
                      child: VideoPlayer(_controller!),
                    )
                  : const CircularProgressIndicator(color: Colors.yellow),
            ),
            if (_isBuffering)
              const Center(child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                   CircularProgressIndicator(color: Colors.yellow),
                   SizedBox(height: 8),
                   Text('Buffering...', style: TextStyle(color: Colors.white)),
                ],
              )),
            if (_isControlsVisible) _buildControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildControls() {
    return Container(
      color: Colors.black45,
      child: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            const Spacer(),
            _buildPlaybackControls(),
            const Spacer(),
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          const Expanded(
            child: Text(
              'Movie Playing',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(icon: const Icon(Icons.cast, color: Colors.white), onPressed: () => context.push('/cast')),
          IconButton(icon: const Icon(Icons.more_vert, color: Colors.white), onPressed: () => _showSettingsMenu()),
        ],
      ),
    );
  }

  Widget _buildPlaybackControls() {
    if (_controller == null) return const SizedBox();
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.replay_10, color: Colors.white, size: 40),
          onPressed: () {
            _controller!.seekTo(
              _controller!.value.position - const Duration(seconds: 10),
            );
            _startHideControlsTimer();
          },
        ),
        const SizedBox(width: 40),
        IconButton(
          icon: Icon(
            _controller!.value.isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
            color: Colors.yellow,
            size: 80,
          ),
          onPressed: () {
            setState(() {
              _controller!.value.isPlaying ? _controller!.pause() : _controller!.play();
              _startHideControlsTimer();
            });
          },
        ),
        const SizedBox(width: 40),
        IconButton(
          icon: const Icon(Icons.forward_10, color: Colors.white, size: 40),
          onPressed: () {
            _controller!.seekTo(
              _controller!.value.position + const Duration(seconds: 10),
            );
            _startHideControlsTimer();
          },
        ),
      ],
    );
  }

  Widget _buildBottomBar() {
    if (_controller == null) return const SizedBox();
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
           VideoProgressIndicator(
            _controller!,
            allowScrubbing: true,
            colors: const VideoProgressColors(
              playedColor: Colors.yellow,
              bufferedColor: Colors.white24,
              backgroundColor: Colors.white10,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_formatDuration(_controller!.value.position)} / ${_formatDuration(_controller!.value.duration)}',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
              Row(
                children: [
                  _buildControlItem(Icons.speed, '${_playbackSpeed}x', _showSpeedMenu),
                  _buildControlItem(Icons.high_quality, _selectedQuality, _showQualityMenu),
                  _buildControlItem(Icons.language, _selectedAudio, _showAudioMenu),
                  _buildControlItem(Icons.subtitles, _selectedSubtitle, _showSubtitleMenu),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildControlItem(IconData icon, String label, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(left: 16),
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            Text(label, style: const TextStyle(color: Colors.white, fontSize: 10)),
          ],
        ),
      ),
    );
  }

  void _showSpeedMenu() {
    _showBottomDialog('Playback Speed', ['0.5x', '0.75x', '1.0x', '1.25x', '1.5x', '2.0x'], (val) {
      setState(() {
        _playbackSpeed = double.parse(val.replaceAll('x', ''));
        _controller?.setPlaybackSpeed(_playbackSpeed);
      });
    });
  }

  void _showQualityMenu() {
    _showBottomDialog('Video Quality', ['Auto', '480p', '720p', '1080p', '4K'], (val) {
      setState(() => _selectedQuality = val);
    });
  }

  void _showAudioMenu() {
    _showBottomDialog('Audio Track', ['English', 'Somali', 'Arabic', 'French', 'Spanish'], (val) {
      setState(() => _selectedAudio = val);
    });
  }

  void _showSubtitleMenu() {
    _showBottomDialog('Subtitles', ['Off', 'English', 'Somali', 'Arabic', 'French'], (val) {
      setState(() => _selectedSubtitle = val);
    });
  }

  void _showSettingsMenu() {
    _showBottomDialog('Settings', ['Auto-play next', 'Skip Intro', 'Skip Credits'], (val) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$val toggled')));
    });
  }

  void _showBottomDialog(String title, List<String> options, Function(String) onSelect) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF2A2A3A),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(color: Colors.yellow, fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 16),
            ...options.map((opt) => ListTile(
              title: Text(opt, style: const TextStyle(color: Colors.white)),
              onTap: () {
                onSelect(opt);
                Navigator.pop(context);
              },
            )),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    if (hours > 0) {
      return '${twoDigits(hours)}:${twoDigits(minutes)}:${twoDigits(seconds)}';
    } else {
      return '${twoDigits(minutes)}:${twoDigits(seconds)}';
    }
  }
}
