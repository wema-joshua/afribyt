// service_pages/cctv_Installation_page.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../bookingscreens/CCTV_installation_booking.dart';

// ─────────────────────────────────────────
// THEME CONSTANTS
// ─────────────────────────────────────────
const Color _kDeepBlue    = Color(0xFF0A1172);
const Color _kBlue        = Color(0xFF1E3A8A);
const Color _kAccentBlue  = Color(0xFF3B82F6);
const Color _kPurple      = Color(0xFF7C3AED);
const Color _kLightPurple = Color(0xFFEDE9FE);
const Color _kWhite       = Color(0xFFFFFFFF);
const Color _kSurface     = Color(0xFFF8F7FF);
const Color _kCardBorder  = Color(0xFFE0E7FF);

// ─────────────────────────────────────────
// DATA MODEL
// ─────────────────────────────────────────
class _CctvService {
  final String   name;
  final String   subtitle;
  final IconData icon;
  final int      price;
  final int      duration;
  final String   tag;
  final bool     siteVisitRequired;

  const _CctvService({
    required this.name,
    required this.subtitle,
    required this.icon,
    required this.price,
    required this.duration,
    required this.tag,
    this.siteVisitRequired = false,
  });
}

const List<_CctvService> _services = [
  _CctvService(
    name: 'Home CCTV Setup',
    subtitle: '2–4 cameras, DVR & remote viewing',
    icon: Icons.home_rounded,
    price: 15000,
    duration: 180,
    tag: 'Popular',
    siteVisitRequired: true,
  ),
  _CctvService(
    name: 'Business CCTV Setup',
    subtitle: '4–16 cameras, NVR & analytics',
    icon: Icons.business_rounded,
    price: 35000,
    duration: 360,
    tag: 'Top Rated',
    siteVisitRequired: true,
  ),
  _CctvService(
    name: 'IP Camera Installation',
    subtitle: 'PoE, Wi-Fi & bullet camera mounting',
    icon: Icons.camera_outdoor_rounded,
    price: 3500,
    duration: 60,
    tag: 'Popular',
    siteVisitRequired: false,
  ),
  _CctvService(
    name: 'PTZ Camera Setup',
    subtitle: 'Pan-tilt-zoom with auto-tracking',
    icon: Icons.camera_rounded,
    price: 8000,
    duration: 120,
    tag: 'Expert',
    siteVisitRequired: true,
  ),
  _CctvService(
    name: 'DVR / NVR Installation',
    subtitle: 'Hard drive setup, scheduling & alerts',
    icon: Icons.dns_rounded,
    price: 5000,
    duration: 90,
    tag: '',
    siteVisitRequired: false,
  ),
  _CctvService(
    name: 'Remote Viewing Setup',
    subtitle: 'Mobile app config & cloud access',
    icon: Icons.phone_android_rounded,
    price: 2000,
    duration: 45,
    tag: 'Quick Fix',
    siteVisitRequired: false,
  ),
  _CctvService(
    name: 'Night Vision Upgrade',
    subtitle: 'IR & colour night vision camera swap',
    icon: Icons.nightlight_round,
    price: 6000,
    duration: 90,
    tag: '',
    siteVisitRequired: false,
  ),
  _CctvService(
    name: 'Cable & Conduit Laying',
    subtitle: 'Cat6, coaxial & trunking installation',
    icon: Icons.cable_rounded,
    price: 4000,
    duration: 120,
    tag: '',
    siteVisitRequired: true,
  ),
  _CctvService(
    name: 'CCTV System Repair',
    subtitle: 'Camera, recorder & network troubleshooting',
    icon: Icons.build_circle_rounded,
    price: 2500,
    duration: 60,
    tag: 'Quick Fix',
    siteVisitRequired: false,
  ),
  _CctvService(
    name: 'System Maintenance',
    subtitle: 'Lens cleaning, firmware & health checks',
    icon: Icons.settings_rounded,
    price: 3000,
    duration: 90,
    tag: '',
    siteVisitRequired: false,
  ),
];

// ─────────────────────────────────────────
// MAIN PAGE
// ─────────────────────────────────────────
class CctvInstallationPage extends StatefulWidget {
  const CctvInstallationPage({super.key});

  @override
  State<CctvInstallationPage> createState() => _CctvInstallationPageState();
}

class _CctvInstallationPageState extends State<CctvInstallationPage>
    with TickerProviderStateMixin {

  late final AnimationController _headerCtrl;
  late final Animation<double>   _headerFade;
  late final Animation<Offset>   _headerSlide;

  @override
  void initState() {
    super.initState();
    _headerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _headerFade = CurvedAnimation(
      parent: _headerCtrl,
      curve: Curves.easeOut,
    );
    _headerSlide = Tween<Offset>(
      begin: const Offset(0, 0.18),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _headerCtrl,
      curve: Curves.easeOutCubic,
    ));
    _headerCtrl.forward();
  }

  @override
  void dispose() {
    _headerCtrl.dispose();
    super.dispose();
  }

  Color _tagColor(String tag) {
    switch (tag) {
      case 'Popular':   return _kAccentBlue;
      case 'Top Rated': return _kPurple;
      case 'Expert':    return const Color(0xFF059669);
      case 'Quick Fix': return const Color(0xFFD97706);
      default:          return Colors.transparent;
    }
  }

  void _showBookSheet(BuildContext ctx, _CctvService svc) {
    showModalBottomSheet(
      context: ctx,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _BookingSheet(service: svc),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kSurface,
      extendBodyBehindAppBar: true,

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.18),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: _kWhite,
                size: 18,
              ),
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.18),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.search_rounded,
                color: _kWhite,
                size: 20,
              ),
            ),
          ),
        ],
      ),

      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _HeroHeader(
              fade: _headerFade,
              slide: _headerSlide,
            ),
          ),

          const SliverToBoxAdapter(child: _SiteVisitBanner()),

          const SliverToBoxAdapter(child: _StatsRow()),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
              child: Text(
                'Available services',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: _kDeepBlue,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, i) => _ServiceCard(
                  service: _services[i],
                  index: i,
                  tagColor: _tagColor(_services[i].tag),
                  onBook: () => _showBookSheet(context, _services[i]),
                ),
                childCount: _services.length,
              ),
            ),
          ),
        ],
      ),

      bottomNavigationBar: _BottomBar(),
    );
  }
}

// ─────────────────────────────────────────
// HERO HEADER
// ─────────────────────────────────────────
class _HeroHeader extends StatelessWidget {
  final Animation<double> fade;
  final Animation<Offset>  slide;
  const _HeroHeader({required this.fade, required this.slide});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final headerHeight = (screenHeight * 0.34).clamp(260.0, 340.0);

    return Container(
      height: headerHeight,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF0A1172),
            Color(0xFF1E3A8A),
            Color(0xFF4F46E5),
            Color(0xFF7C3AED),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: [0.0, 0.35, 0.65, 1.0],
        ),
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(36),
        ),
      ),
      child: Stack(
        children: [
          // Decorative orbs
          Positioned(
            top: -45,
            right: -35,
            child: Container(
              width: 170,
              height: 170,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF7C3AED).withOpacity(0.22),
              ),
            ),
          ),
          Positioned(
            bottom: 25,
            left: -25,
            child: Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF3B82F6).withOpacity(0.18),
              ),
            ),
          ),

          // Camera silhouette accent
          Positioned(
            right: 24,
            bottom: 44,
            child: Opacity(
              opacity: 0.10,
              child: const Icon(
                Icons.camera_outdoor_rounded,
                size: 130,
                color: Colors.white,
              ),
            ),
          ),

          // Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 42, 24, 24),
              child: SlideTransition(
                position: slide,
                child: FadeTransition(
                  opacity: fade,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Eyebrow
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'SECURITY & SURVEILLANCE',
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Colors.white70,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Title — scales with screen width
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final titleSize = (constraints.maxWidth * 0.085)
                              .clamp(22.0, 36.0);
                          return Text(
                            'CCTV\nInstallation',
                            style: GoogleFonts.poppins(
                              fontSize: titleSize,
                              fontWeight: FontWeight.w800,
                              color: _kWhite,
                              height: 1.1,
                              letterSpacing: -0.5,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 8),

                      
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// SITE VISIT BANNER
// ─────────────────────────────────────────
class _SiteVisitBanner extends StatelessWidget {
  const _SiteVisitBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 18, 20, 0),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F3FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD8B4FE), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Icon — fixed, won't shrink
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _kPurple.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.location_on_rounded,
              color: _kPurple,
              size: 20,
            ),
          ),
          const SizedBox(width: 10),

          // Text — takes all available space
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Some services require a free site survey',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF4C1D95),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Our engineer visits first to plan the optimal camera layout.',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: _kPurple,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// STATS ROW
// ─────────────────────────────────────────
class _StatsRow extends StatelessWidget {
  const _StatsRow();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
      decoration: BoxDecoration(
        color: _kWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _kCardBorder),
        boxShadow: [
          BoxShadow(
            color: _kBlue.withOpacity(0.07),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: const [
          Expanded(child: _Stat(value: '10+',  label: 'Services')),
          _StatDivider(),
          Expanded(child: _Stat(value: '4.9★', label: 'Rating')),
          _StatDivider(),
          Expanded(child: _Stat(value: '24/7', label: 'Monitoring')),
          _StatDivider(),
          Expanded(child: _Stat(value: 'Free', label: 'Site Survey')),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String value;
  final String label;
  const _Stat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: _kPurple,
            ),
          ),
        ),
        const SizedBox(height: 2),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: Colors.grey[500],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class _StatDivider extends StatelessWidget {
  const _StatDivider();

  @override
  Widget build(BuildContext context) =>
      Container(width: 1, height: 32, color: _kCardBorder);
}

// ─────────────────────────────────────────
// SERVICE CARD
// ─────────────────────────────────────────
class _ServiceCard extends StatefulWidget {
  final _CctvService service;
  final int          index;
  final Color        tagColor;
  final VoidCallback onBook;

  const _ServiceCard({
    required this.service,
    required this.index,
    required this.tagColor,
    required this.onBook,
  });

  @override
  State<_ServiceCard> createState() => _ServiceCardState();
}

class _ServiceCardState extends State<_ServiceCard>
    with SingleTickerProviderStateMixin {

  late final AnimationController _ac;
  late final Animation<double>   _fade;
  late final Animation<Offset>   _slide;

  @override
  void initState() {
    super.initState();
    _ac = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 420 + widget.index * 55),
    );
    _fade  = CurvedAnimation(parent: _ac, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.25),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ac, curve: Curves.easeOutCubic));

    Future.delayed(
      Duration(milliseconds: widget.index * 65),
      () { if (mounted) _ac.forward(); },
    );
  }

  @override
  void dispose() {
    _ac.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final svc    = widget.service;
    final hasTag = svc.tag.isNotEmpty;

    return SlideTransition(
      position: _slide,
      child: FadeTransition(
        opacity: _fade,
        child: Container(
          margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(
            color: _kWhite,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _kCardBorder, width: 1),
            boxShadow: [
              BoxShadow(
                color: _kBlue.withOpacity(0.06),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              splashColor: _kLightPurple,
              highlightColor: _kLightPurple.withOpacity(0.4),
              onTap: widget.onBook,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [

                    // ── Icon box ─────────────────
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFF1E3A8A),
                                Color(0xFF4F46E5),
                                Color(0xFF7C3AED),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(svc.icon, color: _kWhite, size: 24),
                        ),
                        if (svc.siteVisitRequired)
                          Positioned(
                            top: -4,
                            right: -4,
                            child: Container(
                              width: 18,
                              height: 18,
                              decoration: const BoxDecoration(
                                color: _kPurple,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.location_on_rounded,
                                size: 11,
                                color: _kWhite,
                              ),
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(width: 12),

                    // ── Text — takes remaining space ──
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [

                          // Name + tag — must not overflow
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Flexible(
                                child: Text(
                                  svc.name,
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: _kDeepBlue,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (hasTag) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 7, vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: widget.tagColor.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    svc.tag,
                                    style: GoogleFonts.poppins(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w700,
                                      color: widget.tagColor,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),

                          const SizedBox(height: 3),

                          Text(
                            svc.subtitle,
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: Colors.grey[500],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),

                          const SizedBox(height: 7),

                          // Duration + site survey badge — wraps on small screens
                          Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.access_time_rounded,
                                    size: 12,
                                    color: _kPurple,
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    '~${svc.duration} min',
                                    style: GoogleFonts.poppins(
                                      fontSize: 11,
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                ],
                              ),
                              if (svc.siteVisitRequired)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _kLightPurple,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: const Color(0xFFD8B4FE),
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    'Site survey',
                                    style: GoogleFonts.poppins(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w600,
                                      color: _kPurple,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 10),

                    // ── Price + arrow — constrained width ──
                    SizedBox(
                      width: 62,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'KSh',
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              color: Colors.grey[400],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerRight,
                            child: Text(
                              '${svc.price}',
                              style: GoogleFonts.poppins(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: _kPurple,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: _kLightPurple,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 13,
                                color: _kPurple,
                              ),
                            ),
                          ),
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

// ─────────────────────────────────────────
// BOTTOM BAR
// ─────────────────────────────────────────
class _BottomBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(20, 12, 20, bottomPadding + 12),
      decoration: BoxDecoration(
        color: _kWhite,
        border: Border(top: BorderSide(color: _kCardBorder)),
        boxShadow: [
          BoxShadow(
            color: _kBlue.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Call button — fixed size
            Container(
              height: 52,
              width: 52,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                border: Border.all(color: _kCardBorder, width: 1.5),
                borderRadius: BorderRadius.circular(14),
              ),
              child: IconButton(
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.phone_in_talk_rounded, color: _kPurple, size: 22),
                onPressed: () {},
              ),
            ),

            // Book button — fills remaining width
            Expanded(
              child: GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>  CctvRequestServiceScreen(),
                  ),
                ),
                child: Container(
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF1E3A8A),
                        Color(0xFF4F46E5),
                        Color(0xFF7C3AED),
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: _kPurple.withOpacity(0.35),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.camera_outdoor_rounded,
                        color: _kWhite,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            'Book an Installer',
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: _kWhite,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ),
                      ),
                    ],
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

// ─────────────────────────────────────────
// BOOKING BOTTOM SHEET
// ─────────────────────────────────────────
class _BookingSheet extends StatelessWidget {
  final _CctvService service;
  const _BookingSheet({required this.service});

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(24, 0, 24, bottomPadding + 24),
      decoration: const BoxDecoration(
        color: _kWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [

          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 20),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(4),
            ),
          ),

          // Icon + name row
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1E3A8A), Color(0xFF7C3AED)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(service.icon, color: _kWhite, size: 24),
                  ),
                  if (service.siteVisitRequired)
                    Positioned(
                      top: -4,
                      right: -4,
                      child: Container(
                        width: 18,
                        height: 18,
                        decoration: const BoxDecoration(
                          color: _kPurple,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.location_on_rounded,
                          size: 11,
                          color: _kWhite,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      service.name,
                      style: GoogleFonts.poppins(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: _kDeepBlue,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      service.subtitle,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Site visit notice
          if (service.siteVisitRequired) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F3FF),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFD8B4FE)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 1),
                    child: Icon(
                      Icons.location_on_rounded,
                      color: _kPurple,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'A free site survey will be scheduled first to plan your camera layout.',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: const Color(0xFF4C1D95),
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Details row — each cell is Expanded so they share space equally
          Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
            decoration: BoxDecoration(
              color: _kSurface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _kCardBorder),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _SheetDetail(
                    icon: Icons.payments_rounded,
                    label: 'Starting from',
                    value: 'KSh ${service.price}',
                  ),
                ),
                Container(width: 1, height: 36, color: _kCardBorder),
                Expanded(
                  child: _SheetDetail(
                    icon: Icons.access_time_rounded,
                    label: 'Est. duration',
                    value: '~${service.duration} min',
                  ),
                ),
                Container(width: 1, height: 36, color: _kCardBorder),
                Expanded(
                  child: _SheetDetail(
                    icon: Icons.verified_rounded,
                    label: 'Survey',
                    value: 'Free',
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // CTA
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CctvRequestServiceScreen(
                    serviceInfo: CctvServiceInfo(
                      name: service.name,
                      subtitle: service.subtitle,
                      price: service.price,
                      duration: service.duration,
                      tag: service.tag,
                      icon: service.icon,
                      siteVisitRequired: service.siteVisitRequired,
                    ),
                  ),
                ),
              );
            },
            child: Container(
              height: 54,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF1E3A8A),
                    Color(0xFF4F46E5),
                    Color(0xFF7C3AED),
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: _kPurple.withOpacity(0.32),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  'Continue to Booking',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: _kWhite,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SheetDetail extends StatelessWidget {
  final IconData icon;
  final String   label;
  final String   value;
  const _SheetDetail({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: _kPurple, size: 20),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey[400]),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: _kDeepBlue,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}