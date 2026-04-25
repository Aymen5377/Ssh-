// ============================================================
//  SportZone Elite — main.dart
//  Senior Flutter Architecture | Ultra-Premium Glassmorphism
//  Target: Android APK | 60 FPS | HLS HTTP Streaming
// ============================================================
//
//  pubspec.yaml dependencies required:
//  dependencies:
//    flutter:
//      sdk: flutter
//    video_player: ^2.8.3
//    chewie: ^1.7.4
//    shimmer: ^3.0.0
//
//  ⚠️  AndroidManifest.xml REQUIRED:
//  In android/app/src/main/AndroidManifest.xml, inside <application>:
//    android:usesCleartextTraffic="true"
//
// ============================================================

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:shimmer/shimmer.dart';

// ─────────────────────────────────────────────
//  ENTRY POINT
// ─────────────────────────────────────────────
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  runApp(const SportZoneApp());
}

// ─────────────────────────────────────────────
//  COLOR PALETTE
// ─────────────────────────────────────────────
class AppColors {
  static const background   = Color(0xFF08060E); // Deep Black
  static const purple       = Color(0xFFBB86FC); // Royal Purple
  static const purpleDark   = Color(0xFF7C4DFF);
  static const purpleGlow   = Color(0x55BB86FC);
  static const white        = Color(0xFFFFFFFF);
  static const glass        = Color(0x1AFFFFFF);
  static const glassBorder  = Color(0x33FFFFFF);
  static const textSecond   = Color(0xFFB0B0C3);
  static const shimmerBase  = Color(0xFF1A1730);
  static const shimmerHigh  = Color(0xFF2D2550);
}

// ─────────────────────────────────────────────
//  CHANNEL MODEL
// ─────────────────────────────────────────────
class Channel {
  final String id;
  final String name;
  final String category;
  final String streamUrl;
  final String logoEmoji;
  final bool   isLive;

  const Channel({
    required this.id,
    required this.name,
    required this.category,
    required this.streamUrl,
    required this.logoEmoji,
    this.isLive = true,
  });
}

// Sample channels — primary uses the required HTTP stream
const List<Channel> kChannels = [
  Channel(
    id: 'ch1',
    name: 'SportZone Live',
    category: 'LIVE',
    streamUrl: 'http://103.205.17.67:8080/live/92164982129771/47825113539654/65.m3u8',
    logoEmoji: '⚽',
    isLive: true,
  ),
  Channel(
    id: 'ch2',
    name: 'Champions Arena',
    category: 'FOOTBALL',
    streamUrl: 'http://103.205.17.67:8080/live/92164982129771/47825113539654/65.m3u8',
    logoEmoji: '🏆',
  ),
  Channel(
    id: 'ch3',
    name: 'Basketball HD',
    category: 'NBA',
    streamUrl: 'http://103.205.17.67:8080/live/92164982129771/47825113539654/65.m3u8',
    logoEmoji: '🏀',
  ),
  Channel(
    id: 'ch4',
    name: 'Tennis Central',
    category: 'TENNIS',
    streamUrl: 'http://103.205.17.67:8080/live/92164982129771/47825113539654/65.m3u8',
    logoEmoji: '🎾',
  ),
  Channel(
    id: 'ch5',
    name: 'Formula Elite',
    category: 'F1',
    streamUrl: 'http://103.205.17.67:8080/live/92164982129771/47825113539654/65.m3u8',
    logoEmoji: '🏎️',
  ),
  Channel(
    id: 'ch6',
    name: 'Boxing Night',
    category: 'BOXING',
    streamUrl: 'http://103.205.17.67:8080/live/92164982129771/47825113539654/65.m3u8',
    logoEmoji: '🥊',
  ),
];

// ─────────────────────────────────────────────
//  ROOT APP
// ─────────────────────────────────────────────
class SportZoneApp extends StatelessWidget {
  const SportZoneApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SportZone Elite',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.purple,
          background: AppColors.background,
        ),
        fontFamily: 'Roboto',
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          },
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

// ─────────────────────────────────────────────
//  HOME SCREEN
// ─────────────────────────────────────────────
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  bool _isLoading = true;
  late AnimationController _logoController;
  late Animation<double> _logoAnim;

  @override
  void initState() {
    super.initState();
    _logoController = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _logoAnim = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeInOut),
    );
    // Simulate loading
    Future.delayed(const Duration(milliseconds: 1800), () {
      if (mounted) setState(() => _isLoading = false);
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Background gradient mesh
          _buildBackgroundMesh(),
          // Main content
          SafeArea(
            child: Column(
              children: [
                _buildTopBar(),
                _buildCategoryTabs(),
                Expanded(
                  child: _isLoading
                      ? _buildShimmerGrid()
                      : _buildChannelGrid(),
                ),
              ],
            ),
          ),
          // Bottom nav bar — glassmorphic
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: _buildGlassNavBar(),
          ),
        ],
      ),
    );
  }

  // ── Background gradient mesh ──────────────────
  Widget _buildBackgroundMesh() {
    return RepaintBoundary(
      child: Stack(children: [
        Container(color: AppColors.background),
        Positioned(
          top: -100, left: -80,
          child: ScaleTransition(
            scale: _logoAnim,
            child: Container(
              width: 350, height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  AppColors.purpleDark.withOpacity(0.35),
                  Colors.transparent,
                ]),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 100, right: -100,
          child: Container(
            width: 300, height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: [
                AppColors.purple.withOpacity(0.18),
                Colors.transparent,
              ]),
            ),
          ),
        ),
      ]),
    );
  }

  // ── Top bar ───────────────────────────────────
  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo
          Row(children: [
            ScaleTransition(
              scale: _logoAnim,
              child: Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.purple, AppColors.purpleDark],
                  ),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.purpleGlow,
                      blurRadius: 12, spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Icon(Icons.sports, color: Colors.white, size: 20),
              ),
            ),
            const SizedBox(width: 10),
            RichText(
              text: const TextSpan(children: [
                TextSpan(
                  text: 'beIN',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                TextSpan(
                  text: 'Connect',
                  style: TextStyle(
                    color: AppColors.purple,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
              ]),
            ),
          ]),
          // Live badge + search
          Row(children: [
            _LiveBadge(),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: () {},
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.glass,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.glassBorder, width: 1),
                    ),
                    child: const Icon(Icons.search, color: AppColors.white, size: 20),
                  ),
                ),
              ),
            ),
          ]),
        ],
      ),
    );
  }

  // ── Category tabs ─────────────────────────────
  final List<String> _categories = ['ALL', 'LIVE', 'FOOTBALL', 'NBA', 'TENNIS', 'F1', 'BOXING'];

  Widget _buildCategoryTabs() {
    return SizedBox(
      height: 44,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categories.length,
        itemBuilder: (ctx, i) {
          final selected = i == _selectedIndex;
          return GestureDetector(
            onTap: () => setState(() => _selectedIndex = i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                gradient: selected
                    ? const LinearGradient(
                        colors: [AppColors.purple, AppColors.purpleDark],
                      )
                    : null,
                color: selected ? null : AppColors.glass,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: selected ? AppColors.purple : AppColors.glassBorder,
                  width: 1,
                ),
                boxShadow: selected
                    ? [BoxShadow(color: AppColors.purpleGlow, blurRadius: 10)]
                    : null,
              ),
              child: Text(
                _categories[i],
                style: TextStyle(
                  color: selected ? AppColors.white : AppColors.textSecond,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Channel grid ──────────────────────────────
  List<Channel> get _filteredChannels {
    if (_selectedIndex == 0) return kChannels;
    final cat = _categories[_selectedIndex];
    return kChannels.where((c) => c.category == cat).toList();
  }

  Widget _buildChannelGrid() {
    final channels = _filteredChannels;
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.82,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
      ),
      itemCount: channels.length,
      itemBuilder: (ctx, i) {
        return RepaintBoundary(
          child: _ChannelCard(
            channel: channels[i],
            index: i,
            onTap: () => _openPlayer(channels[i]),
          ),
        );
      },
    );
  }

  // ── Shimmer loading grid ──────────────────────
  Widget _buildShimmerGrid() {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, childAspectRatio: 0.82,
        crossAxisSpacing: 14, mainAxisSpacing: 14,
      ),
      itemCount: 6,
      itemBuilder: (ctx, i) => Shimmer.fromColors(
        baseColor: AppColors.shimmerBase,
        highlightColor: AppColors.shimmerHigh,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.shimmerBase,
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }

  // ── Glass nav bar ─────────────────────────────
  Widget _buildGlassNavBar() {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          decoration: const BoxDecoration(
            color: Color(0x1A0D0D1A),
            border: Border(top: BorderSide(color: AppColors.glassBorder, width: 1)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(icon: Icons.home_rounded,   label: 'Home',    active: true),
              _NavItem(icon: Icons.live_tv_rounded, label: 'Live',   active: false),
              _NavItem(icon: Icons.star_rounded,    label: 'Favs',   active: false),
              _NavItem(icon: Icons.person_rounded,  label: 'Profile',active: false),
            ],
          ),
        ),
      ),
    );
  }

  // ── Navigate to player ────────────────────────
  void _openPlayer(Channel channel) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, animation, __) => PlayerScreen(channel: channel),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(
            opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  CHANNEL CARD
// ─────────────────────────────────────────────
class _ChannelCard extends StatefulWidget {
  final Channel channel;
  final int     index;
  final VoidCallback onTap;

  const _ChannelCard({required this.channel, required this.index, required this.onTap});

  @override
  State<_ChannelCard> createState() => _ChannelCardState();
}

class _ChannelCardState extends State<_ChannelCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double>   _scale;

  @override
  void initState() {
    super.initState();
    _ctrl  = AnimationController(vsync: this, duration: const Duration(milliseconds: 140));
    _scale = Tween<double>(begin: 1.0, end: 0.94).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown:   (_) => _ctrl.forward(),
      onTapUp:     (_) { _ctrl.reverse(); widget.onTap(); },
      onTapCancel: ()  => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Hero(
          tag: 'channel_${widget.channel.id}',
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.glass,
                      AppColors.purpleDark.withOpacity(0.08),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.glassBorder, width: 1),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Emoji logo in glowing circle
                    Container(
                      width: 72, height: 72,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(colors: [
                          AppColors.purpleDark.withOpacity(0.5),
                          AppColors.purpleGlow.withOpacity(0.1),
                        ]),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.purpleGlow,
                            blurRadius: 20, spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          widget.channel.logoEmoji,
                          style: const TextStyle(fontSize: 32),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    // Channel name
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        widget.channel.name,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Live pill badge
                    if (widget.channel.isLive)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFF4E50), Color(0xFFF9D423)],
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.circle, color: Colors.white, size: 6),
                            SizedBox(width: 4),
                            Text('LIVE', style: TextStyle(
                              color: Colors.white, fontSize: 10,
                              fontWeight: FontWeight.w800, letterSpacing: 1,
                            )),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  LIVE BADGE
// ─────────────────────────────────────────────
class _LiveBadge extends StatefulWidget {
  @override
  State<_LiveBadge> createState() => _LiveBadgeState();
}

class _LiveBadgeState extends State<_LiveBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double>   _pulse;

  @override
  void initState() {
    super.initState();
    _ctrl  = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.4, end: 1.0).animate(_ctrl);
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0x33FF4E50),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0x55FF4E50), width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              FadeTransition(
                opacity: _pulse,
                child: const Icon(Icons.circle, color: Color(0xFFFF4E50), size: 7),
              ),
              const SizedBox(width: 5),
              const Text('LIVE', style: TextStyle(
                color: Color(0xFFFF4E50), fontSize: 11,
                fontWeight: FontWeight.w800, letterSpacing: 1,
              )),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  NAV ITEM
// ─────────────────────────────────────────────
class _NavItem extends StatelessWidget {
  final IconData icon;
  final String   label;
  final bool     active;
  const _NavItem({required this.icon, required this.label, required this.active});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon,
            color: active ? AppColors.purple : AppColors.textSecond,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(
            color: active ? AppColors.purple : AppColors.textSecond,
            fontSize: 10, fontWeight: FontWeight.w600,
          )),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  PLAYER SCREEN
// ─────────────────────────────────────────────
class PlayerScreen extends StatefulWidget {
  final Channel channel;
  const PlayerScreen({super.key, required this.channel});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen>
    with TickerProviderStateMixin {
  // Video controllers
  late VideoPlayerController _videoController;
  ChewieController?          _chewieController;

  // UI state
  bool _isInitialized = false;
  bool _hasError      = false;
  bool _showControls  = true;
  bool _isFullscreen  = false;
  bool _isPlaying     = false;

  // Seek flash state
  bool _showLeftSeek  = false;
  bool _showRightSeek = false;

  // Animation controllers
  late AnimationController _playPauseCtrl;
  late AnimationController _controlsCtrl;
  late AnimationController _seekCtrl;

  late Animation<double> _playPauseScale;
  late Animation<double> _controlsOpacity;

  @override
  void initState() {
    super.initState();

    // Animation setup
    _playPauseCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 200));
    _playPauseScale = Tween<double>(begin: 1.0, end: 0.85).animate(
      CurvedAnimation(parent: _playPauseCtrl, curve: Curves.easeOut),
    );

    _controlsCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _controlsOpacity = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _controlsCtrl, curve: Curves.easeOut),
    );

    _seekCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600))
      ..addStatusListener((s) {
        if (s == AnimationStatus.completed) {
          setState(() { _showLeftSeek = false; _showRightSeek = false; });
          _seekCtrl.reset();
        }
      });

    _initVideo();
  }

  // ── Init video ────────────────────────────────
  Future<void> _initVideo() async {
    try {
      _videoController = VideoPlayerController.networkUrl(
        Uri.parse(widget.channel.streamUrl),
        httpHeaders: {'User-Agent': 'SportZoneElite/1.0'},
        videoPlayerOptions: VideoPlayerOptions(mixWithOthers: false),
      );

      await _videoController.initialize();

      _chewieController = ChewieController(
        videoPlayerController: _videoController,
        autoPlay: true,
        looping: true,
        allowFullScreen: false,     // We handle fullscreen ourselves
        showControls: false,        // We use our own custom controls
        aspectRatio: _videoController.value.aspectRatio,
        errorBuilder: (ctx, msg) => _buildErrorWidget(msg),
      );

      _videoController.addListener(_videoListener);

      if (mounted) {
        setState(() {
          _isInitialized = true;
          _isPlaying     = true;
        });
        _scheduleHideControls();
      }
    } catch (e) {
      if (mounted) setState(() => _hasError = true);
    }
  }

  void _videoListener() {
    if (mounted) {
      final playing = _videoController.value.isPlaying;
      if (playing != _isPlaying) setState(() => _isPlaying = playing);
    }
  }

  @override
  void dispose() {
    _videoController.removeListener(_videoListener);
    _videoController.dispose();
    _chewieController?.dispose();
    _playPauseCtrl.dispose();
    _controlsCtrl.dispose();
    _seekCtrl.dispose();
    super.dispose();
  }

  // ── Controls visibility ───────────────────────
  void _scheduleHideControls() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && _isPlaying) _hideControls();
    });
  }

  void _hideControls() {
    _controlsCtrl.forward();
    setState(() => _showControls = false);
  }

  void _toggleControls() {
    if (_showControls) {
      _hideControls();
    } else {
      _controlsCtrl.reverse();
      setState(() => _showControls = true);
      _scheduleHideControls();
    }
  }

  // ── Play / pause ──────────────────────────────
  void _togglePlayPause() {
    _playPauseCtrl.forward().then((_) => _playPauseCtrl.reverse());
    if (_isPlaying) {
      _videoController.pause();
    } else {
      _videoController.play();
      _scheduleHideControls();
    }
  }

  // ── Double tap seek ───────────────────────────
  void _seekForward() {
    final pos    = _videoController.value.position;
    final dur    = _videoController.value.duration;
    final newPos = pos + const Duration(seconds: 10);
    _videoController.seekTo(newPos > dur ? dur : newPos);
    setState(() => _showRightSeek = true);
    _seekCtrl.forward(from: 0);
  }

  void _seekBackward() {
    final pos    = _videoController.value.position;
    final newPos = pos - const Duration(seconds: 10);
    _videoController.seekTo(newPos < Duration.zero ? Duration.zero : newPos);
    setState(() => _showLeftSeek = true);
    _seekCtrl.forward(from: 0);
  }

  // ── Fullscreen toggle ─────────────────────────
  void _toggleFullscreen() {
    setState(() => _isFullscreen = !_isFullscreen);
    if (_isFullscreen) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    } else {
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
  }

  // ── Format duration ───────────────────────────
  String _formatDuration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return h > 0 ? '$h:$m:$s' : '$m:$s';
  }

  // ─────────────────────────────────────────────
  //  BUILD
  // ─────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Player area
            RepaintBoundary(child: _buildPlayerArea()),
            // Info + channel list below (portrait only)
            if (!_isFullscreen) Expanded(child: _buildInfoPanel()),
          ],
        ),
      ),
    );
  }

  // ── Player area ───────────────────────────────
  Widget _buildPlayerArea() {
    return Hero(
      tag: 'channel_${widget.channel.id}',
      child: AspectRatio(
        aspectRatio: _isFullscreen ? (MediaQuery.of(context).size.aspectRatio) : 16 / 9,
        child: Stack(
          children: [
            // Video or loading/error
            _buildVideoContent(),
            // Double-tap seek zones
            _buildSeekZones(),
            // Custom controls overlay
            if (_isInitialized) _buildControlsOverlay(),
            // Seek flash indicators
            if (_showLeftSeek)  _buildSeekFlash(left: true),
            if (_showRightSeek) _buildSeekFlash(left: false),
          ],
        ),
      ),
    );
  }

  // ── Video content ─────────────────────────────
  Widget _buildVideoContent() {
    if (_hasError)       return _buildErrorWidget('Stream unavailable');
    if (!_isInitialized) return _buildLoadingWidget();
    return Chewie(controller: _chewieController!);
  }

  Widget _buildLoadingWidget() {
    return Container(
      color: Colors.black,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Shimmer.fromColors(
            baseColor: AppColors.shimmerBase,
            highlightColor: AppColors.purple,
            child: Container(
              width: 80, height: 80,
              decoration: const BoxDecoration(
                color: AppColors.shimmerBase, shape: BoxShape.circle,
              ),
              child: const Icon(Icons.sports, color: Colors.transparent, size: 40),
            ),
          ),
          const SizedBox(height: 20),
          const Text('Loading stream...', style: TextStyle(
            color: AppColors.textSecond, fontSize: 14, fontWeight: FontWeight.w500,
          )),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(String msg) {
    return Container(
      color: Colors.black,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.wifi_off_rounded, color: AppColors.purple, size: 52),
          const SizedBox(height: 16),
          const Text('Stream Unavailable', style: TextStyle(
            color: AppColors.white, fontSize: 16, fontWeight: FontWeight.w700,
          )),
          const SizedBox(height: 8),
          Text(msg, style: const TextStyle(
            color: AppColors.textSecond, fontSize: 12,
          )),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: () { setState(() { _hasError = false; _isInitialized = false; }); _initVideo(); },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [AppColors.purple, AppColors.purpleDark]),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [BoxShadow(color: AppColors.purpleGlow, blurRadius: 16)],
              ),
              child: const Text('Retry', style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.w700,
              )),
            ),
          ),
        ],
      ),
    );
  }

  // ── Seek zones (double-tap) ───────────────────
  Widget _buildSeekZones() {
    return Row(
      children: [
        Expanded(child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onDoubleTap: _seekBackward,
          onTap: _toggleControls,
        )),
        Expanded(child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onDoubleTap: _seekForward,
          onTap: _toggleControls,
        )),
      ],
    );
  }

  // ── Seek flash ────────────────────────────────
  Widget _buildSeekFlash({required bool left}) {
    return Positioned(
      left:  left  ? 0   : null,
      right: !left ? 0   : null,
      top: 0, bottom: 0,
      child: FadeTransition(
        opacity: Tween<double>(begin: 1.0, end: 0.0).animate(
          CurvedAnimation(parent: _seekCtrl, curve: Curves.easeOut),
        ),
        child: Container(
          width: 100,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: left ? Alignment.centerLeft : Alignment.centerRight,
              end:   left ? Alignment.centerRight : Alignment.centerLeft,
              colors: [AppColors.purpleGlow, Colors.transparent],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                left ? Icons.fast_rewind_rounded : Icons.fast_forward_rounded,
                color: Colors.white, size: 32,
              ),
              const SizedBox(height: 4),
              Text(
                left ? '-10s' : '+10s',
                style: const TextStyle(
                  color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Controls overlay ──────────────────────────
  Widget _buildControlsOverlay() {
    return FadeTransition(
      opacity: _controlsOpacity.drive(Tween<double>(begin: 1.0, end: 0.0)),
      child: Stack(
        children: [
          // Gradient scrim
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xCC000000), Colors.transparent, Color(0xCC000000)],
                stops: [0, 0.4, 1],
              ),
            ),
          ),
          // Top bar
          Positioned(
            top: 0, left: 0, right: 0,
            child: _buildControlsTopBar(),
          ),
          // Center play/pause
          Center(child: _buildPlayPauseButton()),
          // Bottom seek bar
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: _buildSeekBar(),
          ),
        ],
      ),
    );
  }

  Widget _buildControlsTopBar() {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 12),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter, end: Alignment.bottomCenter,
              colors: [Color(0x99000000), Colors.transparent],
            ),
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white, size: 20),
                onPressed: () {
                  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
                  Navigator.pop(context);
                },
              ),
              Expanded(
                child: Text(
                  widget.channel.name,
                  style: const TextStyle(
                    color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: Icon(
                  _isFullscreen ? Icons.fullscreen_exit_rounded : Icons.fullscreen_rounded,
                  color: Colors.white, size: 24,
                ),
                onPressed: _toggleFullscreen,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlayPauseButton() {
    return ScaleTransition(
      scale: _playPauseScale,
      child: GestureDetector(
        onTap: _togglePlayPause,
        child: Container(
          width: 64, height: 64,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [AppColors.purple, AppColors.purpleDark],
            ),
            boxShadow: [
              BoxShadow(color: AppColors.purpleGlow, blurRadius: 24, spreadRadius: 4),
            ],
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Icon(
              _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
              key: ValueKey(_isPlaying),
              color: Colors.white, size: 36,
            ),
          ),
        ),
      ),
    );
  }

  // ── Custom Seek Bar ───────────────────────────
  Widget _buildSeekBar() {
    return ValueListenableBuilder<VideoPlayerValue>(
      valueListenable: _videoController,
      builder: (ctx, value, _) {
        final position = value.position;
        final duration = value.duration;
        final progress = duration.inMilliseconds > 0
            ? (position.inMilliseconds / duration.inMilliseconds).clamp(0.0, 1.0)
            : 0.0;

        return ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter, end: Alignment.topCenter,
                  colors: [Color(0x99000000), Colors.transparent],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Time row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_formatDuration(position),
                        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
                      if (widget.channel.isLive)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xCCFF4E50),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text('● LIVE', style: TextStyle(
                            color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800,
                          )),
                        )
                      else
                        Text(_formatDuration(duration),
                          style: const TextStyle(color: Colors.white70, fontSize: 11)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Glowing seek slider
                  SliderTheme(
                    data: SliderThemeData(
                      trackHeight: 3,
                      thumbShape: _GlowingThumbShape(),
                      overlayShape: SliderComponentShape.noOverlay,
                      activeTrackColor: AppColors.purple,
                      inactiveTrackColor: Colors.white24,
                      thumbColor: AppColors.purple,
                    ),
                    child: Slider(
                      value: progress,
                      onChanged: (v) {
                        final ms = (v * duration.inMilliseconds).toInt();
                        _videoController.seekTo(Duration(milliseconds: ms));
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ── Info panel ────────────────────────────────
  Widget _buildInfoPanel() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter, end: Alignment.bottomCenter,
          colors: [AppColors.background, Color(0xFF0D0A1A)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Channel info
          Padding(
            padding: const EdgeInsets.all(16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.glass,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.glassBorder),
                  ),
                  child: Row(children: [
                    Text(widget.channel.logoEmoji, style: const TextStyle(fontSize: 36)),
                    const SizedBox(width: 14),
                    Expanded(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.channel.name, style: const TextStyle(
                          color: AppColors.white, fontSize: 16, fontWeight: FontWeight.w800,
                        )),
                        const SizedBox(height: 4),
                        Text(widget.channel.category, style: const TextStyle(
                          color: AppColors.purple, fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 1,
                        )),
                      ],
                    )),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [AppColors.purple, AppColors.purpleDark]),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [BoxShadow(color: AppColors.purpleGlow, blurRadius: 12)],
                      ),
                      child: const Icon(Icons.cast, color: Colors.white, size: 20),
                    ),
                  ]),
                ),
              ),
            ),
          ),
          // More channels label
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text('MORE CHANNELS', style: TextStyle(
              color: AppColors.textSecond, fontSize: 11,
              fontWeight: FontWeight.w800, letterSpacing: 1.5,
            )),
          ),
          const SizedBox(height: 8),
          // Horizontal channel list
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.vertical,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: kChannels.where((c) => c.id != widget.channel.id).length,
              itemBuilder: (ctx, i) {
                final others = kChannels.where((c) => c.id != widget.channel.id).toList();
                final ch = others[i];
                return GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (_, a, __) => PlayerScreen(channel: ch),
                        transitionsBuilder: (_, a, __, child) =>
                            FadeTransition(opacity: a, child: child),
                        transitionDuration: const Duration(milliseconds: 300),
                      ),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.glass,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.glassBorder),
                    ),
                    child: Row(children: [
                      Text(ch.logoEmoji, style: const TextStyle(fontSize: 24)),
                      const SizedBox(width: 12),
                      Expanded(child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(ch.name, style: const TextStyle(
                            color: AppColors.white, fontSize: 13, fontWeight: FontWeight.w700,
                          )),
                          Text(ch.category, style: const TextStyle(
                            color: AppColors.purple, fontSize: 11,
                          )),
                        ],
                      )),
                      if (ch.isLive)
                        const Icon(Icons.circle, color: Color(0xFFFF4E50), size: 8),
                    ]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  CUSTOM GLOWING THUMB FOR SEEK BAR
// ─────────────────────────────────────────────
class _GlowingThumbShape extends SliderComponentShape {
  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) => const Size(16, 16);

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final canvas = context.canvas;

    // Glow
    canvas.drawCircle(
      center, 12,
      Paint()
        ..color = AppColors.purpleGlow
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );
    // White inner
    canvas.drawCircle(center, 7, Paint()..color = Colors.white);
    // Purple ring
    canvas.drawCircle(
      center, 7,
      Paint()
        ..color = AppColors.purple
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }
}
