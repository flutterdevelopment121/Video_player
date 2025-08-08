//4k button without loding
import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_compress/video_compress.dart';
import 'package:video_player/video_player.dart';
import 'dart:ui'; // For BackdropFilter

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const VideoApp());
}

class VideoApp extends StatelessWidget {
  const VideoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Video Player App",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const VideoSelectionPage(),
    );
  }
}

class VideoSelectionPage extends StatefulWidget {
  const VideoSelectionPage({super.key});

  @override
  State<VideoSelectionPage> createState() => _VideoSelectionPageState();
}

class _VideoSelectionPageState extends State<VideoSelectionPage> {
  bool _isProcessing = false;

  Future<void> _checkPermissions() async {
    if (Platform.isAndroid) {
      if (await Permission.storage.isDenied ||
          await Permission.manageExternalStorage.isDenied) {
        await [Permission.storage, Permission.manageExternalStorage].request();
      }
      if (Platform.version.contains('13') || Platform.version.contains('14')) {
        await Permission.videos.request();
      }
    }
  }

  /// Compresses the video only once with low quality to reduce size while keeping audio.
  Future<String?> _compressVideoOnce(String videoPath) async {
    setState(() {
      _isProcessing = true;
    });

    try {
      final info = await VideoCompress.compressVideo(
        videoPath,
        quality: VideoQuality.LowQuality,
        deleteOrigin: false,
        includeAudio: true,
      );

      if (info == null || info.path == null) return null;

      return info.path!;
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  Future<void> _selectAndPlayVideo() async {
    await _checkPermissions();

    final result = await FilePicker.platform.pickFiles(
      type: FileType.video,
      allowMultiple: false,
    );

    if (result == null || result.files.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No video selected.")),
        );
      }
      return;
    }

    final pickedFilePath = result.files.single.path;
    if (pickedFilePath == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to get video path.")),
        );
      }
      return;
    }

    // Compress the video once instead of multiple times
    final compressedPath = await _compressVideoOnce(pickedFilePath);

    if (compressedPath == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Video compression failed.")),
        );
      }
      return;
    }

    final fileName = p.basename(compressedPath);

    final prefs = await SharedPreferences.getInstance();
    final lastPosition = prefs.getInt('pos_$fileName') ?? 0;

    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VideoPlayerPage(
          videoPath: compressedPath,
          fileName: fileName,
          startPosition: lastPosition > 0
              ? Duration(milliseconds: lastPosition)
              : Duration.zero,
        ),
      ),
    );
  }

  @override
  void dispose() {
    VideoCompress.cancelCompression();
    VideoCompress.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Select and Play Video")),
      body: Center(
        child: _isProcessing
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  CircularProgressIndicator(),
                  SizedBox(height: 12),
                  Text("Compressing video, please wait..."),
                ],
              )
            : ElevatedButton(
                onPressed: _selectAndPlayVideo,
                child: const Text("Select Video to Play"),
              ),
      ),
    );
  }
}

class VideoPlayerPage extends StatefulWidget {
  final String videoPath;
  final String fileName;
  final Duration startPosition;

  const VideoPlayerPage({
    super.key,
    required this.videoPath,
    required this.fileName,
    required this.startPosition,
  });

  @override
  State<VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _isFullscreen = false;
  bool _showControls = true;
  Timer? _hideTimer;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(File(widget.videoPath))
      ..initialize().then((_) {
        _controller.seekTo(widget.startPosition);
        _controller.setPlaybackSpeed(1.0);
        setState(() => _isInitialized = true);
        _controller.play();
        _startHideTimer();
      });

    // Listen to video updates to update UI for progress bar
    _controller.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _savePosition();
    _controller.dispose();
    _hideTimer?.cancel();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _startHideTimer() {
    _hideTimer?.cancel();
    if (_isFullscreen) {
      _hideTimer = Timer(const Duration(seconds: 3), () {
        setState(() => _showControls = false);
      });
    }
  }

  void _toggleControls() {
    setState(() => _showControls = !_showControls);
    if (_showControls) _startHideTimer();
  }

  Future<void> _savePosition() async {
    final prefs = await SharedPreferences.getInstance();
    final pos = _controller.value.position.inMilliseconds;
    await prefs.setInt('pos_${widget.fileName}', pos);
  }

  void _toggleFullscreen() {
    if (_isFullscreen) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    } else {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    }
    setState(() {
      _isFullscreen = !_isFullscreen;
      _showControls = true;
    });
    _startHideTimer();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  /// This method seeks video 5 seconds back and plays.
  void _playLast5Seconds() {
    final currentPos = _controller.value.position;
    Duration targetPos;

    if (currentPos.inSeconds > 5) {
      targetPos = currentPos - const Duration(seconds: 5);
    } else {
      targetPos = Duration.zero;
    }

    _controller.seekTo(targetPos);
    _controller.play();
    _startHideTimer();
  }

  @override
  Widget build(BuildContext context) {
    final position = _controller.value.position;
    final duration = _controller.value.duration;

    double progress = 0;
    if (duration.inMilliseconds > 0) {
      progress = position.inMilliseconds / duration.inMilliseconds;
      if (progress > 1) progress = 1;
    }

    return Scaffold(
      appBar: _isFullscreen ? null : AppBar(title: Text(p.basename(widget.videoPath))),
      body: _isInitialized
          ? GestureDetector(
              onTap: _toggleControls,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Center(
                    child: AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: Stack(
                        children: [
                          VideoPlayer(_controller),
                          Positioned.fill(
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
                              child: Container(color: Colors.black.withOpacity(0)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (_showControls)
                    Positioned(
                      bottom: 80, // place above buttons
                      left: 20,
                      right: 20,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          LinearProgressIndicator(
                            value: progress,
                            backgroundColor: Colors.white24,
                            color: Colors.blueAccent,
                            minHeight: 4,
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _formatDuration(position),
                                style: const TextStyle(color: Colors.white),
                              ),
                              Text(
                                _formatDuration(duration),
                                style: const TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  if (_showControls)
                    Positioned(
                      bottom: 20,
                      left: 20,
                      right: 20,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          FloatingActionButton(
                            heroTag: "rewind",
                            mini: true,
                            onPressed: () {
                              final current = _controller.value.position;
                              final newPosition = current - const Duration(seconds: 10);
                              _controller.seekTo(newPosition > Duration.zero ? newPosition : Duration.zero);
                              _startHideTimer();
                            },
                            child: const Icon(Icons.replay_10),
                          ),
                          FloatingActionButton(
                            heroTag: "playpause",
                            mini: true,
                            onPressed: () {
                              setState(() {
                                if (_controller.value.isPlaying) {
                                  _controller.pause();
                                } else {
                                  _controller.play();
                                }
                              });
                              _startHideTimer();
                            },
                            child: Icon(
                              _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                            ),
                          ),
                          FloatingActionButton(
                            heroTag: "forward",
                            mini: true,
                            onPressed: () {
                              final current = _controller.value.position;
                              final duration = _controller.value.duration;
                              final newPosition = current + const Duration(seconds: 10);
                              _controller.seekTo(newPosition < duration ? newPosition : duration);
                              _startHideTimer();
                            },
                            child: const Icon(Icons.forward_10),
                          ),
                          // New 4K button with rounded square shape
                          FloatingActionButton(
                            heroTag: "4k_button",
                            mini: true,
                            onPressed: _playLast5Seconds,
                            backgroundColor: Colors.blueAccent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12), // Rounded corners
                            ),
                            child: const Text(
                              "4K",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          FloatingActionButton(
                            heroTag: "fullscreen",
                            mini: true,
                            onPressed: _toggleFullscreen,
                            child: Icon(
                              _isFullscreen ? Icons.fullscreen_exit : Icons.fullscreen,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}
