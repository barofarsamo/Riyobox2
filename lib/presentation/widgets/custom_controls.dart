import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class CustomControls extends StatefulWidget {
  final VideoPlayerController controller;

  const CustomControls({super.key, required this.controller});

  @override
  State<CustomControls> createState() => _CustomControlsState();
}

class _CustomControlsState extends State<CustomControls> {
  bool _isVisible = true;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
  }

  void _toggleVisibility() {
    setState(() {
      _isVisible = !_isVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleVisibility,
      child: AnimatedOpacity(
        opacity: _isVisible ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 300),
        child: Container(
          color: const Color.fromRGBO(0, 0, 0, 0.4),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              VideoProgressIndicator(
                widget.controller,
                allowScrubbing: true,
                padding: const EdgeInsets.all(10.0),
                colors: const VideoProgressColors(
                  playedColor: Colors.red,
                  bufferedColor: Colors.grey,
                  backgroundColor: Colors.black,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  IconButton(
                    icon: Icon(
                      widget.controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                      color: Colors.white,
                      size: 30.0,
                    ),
                    onPressed: () {
                      setState(() {
                        widget.controller.value.isPlaying
                            ? widget.controller.pause()
                            : widget.controller.play();
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
