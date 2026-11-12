// tabs/tech_news.dart
//
// TikTok-style vertical video feed — tech news via YouTube Data API v3.
// Drop this file into your project and replace _kApiKey with your key.
// The widget is designed to be embedded inside a parent scroll view
// (shrinkWrap + NeverScrollableScrollPhysics) OR used as a standalone tab.
//
// Required pubspec.yaml additions:
//   http: ^1.2.0
//   url_launcher: ^6.2.5
//   cached_network_image: ^3.3.1
//   shimmer: ^3.0.0
//   intl: ^0.19.0

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart' as shimmer;
import 'package:intl/intl.dart';

// ─────────────────────────────────────────────────────────────
// CONFIG 
// ─────────────────────────────────────────────────────────────
const String _kApiKey = 'AIzaSyBBKMYsziRFugkyIGJBmKLwB6GwxSut7Fk';

// Search query 
const String _kQuery = 'Latest innovation 2026  ';

// videos to load per page
const int _kMaxResults = 10;

// ─────────────────────────────────────────────────────────────
// THEME TOKENS  
// ─────────────────────────────────────────────────────────────
class _C {
  // Background layers
  static const bg = Color(0xFF0A0A0F);          // near-black
  static const card = Color(0xFF13131A);         // lifted surface
  static const cardHover = Color(0xFF1C1C27);

  // Accent gradient — indigo to violet (matches the profile & payment screens)
  static const indigo = Color(0xFF4F46E5);
  static const violet = Color(0xFF7C3AED);
  static const indigoLight = Color(0xFF818CF8);

  // Text
  static const textPrimary = Color(0xFFF1F0FF);
  static const textSecondary = Color(0xFF9B9AB0);
  static const textMuted = Color(0xFF5C5B72);

  // Tags & chips
  static const tagBg = Color(0xFF1E1D30);
  static const tagText = Color(0xFF818CF8);

  // Live / now indicator
  static const live = Color(0xFFEF4444);

  // Divider
  static const divider = Color(0xFF1F1E2E);
}

// ─────────────────────────────────────────────────────────────
// VIDEO MODEL
// ─────────────────────────────────────────────────────────────
class _VideoItem {
  final String videoId;
  final String title;
  final String channelTitle;
  final String publishedAt;
  final String thumbnailUrl;
  final String description;

  const _VideoItem({
    required this.videoId,
    required this.title,
    required this.channelTitle,
    required this.publishedAt,
    required this.thumbnailUrl,
    required this.description,
  });

  factory _VideoItem.fromJson(Map<String, dynamic> json) {
    final snippet = json['snippet'] as Map<String, dynamic>;
    final id = json['id'];
    final videoId = id is Map ? (id['videoId'] ?? '') : id.toString();

    // Prefer maxres → high → medium → default thumbnail
    final thumbs = snippet['thumbnails'] as Map<String, dynamic>? ?? {};
    final thumb = (thumbs['maxres'] ??
            thumbs['high'] ??
            thumbs['medium'] ??
            thumbs['default'] ??
            {}) as Map<String, dynamic>;

    return _VideoItem(
      videoId: videoId,
      title: snippet['title'] ?? '',
      channelTitle: snippet['channelTitle'] ?? '',
      publishedAt: snippet['publishedAt'] ?? '',
      thumbnailUrl: thumb['url'] ?? '',
      description: snippet['description'] ?? '',
    );
  }

  String get watchUrl => 'https://www.youtube.com/watch?v=$videoId';

  /// "3 days ago", "1 month ago", etc.
  String get timeAgo {
    try {
      final dt = DateTime.parse(publishedAt);
      final diff = DateTime.now().difference(dt);
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      if (diff.inDays < 30) return '${diff.inDays}d ago';
      if (diff.inDays < 365) return '${(diff.inDays / 30).floor()}mo ago';
      return '${(diff.inDays / 365).floor()}y ago';
    } catch (_) {
      return '';
    }
  }
}

// ─────────────────────────────────────────────────────────────
// YOUTUBE SERVICE
// ─────────────────────────────────────────────────────────────
class _YouTubeService {
  String? _nextPageToken;
  bool _hasMore = true;
  bool get hasMore => _hasMore;

  Future<List<_VideoItem>> fetchVideos({bool reset = false}) async {
    if (reset) {
      _nextPageToken = null;
      _hasMore = true;
    }
    if (!_hasMore) return [];

    final uri = Uri.https('www.googleapis.com', '/youtube/v3/search', {
      'part': 'snippet',
      'q': _kQuery,
      'type': 'video',
      'maxResults': '$_kMaxResults',
      'order': 'date',
      'key': _kApiKey,
      if (_nextPageToken != null) 'pageToken': _nextPageToken!,
    });

    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception('YouTube API error ${response.statusCode}: ${response.body}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    _nextPageToken = data['nextPageToken'] as String?;
    _hasMore = _nextPageToken != null;

    final items = (data['items'] as List<dynamic>)
        .map((e) => _VideoItem.fromJson(e as Map<String, dynamic>))
        .where((v) => v.videoId.isNotEmpty && v.thumbnailUrl.isNotEmpty)
        .toList();

    return items;
  }
}

// ─────────────────────────────────────────────────────────────
// CONTROLLER / STATE
// ─────────────────────────────────────────────────────────────
class _FeedController extends ChangeNotifier {
  final _service = _YouTubeService();

  List<_VideoItem> videos = [];
  bool isLoading = false;
  bool isLoadingMore = false;
  String? error;

  Future<void> load({bool refresh = false}) async {
    if (refresh) {
      isLoading = true;
      error = null;
      videos = [];
      notifyListeners();
    }

    try {
      final fetched = await _service.fetchVideos(reset: refresh);
      videos = [...videos, ...fetched];
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      isLoadingMore = false;
      notifyListeners();
    }
  }

  Future<void> loadMore() async {
    if (isLoadingMore || !_service.hasMore) return;
    isLoadingMore = true;
    notifyListeners();
    await load();
  }
}

// ─────────────────────────────────────────────────────────────
// PUBLIC ENTRY POINT  — drop-in replacement for NewsUpdatesSection
// ─────────────────────────────────────────────────────────────
class NewsUpdatesSection extends StatefulWidget {
  /// Set [standalone] to true when this widget IS the full screen body
  /// (no parent scroll view). Set false when embedded inside another
  /// scrollable (the original use-case).
  final bool standalone;

  const NewsUpdatesSection({super.key, this.standalone = false});

  @override
  State<NewsUpdatesSection> createState() => _NewsUpdatesSectionState();
}

class _NewsUpdatesSectionState extends State<NewsUpdatesSection> {
  final _ctrl = _FeedController();
  final _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    _ctrl.load(refresh: true);
    _ctrl.addListener(() {
      if (mounted) setState(() {});
    });
    _scrollCtrl.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollCtrl.position.pixels >=
        _scrollCtrl.position.maxScrollExtent - 300) {
      _ctrl.loadMore();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_ctrl.isLoading) return _ShimmerFeed(standalone: widget.standalone);

    if (_ctrl.error != null && _ctrl.videos.isEmpty) {
      return _ErrorState(
        message: _ctrl.error!,
        onRetry: () => _ctrl.load(refresh: true),
      );
    }

    if (_ctrl.videos.isEmpty) {
      return const _EmptyState();
    }

    // When embedded, disable internal scrolling so the parent scroll owns it.
    if (!widget.standalone) {
      return Column(
        children: [
          ..._ctrl.videos.map((v) => _VideoCard(item: v)).toList(),
          if (_ctrl.isLoadingMore) const _LoadMoreIndicator(),
        ],
      );
    }

    // Standalone — full screen dark feed
    return Theme(
      data: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: _C.bg,
      ),
      child: Scaffold(
        backgroundColor: _C.bg,
        body: SafeArea(
          child: Column(
            children: [
              _FeedHeader(onRefresh: () => _ctrl.load(refresh: true)),
              Expanded(
                child: RefreshIndicator(
                  color: _C.indigo,
                  backgroundColor: _C.card,
                  onRefresh: () => _ctrl.load(refresh: true),
                  child: ListView.builder(
                    controller: _scrollCtrl,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    itemCount:
                        _ctrl.videos.length + (_ctrl.isLoadingMore ? 1 : 0),
                    itemBuilder: (ctx, i) {
                      if (i == _ctrl.videos.length) {
                        return const _LoadMoreIndicator();
                      }
                      return _VideoCard(item: _ctrl.videos[i]);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// FEED HEADER
// ─────────────────────────────────────────────────────────────
class _FeedHeader extends StatelessWidget {
  final VoidCallback onRefresh;
  const _FeedHeader({required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _C.bg,
      padding: const EdgeInsets.fromLTRB(20, 12, 16, 10),
      child: Row(
        children: [
          // Gradient title pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [_C.indigo, _C.violet],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              children: [
                Icon(Icons.play_circle_fill_rounded,
                    color: Colors.white, size: 15),
                SizedBox(width: 6),
                Text(
                  "Tech Feed",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          // Live dot
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: _C.live.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: _C.live,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 5),
                const Text(
                  "LIVE",
                  style: TextStyle(
                    color: _C.live,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onRefresh,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _C.tagBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.refresh_rounded,
                  color: _C.textSecondary, size: 18),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// VIDEO CARD  — the TikTok-style unit
// ─────────────────────────────────────────────────────────────
class _VideoCard extends StatefulWidget {
  final _VideoItem item;
  const _VideoCard({super.key, required this.item});

  @override
  State<_VideoCard> createState() => _VideoCardState();
}

class _VideoCardState extends State<_VideoCard>
    with SingleTickerProviderStateMixin {
  bool _liked = false;
  bool _bookmarked = false;
  late AnimationController _likeCtrl;
  late Animation<double> _likeScale;

  @override
  void initState() {
    super.initState();
    _likeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    _likeScale =
        CurvedAnimation(parent: _likeCtrl, curve: Curves.elasticOut);
  }

  @override
  void dispose() {
    _likeCtrl.dispose();
    super.dispose();
  }

  void _toggleLike() {
    HapticFeedback.lightImpact();
    setState(() => _liked = !_liked);
    _likeCtrl.forward(from: 0);
  }

  void _toggleBookmark() {
    HapticFeedback.lightImpact();
    setState(() => _bookmarked = !_bookmarked);
  }

  Future<void> _openVideo() async {
    final uri = Uri.parse(widget.item.watchUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;

    return GestureDetector(
      onTap: _openVideo,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: _C.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _C.divider, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── THUMBNAIL ────────────────────────
            _Thumbnail(item: item, onTap: _openVideo),

            // ── BODY ─────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Channel row
                  Row(
                    children: [
                      // Channel avatar placeholder
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [_C.indigo, _C.violet],
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            item.channelTitle.isNotEmpty
                                ? item.channelTitle[0].toUpperCase()
                                : 'Y',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          item.channelTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: _C.indigoLight,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Text(
                        item.timeAgo,
                        style: const TextStyle(
                          color: _C.textMuted,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Title
                  Text(
                    item.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: _C.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      height: 1.3,
                      letterSpacing: -0.2,
                    ),
                  ),

                  const SizedBox(height: 6),

                  // Description snippet
                  if (item.description.isNotEmpty)
                    Text(
                      item.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _C.textSecondary,
                        fontSize: 12,
                        height: 1.5,
                      ),
                    ),
                ],
              ),
            ),

            // ── ACTION ROW ───────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
              child: Row(
                children: [
                  // Like
                  _ActionBtn(
                    onTap: _toggleLike,
                    icon: _liked
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    color: _liked ? _C.live : _C.textSecondary,
                    scale: _likeScale,
                  ),
                  const SizedBox(width: 4),

                  // Bookmark
                  _ActionBtn(
                    onTap: _toggleBookmark,
                    icon: _bookmarked
                        ? Icons.bookmark_rounded
                        : Icons.bookmark_border_rounded,
                    color: _bookmarked ? _C.indigoLight : _C.textSecondary,
                  ),
                  const SizedBox(width: 4),

                  // Share
                  _ActionBtn(
                    onTap: () {},
                    icon: Icons.share_rounded,
                    color: _C.textSecondary,
                  ),

                  const Spacer(),

                  // Watch on YouTube button
                  GestureDetector(
                    onTap: _openVideo,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [_C.indigo, _C.violet],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: _C.indigo.withOpacity(0.4),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.play_arrow_rounded,
                              color: Colors.white, size: 14),
                          SizedBox(width: 4),
                          Text(
                            "Watch",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// THUMBNAIL with play overlay
// ─────────────────────────────────────────────────────────────
class _Thumbnail extends StatelessWidget {
  final _VideoItem item;
  final VoidCallback onTap;
  const _Thumbnail({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Thumbnail image
              CachedNetworkImage(
                imageUrl: item.thumbnailUrl,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(color: _C.cardHover),
                errorWidget: (_, __, ___) => Container(
                  color: _C.cardHover,
                  child: const Icon(Icons.play_circle_outline_rounded,
                      color: _C.textMuted, size: 40),
                ),
              ),

              // Gradient scrim — bottom
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.55),
                      ],
                      stops: const [0.5, 1.0],
                    ),
                  ),
                ),
              ),

              // Play button centre
              Center(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.45),
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: Colors.white.withOpacity(0.3), width: 1.5),
                  ),
                  child: const Icon(Icons.play_arrow_rounded,
                      color: Colors.white, size: 28),
                ),
              ),

              // YouTube badge — bottom right
              Positioned(
                bottom: 10,
                right: 12,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.65),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.smart_display_rounded,
                          color: Color(0xFFFF0000), size: 13),
                      SizedBox(width: 4),
                      Text(
                        "YouTube",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// ACTION BUTTON (like, bookmark, share)
// ─────────────────────────────────────────────────────────────
class _ActionBtn extends StatelessWidget {
  final VoidCallback onTap;
  final IconData icon;
  final Color color;
  final Animation<double>? scale;

  const _ActionBtn({
    required this.onTap,
    required this.icon,
    required this.color,
    this.scale,
  });

  @override
  Widget build(BuildContext context) {
    Widget iconWidget = GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: _C.tagBg,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 18),
      ),
    );

    if (scale != null) {
      iconWidget = ScaleTransition(scale: scale!, child: iconWidget);
    }

    return iconWidget;
  }
}

// ─────────────────────────────────────────────────────────────
// SHIMMER LOADING SKELETON
// ─────────────────────────────────────────────────────────────
class _ShimmerFeed extends StatelessWidget {
  final bool standalone;
  const _ShimmerFeed({required this.standalone});

  @override
  Widget build(BuildContext context) {
    final cards = List.generate(
      3,
      (_) => shimmer.Shimmer.fromColors(
        baseColor: _C.card,
        highlightColor: _C.cardHover,
        child: Container(
          margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(
            color: _C.card,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thumbnail placeholder
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Container(color: _C.cardHover),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Channel row
                    Row(
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: const BoxDecoration(
                            color: _C.cardHover,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                            width: 100, height: 12, color: _C.cardHover),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Container(
                        width: double.infinity,
                        height: 16,
                        color: _C.cardHover),
                    const SizedBox(height: 6),
                    Container(width: 200, height: 12, color: _C.cardHover),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );

    final body = Column(children: cards);

    if (!standalone) return body;

    return Theme(
      data: ThemeData.dark().copyWith(scaffoldBackgroundColor: _C.bg),
      child: Scaffold(
        backgroundColor: _C.bg,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 60, 16, 0),
            child: body,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// LOAD MORE INDICATOR
// ─────────────────────────────────────────────────────────────
class _LoadMoreIndicator extends StatelessWidget {
  const _LoadMoreIndicator();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            valueColor: AlwaysStoppedAnimation(_C.indigoLight),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// EMPTY STATE
// ─────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: _C.tagBg,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.video_library_outlined,
                color: _C.textMuted, size: 36),
          ),
          const SizedBox(height: 16),
          const Text(
            "No videos found",
            style: TextStyle(
              color: _C.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            "Try adjusting the search query in _kQuery.",
            style: TextStyle(color: _C.textSecondary, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// ERROR STATE
// ─────────────────────────────────────────────────────────────
class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    // Surface only the meaningful part of the error, not the full stack
    final short = message.length > 120 ? '${message.substring(0, 120)}…' : message;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: _C.live.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.wifi_off_rounded,
                  color: _C.live, size: 30),
            ),
            const SizedBox(height: 16),
            const Text(
              "Couldn't load feed",
              style: TextStyle(
                color: _C.textPrimary,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              short,
              textAlign: TextAlign.center,
              style: const TextStyle(color: _C.textSecondary, fontSize: 12),
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: onRetry,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [_C.indigo, _C.violet],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: _C.indigo.withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Text(
                  "Try again",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}