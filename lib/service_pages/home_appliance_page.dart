// service_pages/home_appliance_page.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../bookingscreens/appliance_repair_booking.dart';

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

  /// True when the screen is tablet-width or landscape phone.
  static bool isWide(BuildContext ctx) =>
      MediaQuery.sizeOf(ctx).width >= 600;
}

// ─────────────────────────────────────────
// DATA MODEL
// ─────────────────────────────────────────
class _ApplianceService {
  final String   name;
  final String   subtitle;
  final IconData icon;
  final int      price;
  final int      duration; // minutes
  final String   tag;

  const _ApplianceService({
    required this.name,
    required this.subtitle,
    required this.icon,
    required this.price,
    required this.duration,
    required this.tag,
  });
}

const List<_ApplianceService> _services = [
  _ApplianceService(
    name: 'Washing Machine',
    subtitle: 'Drum, motor & pump repairs',
    icon: Icons.local_laundry_service_rounded,
    price: 3500,
    duration: 90,
    tag: 'Popular',
  ),
  _ApplianceService(
    name: 'Refrigerator',
    subtitle: 'Cooling, compressor & seals',
    icon: Icons.kitchen_rounded,
    price: 4000,
    duration: 120,
    tag: 'Top Rated',
  ),
  _ApplianceService(
    name: 'Microwave',
    subtitle: 'Magnetron & panel fixes',
    icon: Icons.microwave_rounded,
    price: 2500,
    duration: 60,
    tag: '',
  ),
  _ApplianceService(
    name: 'TV Screen',
    subtitle: 'Screen, backlight & board',
    icon: Icons.tv_rounded,
    price: 6000,
    duration: 150,
    tag: 'Expert',
  ),
  _ApplianceService(
    name: 'Oven & Cooker',
    subtitle: 'Elements, igniters & thermostat',
    icon: Icons.outdoor_grill_rounded,
    price: 3800,
    duration: 75,
    tag: '',
  ),
  _ApplianceService(
    name: 'Blender & Mixer',
    subtitle: 'Motor, blade & coupler repairs',
    icon: Icons.blender_rounded,
    price: 1200,
    duration: 45,
    tag: 'Quick Fix',
  ),
  _ApplianceService(
    name: 'Iron Box',
    subtitle: 'Heating element & cord',
    icon: Icons.iron_rounded,
    price: 800,
    duration: 30,
    tag: 'Quick Fix',
  ),
  _ApplianceService(
    name: 'Fan',
    subtitle: 'Motor, blades & capacitor',
    icon: Icons.wind_power_rounded,
    price: 1000,
    duration: 45,
    tag: '',
  ),
  _ApplianceService(
    name: 'Vacuum Cleaner',
    subtitle: 'Motor, filters & suction fixes',
    icon: Icons.cleaning_services_rounded,
    price: 2200,
    duration: 60,
    tag: '',
  ),
];

// ─────────────────────────────────────────
// MAIN PAGE
// ─────────────────────────────────────────
class HomeApplianceRepairDetailsPage extends StatefulWidget {
  const HomeApplianceRepairDetailsPage({super.key});

  @override
  State<HomeApplianceRepairDetailsPage> createState() =>
      _HomeApplianceRepairDetailsPageState();
}

class _HomeApplianceRepairDetailsPageState
    extends State<HomeApplianceRepairDetailsPage>
    with TickerProviderStateMixin {

  late final AnimationController _headerController;
  late final Animation<double>   _headerFade;
  late final Animation<Offset>   _headerSlide;

  @override
  void initState() {
    super.initState();
    _headerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _headerFade = CurvedAnimation(
      parent: _headerController,
      curve: Curves.easeOut,
    );
    _headerSlide = Tween<Offset>(
      begin: const Offset(0, 0.18),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _headerController,
      curve: Curves.easeOutCubic,
    ));
    _headerController.forward();
  }

  @override
  void dispose() {
    _headerController.dispose();
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

  void _showBookSheet(BuildContext context, _ApplianceService svc) {
    showModalBottomSheet(
      context: context,
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
                  childAspectRatio: 2.8,
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
    final heroHeight  = ((screenWidth / 390.0) * 280).clamp(210.0, 340.0);

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

          // Decorative orbs – clipped to prevent overflow
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(36),
            ),
            child: SizedBox.expand(
              child: Stack(
                children: [
                  Positioned(
                    top: -40,
                    right: -30,
                    child: Container(
                      width: 160,
                      height: 160,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _kPurple.withOpacity(0.22),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 30,
                    left: -20,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _kAccentBlue.withOpacity(0.18),
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
                _R.w(context, 15).clamp(12.0, 40.0),
                _R.w(context, 30).clamp(37.0, 75.0),
                _R.w(context, 20).clamp(16.0, 40.0),
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
                          horizontal: 10, vertical: 0,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'HOME REPAIR',
                          style: GoogleFonts.poppins(
                            fontSize: _R.fs(context, 10, min: 8, max: 13),
                            fontWeight: FontWeight.w700,
                            color: Colors.white70,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                      const SizedBox(height: 3),

                      // Title
                      Text(
                        'Appliance\nRepair',
                        style: GoogleFonts.poppins(
                          fontSize: _R.fs(context, 34, min: 22, max: 46),
                          fontWeight: FontWeight.w800,
                          color: _kWhite,
                          height: 1.1,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 5
                      ),

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
// STATS ROW
// ─────────────────────────────────────────
class _StatsRow extends StatelessWidget {
  final double hPad;
  const _StatsRow({this.hPad = 20});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(hPad, 20, hPad, 0),
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
            Expanded(child: _Stat(value: '9+',    label: 'Services')),
            _StatDivider(),
            Expanded(child: _Stat(value: '4.9★',  label: 'Rating')),
            _StatDivider(),
            Expanded(child: _Stat(value: '2 hr',  label: 'Avg. Arrival')),
            _StatDivider(),
            Expanded(child: _Stat(value: '100%',  label: 'Certified')),
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
  final _ApplianceService service;
  final int               index;
  final Color             tagColor;
  final VoidCallback      onBook;

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
      duration: Duration(milliseconds: 400 + widget.index * 60),
    );
    _fade  = CurvedAnimation(parent: _ac, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.25),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ac, curve: Curves.easeOutCubic));

    Future.delayed(
      Duration(milliseconds: widget.index * 70),
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

                    // ── Icon box ──────────────────
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
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

                          // Duration chip
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
                  builder: (_) =>  ApplianceRequestServiceScreen(),
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
                        'Book a Technician',
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
  final _ApplianceService service;
  const _BookingSheet({required this.service});

  @override
  Widget build(BuildContext context) {
    final bottomInset  = MediaQuery.of(context).padding.bottom;
    final screenHeight = MediaQuery.sizeOf(context).height;

    return ConstrainedBox(
      // Never taller than 85 % of screen height
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
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(service.icon, color: _kWhite, size: 24),
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

              const SizedBox(height: 24),

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
                          value: 'Certified',
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
                      builder: (_) => ApplianceRequestServiceScreen(
                        serviceInfo: ApplianceServiceInfo(
                          name: service.name,
                          subtitle: service.subtitle,
                          price: service.price,
                          duration: service.duration,
                          tag: service.tag,
                          icon: service.icon,
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