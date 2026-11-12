// service_pages/electrical_services_page.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../bookingscreens/electrical_services_booking.dart';

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
// RESPONSIVE HELPERS
// ─────────────────────────────────────────
class _R {
  /// Scales [base] proportionally from a 390-wide reference.
  static double w(BuildContext ctx, double base) =>
      (MediaQuery.sizeOf(ctx).width / 390.0) * base;

  /// Font size clamped between [min] and [max].
  static double fs(BuildContext ctx, double ideal,
      {double min = 9, double max = 30}) =>
      w(ctx, ideal).clamp(min, max).toDouble();

  /// True when screen is tablet-width or landscape phone.
  static bool isWide(BuildContext ctx) =>
      MediaQuery.sizeOf(ctx).width >= 600;
}

// ─────────────────────────────────────────
// DATA MODEL
// ─────────────────────────────────────────
class _ElecService {
  final String   name;
  final String   subtitle;
  final IconData icon;
  final int      price;
  final int      duration; // minutes
  final String   tag;
  final bool     isHighRisk;

  const _ElecService({
    required this.name,
    required this.subtitle,
    required this.icon,
    required this.price,
    required this.duration,
    required this.tag,
    this.isHighRisk = false,
  });
}

const List<_ElecService> _services = [
  _ElecService(
    name: 'House Wiring',
    subtitle: 'Full & partial rewiring, conduit layout',
    icon: Icons.cable_rounded,
    price: 8000,
    duration: 240,
    tag: 'Popular',
    isHighRisk: true,
  ),
  _ElecService(
    name: 'Circuit Breaker Repair',
    subtitle: 'Panel inspection, breaker replacement',
    icon: Icons.electrical_services_rounded,
    price: 2500,
    duration: 90,
    tag: 'Top Rated',
    isHighRisk: true,
  ),
  _ElecService(
    name: 'Power Backup Setup',
    subtitle: 'Inverter, UPS & battery installation',
    icon: Icons.battery_charging_full_rounded,
    price: 10000,
    duration: 180,
    tag: 'Expert',
    isHighRisk: false,
  ),
  _ElecService(
    name: 'Generator Maintenance',
    subtitle: 'Servicing, fuel system & AVR checks',
    icon: Icons.settings_input_component_rounded,
    price: 4500,
    duration: 120,
    tag: 'Expert',
    isHighRisk: false,
  ),
  _ElecService(
    name: 'Electric Fence Repair',
    subtitle: 'Energiser, earthing & wire repairs',
    icon: Icons.fence_rounded,
    price: 4000,
    duration: 90,
    tag: '',
    isHighRisk: true,
  ),
  _ElecService(
    name: 'Security Light Setup',
    subtitle: 'Floodlights, motion sensors & wiring',
    icon: Icons.wb_twilight_rounded,
    price: 1500,
    duration: 60,
    tag: 'Popular',
    isHighRisk: false,
  ),
  _ElecService(
    name: 'Light Fixture Install',
    subtitle: 'Ceiling, pendant & LED strip fitting',
    icon: Icons.lightbulb_rounded,
    price: 1200,
    duration: 45,
    tag: 'Quick Fix',
    isHighRisk: false,
  ),
  _ElecService(
    name: 'Switch Installation',
    subtitle: 'Single, double & smart switch fitting',
    icon: Icons.toggle_on_rounded,
    price: 600,
    duration: 30,
    tag: 'Quick Fix',
    isHighRisk: false,
  ),
  _ElecService(
    name: 'Socket Installation',
    subtitle: 'Standard, USB & outdoor socket fitting',
    icon: Icons.power_rounded,
    price: 700,
    duration: 30,
    tag: 'Quick Fix',
    isHighRisk: false,
  ),
  _ElecService(
    name: 'Fuse Replacement',
    subtitle: 'Cartridge, blade & rewirable fuses',
    icon: Icons.bolt_rounded,
    price: 500,
    duration: 20,
    tag: 'Quick Fix',
    isHighRisk: false,
  ),
];

// ─────────────────────────────────────────
// MAIN PAGE
// ─────────────────────────────────────────
class ElectricalServicesDetailsPage extends StatefulWidget {
  const ElectricalServicesDetailsPage({super.key});

  @override
  State<ElectricalServicesDetailsPage> createState() =>
      _ElectricalServicesDetailsPageState();
}

class _ElectricalServicesDetailsPageState
    extends State<ElectricalServicesDetailsPage>
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

  void _showBookSheet(BuildContext ctx, _ElecService svc) {
    showModalBottomSheet(
      context: ctx,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _BookingSheet(service: svc),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWide = _R.isWide(context);
    final hPad   = isWide ? 32.0 : 20.0;

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

          // ── HERO ──
          SliverToBoxAdapter(
            child: _HeroHeader(
              fade: _headerFade,
              slide: _headerSlide,
            ),
          ),

          // ── SAFETY BANNER ──
          SliverToBoxAdapter(
            child: _SafetyBanner(hPad: hPad),
          ),

          // ── STATS ──
          SliverToBoxAdapter(
            child: _StatsRow(hPad: hPad),
          ),

          // ── SECTION LABEL ──
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(hPad, 24, hPad, 8),
              child: Text(
                'Available services',
                style: GoogleFonts.poppins(
                  fontSize: _R.fs(context, 16, max: 20),
                  fontWeight: FontWeight.w700,
                  color: _kDeepBlue,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ),

          // ── CARDS: 2-col grid on wide, list on phone ──
          if (isWide)
            SliverPadding(
              padding: EdgeInsets.fromLTRB(hPad, 0, hPad, 100),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: 2.5,
                ),
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
            )
          else
            SliverPadding(
              padding: EdgeInsets.fromLTRB(hPad, 0, hPad, 100),
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
    final screenWidth = MediaQuery.sizeOf(context).width;
    final heroHeight  = ((screenWidth / 390.0) * 295).clamp(220.0, 360.0);

    return Container(
      height: heroHeight,
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
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(36)),
      ),
      child: Stack(
        children: [

          // Decorative orbs – clipped so they never overflow
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(36),
            ),
            child: SizedBox.expand(
              child: Stack(
                children: [
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
                  // Lightning bolt accent
                  Positioned(
                    right: 28,
                    bottom: 52,
                    child: Opacity(
                      opacity: 0.12,
                      child: Icon(
                        Icons.bolt_rounded,
                        size: (screenWidth * 0.31).clamp(90.0, 140.0),
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content
          SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                _R.w(context, 24).clamp(16.0, 40.0),
                _R.w(context, 40).clamp(40.0, 80.0),
                _R.w(context, 24).clamp(16.0, 40.0),
                28,
              ),
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
                          horizontal: 10, vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'ELECTRICAL SERVICES',
                          style: GoogleFonts.poppins(
                            fontSize: _R.fs(context, 10, min: 8, max: 13),
                            fontWeight: FontWeight.w700,
                            color: Colors.white70,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),

                      // Title
                      Text(
                        'Electrical\nRepair & Setup',
                        style: GoogleFonts.poppins(
                          fontSize: _R.fs(context, 32, min: 22, max: 44),
                          fontWeight: FontWeight.w800,
                          color: _kWhite,
                          height: 1.1,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Subtitle
                      
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
// SAFETY BANNER
// ─────────────────────────────────────────
class _SafetyBanner extends StatelessWidget {
  final double hPad;
  const _SafetyBanner({this.hPad = 20});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(hPad, 18, hPad, 0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFED7AA), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon – fixed, never squished
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFD97706).withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.verified_user_rounded,
              color: Color(0xFFD97706),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          // Text expands to fill remaining space
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Licensed & insured technicians only',
                  style: GoogleFonts.poppins(
                    fontSize: _R.fs(context, 12, min: 10, max: 15),
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF92400E),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'All high-voltage work meets KEBS safety standards.',
                  style: GoogleFonts.poppins(
                    fontSize: _R.fs(context, 11, min: 9, max: 14),
                    color: const Color(0xFFB45309),
                    height: 1.4,
                  ),
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
  final double hPad;
  const _StatsRow({this.hPad = 20});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(hPad, 14, hPad, 0),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
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
      // IntrinsicHeight lets dividers stretch to match the tallest cell
      child: IntrinsicHeight(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: const [
            Expanded(child: _Stat(value: '10+',  label: 'Services')),
            _StatDivider(),
            Expanded(child: _Stat(value: '4.8★', label: 'Rating')),
            _StatDivider(),
            Expanded(child: _Stat(value: '3 hr', label: 'Avg. Arrival')),
            _StatDivider(),
            Expanded(child: _Stat(value: 'KEBS', label: 'Certified')),
          ],
        ),
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
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          value,
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: _R.fs(context, 16, min: 12, max: 20),
            fontWeight: FontWeight.w800,
            color: _kPurple,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: _R.fs(context, 11, min: 9, max: 13),
            color: Colors.grey[500],
            fontWeight: FontWeight.w500,
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
      Container(width: 1, color: _kCardBorder);
}

// ─────────────────────────────────────────
// SERVICE CARD
// ─────────────────────────────────────────
class _ServiceCard extends StatefulWidget {
  final _ElecService service;
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
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Icon(svc.icon, color: _kWhite, size: 24),
                        ),
                        // High-risk lightning badge
                        if (svc.isHighRisk)
                          Positioned(
                            top: -4,
                            right: -4,
                            child: Container(
                              width: 18,
                              height: 18,
                              decoration: const BoxDecoration(
                                color: Color(0xFFD97706),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.bolt_rounded,
                                size: 12,
                                color: _kWhite,
                              ),
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(width: 12),

                    // ── Text (expands) ────────────
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [

                          // Name + tag – wraps on narrow screens
                          Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 6,
                            runSpacing: 4,
                            children: [
                              Text(
                                svc.name,
                                style: GoogleFonts.poppins(
                                  fontSize: _R.fs(context, 14, min: 12, max: 17),
                                  fontWeight: FontWeight.w700,
                                  color: _kDeepBlue,
                                ),
                              ),
                              if (hasTag)
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
                                      fontSize: _R.fs(context, 9, min: 8, max: 11),
                                      fontWeight: FontWeight.w700,
                                      color: widget.tagColor,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ),
                            ],
                          ),

                          const SizedBox(height: 3),

                          Text(
                            svc.subtitle,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              fontSize: _R.fs(context, 11, min: 10, max: 13),
                              color: Colors.grey[500],
                            ),
                          ),

                          const SizedBox(height: 6),

                          // Duration + high-voltage badge – wraps on small screens
                          Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 8,
                            runSpacing: 4,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.access_time_rounded,
                                    size: 13,
                                    color: _kPurple,
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    '~${svc.duration} min',
                                    style: GoogleFonts.poppins(
                                      fontSize: _R.fs(context, 11, min: 9, max: 13),
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                ],
                              ),
                              if (svc.isHighRisk)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFF7ED),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: const Color(0xFFFED7AA),
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    'High voltage',
                                    style: GoogleFonts.poppins(
                                      fontSize: _R.fs(context, 9, min: 8, max: 11),
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFFD97706),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 10),

                    // ── Price + arrow (fixed) ─────
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'KSh',
                          style: GoogleFonts.poppins(
                            fontSize: _R.fs(context, 10, min: 9, max: 12),
                            color: Colors.grey[400],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '${svc.price}',
                          style: GoogleFonts.poppins(
                            fontSize: _R.fs(context, 17, min: 14, max: 22),
                            fontWeight: FontWeight.w800,
                            color: _kPurple,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: _kLightPurple,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 14,
                            color: _kPurple,
                          ),
                        ),
                      ],
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
    final bottomInset = MediaQuery.of(context).padding.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(20, 14, 20, bottomInset + 14),
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
      child: Row(
        children: [

          // Emergency call – fixed square
          SizedBox(
            width: 54,
            height: 54,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: _kCardBorder, width: 1.5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: IconButton(
                padding: EdgeInsets.zero,
                icon: const Icon(
                  Icons.phone_in_talk_rounded,
                  color: _kPurple,
                ),
                onPressed: () {},
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Book now – expands
          Expanded(
            child: GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>  ElectricalRequestServiceScreen(),
                ),
              ),
              child: Container(
                height: 54,
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
                      Icons.calendar_today_rounded,
                      color: _kWhite,
                      size: 18,
                    ),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Text(
                        'Book an Electrician',
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: _R.fs(context, 15, min: 13, max: 18),
                          fontWeight: FontWeight.w700,
                          color: _kWhite,
                          letterSpacing: 0.2,
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
    );
  }
}

// ─────────────────────────────────────────
// BOOKING BOTTOM SHEET
// ─────────────────────────────────────────
class _BookingSheet extends StatelessWidget {
  final _ElecService service;
  const _BookingSheet({required this.service});

  @override
  Widget build(BuildContext context) {
    final bottomInset  = MediaQuery.of(context).padding.bottom;
    final screenHeight = MediaQuery.sizeOf(context).height;

    return ConstrainedBox(
      // Never exceed 85 % of screen height
      constraints: BoxConstraints(maxHeight: screenHeight * 0.85),
      child: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.fromLTRB(24, 0, 24, bottomInset + 24),
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

              // Icon + name
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
                      if (service.isHighRisk)
                        Positioned(
                          top: -4,
                          right: -4,
                          child: Container(
                            width: 18,
                            height: 18,
                            decoration: const BoxDecoration(
                              color: Color(0xFFD97706),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.bolt_rounded,
                              size: 12,
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
                      children: [
                        Text(
                          service.name,
                          style: GoogleFonts.poppins(
                            fontSize: _R.fs(context, 17, min: 14, max: 22),
                            fontWeight: FontWeight.w800,
                            color: _kDeepBlue,
                          ),
                        ),
                        Text(
                          service.subtitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: _R.fs(context, 12, min: 10, max: 14),
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // High-voltage notice
              if (service.isHighRisk) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 10,
                  ),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF7ED),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFFED7AA)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.warning_amber_rounded,
                        color: Color(0xFFD97706),
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'This is a high-voltage service. Only licensed electricians will be assigned.',
                          style: GoogleFonts.poppins(
                            fontSize: _R.fs(context, 11, min: 10, max: 14),
                            color: const Color(0xFF92400E),
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Details row
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: _kSurface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _kCardBorder),
                ),
                child: IntrinsicHeight(
                  child: Row(
                    children: [
                      Expanded(
                        child: _SheetDetail(
                          icon: Icons.payments_rounded,
                          label: 'Starting from',
                          value: 'KSh ${service.price}',
                        ),
                      ),
                      Container(width: 1, color: _kCardBorder),
                      Expanded(
                        child: _SheetDetail(
                          icon: Icons.access_time_rounded,
                          label: 'Est. duration',
                          value: '~${service.duration} min',
                        ),
                      ),
                      Container(width: 1, color: _kCardBorder),
                      Expanded(
                        child: _SheetDetail(
                          icon: Icons.verified_rounded,
                          label: 'Technician',
                          value: 'Licensed',
                        ),
                      ),
                    ],
                  ),
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
                      builder: (_) => ElectricalRequestServiceScreen(
                        serviceInfo: ElectricalServiceInfo(
                          name: service.name,
                          subtitle: service.subtitle,
                          price: service.price,
                          duration: service.duration,
                          tag: service.tag,
                          icon: service.icon,
                          isHighRisk: service.isHighRisk,
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
                        fontSize: _R.fs(context, 15, min: 13, max: 18),
                        fontWeight: FontWeight.w700,
                        color: _kWhite,
                      ),
                    ),
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

// ─────────────────────────────────────────
// SHEET DETAIL CELL
// ─────────────────────────────────────────
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
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: _kPurple, size: 20),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: _R.fs(context, 10, min: 9, max: 12),
            color: Colors.grey[400],
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.poppins(
            fontSize: _R.fs(context, 12, min: 10, max: 15),
            fontWeight: FontWeight.w700,
            color: _kDeepBlue,
          ),
        ),
      ],
    );
  }
}