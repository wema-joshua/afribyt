// bookingscreens/CCTV_installation_booking.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../repositories/request_repository.dart';

const Color _kDeepBlue    = Color(0xFF0A1172);
const Color _kBlue        = Color(0xFF1E3A8A);
const Color _kIndigo      = Color(0xFF4F46E5);
const Color _kPurple      = Color(0xFF7C3AED);
const Color _kLightPurple = Color(0xFFEDE9FE);
const Color _kWhite       = Color(0xFFFFFFFF);
const Color _kSurface     = Color(0xFFF8F7FF);
const Color _kCardBorder  = Color(0xFFE0E7FF);
const Color _kGreen       = Color(0xFF059669);

class CctvServiceInfo {
  final String   name;
  final String   subtitle;
  final int      price;
  final int      duration;
  final String   tag;
  final IconData icon;
  final bool     siteVisitRequired;
  const CctvServiceInfo({
    required this.name, required this.subtitle,
    required this.price, required this.duration,
    this.tag = '', this.icon = Icons.videocam_rounded,
    this.siteVisitRequired = false,
  });
}

class CctvRequestServiceScreen extends StatefulWidget {
  final CctvServiceInfo? serviceInfo;
  const CctvRequestServiceScreen({super.key, this.serviceInfo});
  @override
  State<CctvRequestServiceScreen> createState() => _CctvRequestServiceScreenState();
}

class _CctvRequestServiceScreenState extends State<CctvRequestServiceScreen> {
  late DateTime _selectedDate;
  String? _selectedTime;
  final _nameCtrl  = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  bool _submitting = false;
  final _morningSlots   = ['9:00 AM', '10:00 AM', '11:00 AM', '12:00 PM'];
  final _afternoonSlots = ['1:00 PM', '2:00 PM', '3:00 PM', '4:00 PM'];
  bool _showMoreMorning = false, _showMoreAfternoon = false;
  final _morningExtra   = ['6:00 AM', '7:00 AM', '8:00 AM'];
  final _afternoonExtra = ['5:00 PM', '6:00 PM', '7:00 PM'];

  @override
  void initState() { super.initState(); _selectedDate = DateTime.now(); _selectedTime = '10:00 AM'; }
  @override
  void dispose() { _nameCtrl.dispose(); _phoneCtrl.dispose(); _emailCtrl.dispose(); _notesCtrl.dispose(); _addressCtrl.dispose(); super.dispose(); }

  List<DateTime> get _dateStrip => List.generate(6, (i) => DateTime.now().add(Duration(days: i)));
  String _mon(DateTime d) { const m = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec']; return m[d.month-1]; }
  String get _formattedBooking => _selectedTime == null ? '—' : '${_selectedDate.day} ${_mon(_selectedDate)} ${_selectedDate.year}, $_selectedTime';

  Future<void> _confirm() async {
    if (_nameCtrl.text.trim().isEmpty || _phoneCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill in your name and phone number')));
      return;
    }
    setState(() => _submitting = true);
    try {
      final payload = {
        'serviceType': widget.serviceInfo?.name ?? 'General', 'specificService': widget.serviceInfo?.name ?? '', 'amount': widget.serviceInfo?.price ?? 0,
        'deviceCategory': 'CCTV', 'serviceAddress': _addressCtrl.text.trim(),
        'time': _formattedBooking, 'description': _notesCtrl.text.trim(),
        'customerName': _nameCtrl.text.trim(), 'customerPhone': _phoneCtrl.text.trim(), 'customerEmail': _emailCtrl.text.trim(),
      };
      final result = await RequestRepository().submitBooking(payload);
      if (!mounted) return;
      if (result['success'] == true) {
        _showSuccessSheet();
      } else if (result['sessionExpired'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'Session expired — please log in again')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'Something went wrong. Please try again.')),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _showSuccessSheet() {
    final bp = MediaQuery.of(context).padding.bottom;
    showModalBottomSheet(context: context, backgroundColor: Colors.transparent, isDismissible: false,
      builder: (_) => Container(
        padding: EdgeInsets.fromLTRB(28, 0, 28, bp + 28),
        decoration: const BoxDecoration(color: _kWhite, borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(margin: const EdgeInsets.only(top: 12, bottom: 24), width: 40, height: 4,
              decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(4))),
          Container(width: 72, height: 72,
              decoration: const BoxDecoration(color: Color(0xFFD1FAE5), shape: BoxShape.circle),
              child: const Icon(Icons.check_rounded, color: _kGreen, size: 36)),
          const SizedBox(height: 20),
          Text('Booking Confirmed!', style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w800, color: _kDeepBlue)),
          const SizedBox(height: 8),
          Text('Your CCTV technician will reach out shortly\nto confirm the appointment.',
              textAlign: TextAlign.center, style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[500], height: 1.5)),
          const SizedBox(height: 28),
          GestureDetector(
            onTap: () { Navigator.pop(context); Navigator.pop(context); },
            child: Container(height: 54, width: double.infinity,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF1E3A8A), Color(0xFF4F46E5), Color(0xFF7C3AED)], begin: Alignment.centerLeft, end: Alignment.centerRight),
                borderRadius: BorderRadius.circular(16)),
              child: Center(child: Text('Back to Services', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w700, color: _kWhite)))),
          ),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final svc = widget.serviceInfo;
    final bp = MediaQuery.of(context).padding.bottom;
    return Scaffold(
      backgroundColor: _kSurface,
      body: SafeArea(child: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Book CCTV Installation', style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w800, color: _kDeepBlue)),
              Text('Fast. Reliable. Professional.', style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[500])),
            ])),
            const SizedBox(width: 12),
            GestureDetector(onTap: () => Navigator.pop(context),
              child: Container(width: 38, height: 38,
                decoration: BoxDecoration(color: _kWhite, shape: BoxShape.circle, border: Border.all(color: _kCardBorder)),
                child: Icon(Icons.close_rounded, color: Colors.grey[400], size: 18))),
          ]),
        ),
        const SizedBox(height: 16),
        Expanded(child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            if (svc != null) _CctvServiceCard(service: svc) else _GenericCctvCard(),

            // HIGH RISK BANNER
            if (svc?.siteVisitRequired == true) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: const Color(0xFFFEF2F2), borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFFECACA))),
                child: Row(children: [
                  const Icon(Icons.location_on_rounded, color: _kBlue, size: 20),
                  const SizedBox(width: 10),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Site Visit Required', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w700, color: _kBlue)),
                    Text('A site visit is needed to assess camera placement and cable routing before installation begins.',
                        style: GoogleFonts.poppins(fontSize: 11.5, color: const Color(0xFF7F1D1D), height: 1.4)),
                  ])),
                ]),
              ),
            ],

            const SizedBox(height: 20),
            _SectionHeader(number: '1', icon: Icons.location_on_rounded, label: 'Service Location'),
            const SizedBox(height: 12),
            _InputField(controller: _addressCtrl, label: 'Service Address', hint: 'Enter the address where service is needed'),
            const SizedBox(height: 24),
            _SectionHeader(number: '2', icon: Icons.calendar_month_rounded, label: 'Choose Date & Time'),
            const SizedBox(height: 12),
            _DateStrip(dates: _dateStrip, selected: _selectedDate, onSelect: (d) => setState(() => _selectedDate = d),
              onMore: () async {
                final p = await showDatePicker(context: context, initialDate: _selectedDate,
                    firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 365)),
                    builder: (ctx, child) => Theme(data: Theme.of(ctx).copyWith(colorScheme: const ColorScheme.light(primary: _kPurple, onPrimary: _kWhite)), child: child!));
                if (p != null) setState(() => _selectedDate = p);
              }),
            const SizedBox(height: 16),
            _TimeSlotSection(label: 'Morning', icon: Icons.wb_sunny_outlined, timeRange: '9:00 AM – 1:00 PM',
                slots: _showMoreMorning ? [..._morningExtra, ..._morningSlots] : _morningSlots,
                selected: _selectedTime, onSelect: (t) => setState(() => _selectedTime = t),
                onMore: () => setState(() => _showMoreMorning = !_showMoreMorning), showMore: !_showMoreMorning),
            const SizedBox(height: 12),
            _TimeSlotSection(label: 'Afternoon', icon: Icons.wb_sunny_rounded, timeRange: '1:00 PM – 6:00 PM',
                slots: _showMoreAfternoon ? [..._afternoonSlots, ..._afternoonExtra] : _afternoonSlots,
                selected: _selectedTime, onSelect: (t) => setState(() => _selectedTime = t),
                onMore: () => setState(() => _showMoreAfternoon = !_showMoreAfternoon), showMore: !_showMoreAfternoon),
            const SizedBox(height: 24),
            _SectionHeader(number: '3', icon: Icons.person_rounded, label: 'Customer Information'),
            const SizedBox(height: 12),
            LayoutBuilder(builder: (context, c) {
              if (c.maxWidth < 320) return Column(children: [
                _InputField(controller: _nameCtrl, label: 'Full Name', hint: 'Enter your full name', inputType: TextInputType.name),
                const SizedBox(height: 12),
                _InputField(controller: _phoneCtrl, label: 'Mobile Number', hint: 'Enter 10-digit mobile number', inputType: TextInputType.phone, formatters: [FilteringTextInputFormatter.digitsOnly]),
              ]);
              return Row(children: [
                Expanded(child: _InputField(controller: _nameCtrl, label: 'Full Name', hint: 'Enter your full name', inputType: TextInputType.name)),
                const SizedBox(width: 12),
                Expanded(child: _InputField(controller: _phoneCtrl, label: 'Mobile Number', hint: 'Enter 10-digit mobile number', inputType: TextInputType.phone, formatters: [FilteringTextInputFormatter.digitsOnly])),
              ]);
            }),
            const SizedBox(height: 12),
            _InputField(controller: _emailCtrl, label: 'Email (Optional)', hint: 'Enter your email address', inputType: TextInputType.emailAddress),
            const SizedBox(height: 24),
            _SectionHeader(number: '4', icon: Icons.edit_note_rounded, label: 'Additional Notes (Optional)'),
            const SizedBox(height: 12),
            _NotesField(controller: _notesCtrl),
            const SizedBox(height: 24),
            _CctvBookingSummary(service: svc, dateTime: _formattedBooking),
            const SizedBox(height: 16),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.shield_rounded, size: 14, color: _kGreen),
              const SizedBox(width: 6),
              Flexible(child: Text('Your data is secure and protected', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[500]))),
            ]),
            const SizedBox(height: 20),
          ]),
        )),
        Container(
          padding: EdgeInsets.fromLTRB(20, 14, 20, bp + 14),
          decoration: BoxDecoration(color: _kWhite, border: Border(top: BorderSide(color: _kCardBorder))),
          child: GestureDetector(
            onTap: _submitting ? null : _confirm,
            child: Container(height: 56,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF1E3A8A), Color(0xFF4F46E5), Color(0xFF7C3AED)], begin: Alignment.centerLeft, end: Alignment.centerRight),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: _kPurple.withOpacity(0.35), blurRadius: 16, offset: const Offset(0, 6))]),
              child: Center(child: _submitting
                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: _kWhite, strokeWidth: 2.5))
                : Row(mainAxisAlignment: MainAxisAlignment.center, mainAxisSize: MainAxisSize.min, children: [
                    Flexible(child: Text('Confirm Booking', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700, color: _kWhite))),
                    const SizedBox(width: 10),
                    const Icon(Icons.arrow_forward_rounded, color: _kWhite, size: 20),
                  ])),
            ),
          ),
        ),
      ])),
    );
  }
}

// ── CARDS ────────────────────────────────
class _CctvServiceCard extends StatelessWidget {
  final CctvServiceInfo service;
  const _CctvServiceCard({required this.service});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: _kWhite, borderRadius: BorderRadius.circular(20), border: Border.all(color: _kCardBorder),
          boxShadow: [BoxShadow(color: _kBlue.withOpacity(0.06), blurRadius: 16, offset: const Offset(0, 4))]),
      child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
        Container(width: 54, height: 54,
          decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF1E3A8A), Color(0xFF4F46E5), Color(0xFF7C3AED)], begin: Alignment.topLeft, end: Alignment.bottomRight), borderRadius: BorderRadius.circular(14)),
          child: Icon(service.icon, color: _kWhite, size: 24)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
          Text(service.name, style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w800, color: _kDeepBlue), maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 2),
          Text(service.subtitle, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[500]), maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 6),
          Wrap(spacing: 8, runSpacing: 4, children: [
            if (service.tag.isNotEmpty) _Badge(label: service.tag, color: const Color(0xFF3B82F6)),
            if (service.siteVisitRequired) Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.location_on_rounded, size: 13, color: _kBlue),
              const SizedBox(width: 3),
              Text('Site visit', style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: _kBlue)),
            ]),
          ]),
        ])),
        const SizedBox(width: 10),
        SizedBox(width: 72, child: Column(crossAxisAlignment: CrossAxisAlignment.end, mainAxisSize: MainAxisSize.min, children: [
          FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerRight,
              child: Text('KSh ${service.price}', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w800, color: _kPurple))),
          const SizedBox(height: 4),
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            Icon(Icons.access_time_rounded, size: 12, color: Colors.grey[400]),
            const SizedBox(width: 3),
            Flexible(child: Text('${service.duration} mins', style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey[400]), overflow: TextOverflow.ellipsis)),
          ]),
        ])),
      ]),
    );
  }
}

class _GenericCctvCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: _kWhite, borderRadius: BorderRadius.circular(20), border: Border.all(color: _kCardBorder)),
    child: Row(children: [
      Container(width: 48, height: 48, decoration: BoxDecoration(color: _kLightPurple, borderRadius: BorderRadius.circular(14)),
          child: const Icon(Icons.videocam_rounded, color: _kPurple, size: 22)),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('General CCTV Service', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w700, color: _kDeepBlue), maxLines: 1, overflow: TextOverflow.ellipsis),
        Text('Fill in details below', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[500])),
      ])),
    ]),
  );
}

class _Badge extends StatelessWidget {
  final String label; final Color color;
  const _Badge({required this.label, required this.color});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
    decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
    child: Text(label, style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w700, color: color)));
}

// ── BOOKING SUMMARY ──────────────────────
class _CctvBookingSummary extends StatelessWidget {
  final CctvServiceInfo? service;
  final String dateTime;
  const _CctvBookingSummary({required this.service, required this.dateTime});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: _kWhite, borderRadius: BorderRadius.circular(20), border: Border.all(color: _kCardBorder),
          boxShadow: [BoxShadow(color: _kBlue.withOpacity(0.05), blurRadius: 14, offset: const Offset(0, 4))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Booking Summary', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w800, color: _kDeepBlue)),
        const SizedBox(height: 14),
        LayoutBuilder(builder: (context, c) {
          if (c.maxWidth < 300) return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _Rows(service: service, dateTime: dateTime), const SizedBox(height: 14), const Divider(color: _kCardBorder), const SizedBox(height: 14), const _Badges(),
          ]);
          return IntrinsicHeight(child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(child: _Rows(service: service, dateTime: dateTime)),
            Container(width: 1, margin: const EdgeInsets.symmetric(horizontal: 12), color: _kCardBorder),
            const SizedBox(width: 110, child: _Badges()),
          ]));
        }),
      ]),
    );
  }
}

class _Rows extends StatelessWidget {
  final CctvServiceInfo? service; final String dateTime;
  const _Rows({required this.service, required this.dateTime});
  @override
  Widget build(BuildContext context) => Column(children: [
    _Row(icon: Icons.videocam_rounded, iconColor: _kPurple, label: 'Service', value: service?.name ?? 'General Request'),
    const SizedBox(height: 10),
    _Row(icon: Icons.access_time_rounded, iconColor: _kGreen, label: 'Duration', value: service != null ? '${service!.duration} mins' : '—'),
    const SizedBox(height: 10),
    _Row(icon: Icons.calendar_today_rounded, iconColor: _kIndigo, label: 'Date & Time', value: dateTime),
    const SizedBox(height: 10),
    _Row(icon: Icons.payments_rounded, iconColor: const Color(0xFFD97706), label: 'Amount', value: service != null ? 'KSh ${service!.price}' : '—'),
  ]);
}

class _Badges extends StatelessWidget {
  const _Badges();
  @override
  Widget build(BuildContext context) => const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    _TB(icon: Icons.verified_user_rounded, label: 'Professional Install', sub: 'Expert setup'),
    SizedBox(height: 10),
    _TB(icon: Icons.shield_rounded, label: 'HD Quality', sub: 'Crystal clear'),
    SizedBox(height: 10),
    _TB(icon: Icons.location_on_rounded, label: 'Remote Access', sub: 'Mobile app ready'),
    SizedBox(height: 10),
    _TB(icon: Icons.star_rounded, label: 'Expert Techs', sub: 'Certified Pros'),
  ]);
}

class _Row extends StatelessWidget {
  final IconData icon; final Color iconColor; final String label, value;
  const _Row({required this.icon, required this.iconColor, required this.label, required this.value});
  @override
  Widget build(BuildContext context) => Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Icon(icon, size: 16, color: iconColor), const SizedBox(width: 8),
    Expanded(child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[500])),
      const SizedBox(width: 8),
      Flexible(child: Text(value, textAlign: TextAlign.right, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w700, color: _kDeepBlue), maxLines: 2, overflow: TextOverflow.ellipsis)),
    ])),
  ]);
}

class _TB extends StatelessWidget {
  final IconData icon; final String label, sub;
  const _TB({required this.icon, required this.label, required this.sub});
  @override
  Widget build(BuildContext context) => Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Icon(icon, size: 16, color: _kPurple), const SizedBox(width: 6),
    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w700, color: _kDeepBlue), maxLines: 1, overflow: TextOverflow.ellipsis),
      Text(sub, style: GoogleFonts.poppins(fontSize: 9, color: Colors.grey[400])),
    ])),
  ]);
}

// ── SHARED WIDGETS ───────────────────────
class _SectionHeader extends StatelessWidget {
  final String number, label; final IconData icon;
  const _SectionHeader({required this.number, required this.icon, required this.label});
  @override
  Widget build(BuildContext context) => Row(children: [
    Container(width: 32, height: 32, decoration: BoxDecoration(color: _kLightPurple, borderRadius: BorderRadius.circular(10)), child: Icon(icon, size: 16, color: _kPurple)),
    const SizedBox(width: 10),
    Flexible(child: Text('$number.  $label', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w700, color: _kDeepBlue), maxLines: 1, overflow: TextOverflow.ellipsis)),
  ]);
}

class _InputField extends StatelessWidget {
  final TextEditingController controller; final String label, hint; final TextInputType inputType; final List<TextInputFormatter>? formatters;
  const _InputField({required this.controller, required this.label, required this.hint, this.inputType = TextInputType.text, this.formatters});
  @override
  Widget build(BuildContext context) => TextField(
    controller: controller, keyboardType: inputType, inputFormatters: formatters,
    style: GoogleFonts.poppins(fontSize: 14, color: _kDeepBlue),
    decoration: InputDecoration(labelText: label, labelStyle: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[500]),
      hintText: hint, hintStyle: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[400]),
      filled: true, fillColor: _kWhite, contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: _kCardBorder)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: _kCardBorder)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: _kIndigo, width: 2))),
  );
}

class _NotesField extends StatefulWidget {
  final TextEditingController controller;
  const _NotesField({required this.controller});
  @override State<_NotesField> createState() => _NotesFieldState();
}
class _NotesFieldState extends State<_NotesField> {
  int _count = 0;
  @override void initState() { super.initState(); widget.controller.addListener(() { if (mounted) setState(() => _count = widget.controller.text.length); }); }
  @override Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(color: _kWhite, borderRadius: BorderRadius.circular(14), border: Border.all(color: _kCardBorder)),
    child: TextField(controller: widget.controller, maxLines: 4, maxLength: 200, style: GoogleFonts.poppins(fontSize: 13, color: _kDeepBlue),
      decoration: InputDecoration(hintText: 'Any specific instructions or additional details...',
        hintStyle: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[400]), filled: true, fillColor: _kWhite,
        counterText: '$_count/200', counterStyle: GoogleFonts.poppins(fontSize: 11, color: Colors.grey[400]),
        contentPadding: const EdgeInsets.all(16), border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none))),
  );
}

class _DateStrip extends StatelessWidget {
  final List<DateTime> dates; final DateTime selected; final ValueChanged<DateTime> onSelect; final VoidCallback onMore;
  const _DateStrip({required this.dates, required this.selected, required this.onSelect, required this.onMore});
  bool _same(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;
  String _day(DateTime d) { final n = DateTime.now(); if (_same(d,n)) return 'Today'; const w=['Mon','Tue','Wed','Thu','Fri','Sat','Sun']; return w[d.weekday-1]; }
  String _mon(DateTime d) { const m=['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec']; return m[d.month-1]; }
  @override
  Widget build(BuildContext context) => Row(children: [
    ...dates.map((d) { final sel=_same(d,selected); return Expanded(child: GestureDetector(onTap: ()=>onSelect(d), child: Container(
      margin: const EdgeInsets.only(right: 5), padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(color: sel?_kIndigo:_kWhite, borderRadius: BorderRadius.circular(14),
        border: Border.all(color: sel?_kIndigo:_kCardBorder, width: sel?0:1),
        boxShadow: sel?[BoxShadow(color: _kIndigo.withOpacity(0.3), blurRadius: 10, offset: const Offset(0,4))]:[]),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        FittedBox(fit: BoxFit.scaleDown, child: Text(_day(d), style: GoogleFonts.poppins(fontSize: 9, fontWeight: FontWeight.w600, color: sel?Colors.white70:Colors.grey[500]))),
        const SizedBox(height: 4),
        FittedBox(fit: BoxFit.scaleDown, child: Text('${d.day}', style: GoogleFonts.poppins(fontSize: 17, fontWeight: FontWeight.w800, color: sel?_kWhite:_kDeepBlue))),
        const SizedBox(height: 2),
        FittedBox(fit: BoxFit.scaleDown, child: Text(_mon(d), style: GoogleFonts.poppins(fontSize: 9, color: sel?Colors.white70:Colors.grey[500]))),
      ]))));
    }),
    GestureDetector(onTap: onMore, child: Container(width: 42, height: 70,
      decoration: BoxDecoration(color: _kWhite, borderRadius: BorderRadius.circular(14), border: Border.all(color: _kCardBorder)),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text('More', style: GoogleFonts.poppins(fontSize: 9, color: Colors.grey[500], fontWeight: FontWeight.w600)),
        const SizedBox(height: 2), Icon(Icons.calendar_today_rounded, size: 16, color: Colors.grey[400]),
      ]))),
  ]);
}

class _TimeSlotSection extends StatelessWidget {
  final String label, timeRange; final IconData icon; final List<String> slots; final String? selected;
  final ValueChanged<String> onSelect; final VoidCallback onMore; final bool showMore;
  const _TimeSlotSection({required this.label, required this.icon, required this.timeRange, required this.slots, required this.selected, required this.onSelect, required this.onMore, required this.showMore});
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Row(children: [
      Icon(icon, size: 15, color: Colors.grey[500]), const SizedBox(width: 6),
      Text(label, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w700, color: _kDeepBlue)), const SizedBox(width: 6),
      Flexible(child: Text(timeRange, style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey[400]), overflow: TextOverflow.ellipsis)),
    ]),
    const SizedBox(height: 8),
    SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: [
      ...slots.map((t) { final sel=t==selected; return Padding(padding: const EdgeInsets.only(right: 8),
        child: GestureDetector(onTap: ()=>onSelect(t), child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(color: sel?_kIndigo:_kWhite, borderRadius: BorderRadius.circular(12), border: Border.all(color: sel?_kIndigo:_kCardBorder),
            boxShadow: sel?[BoxShadow(color: _kIndigo.withOpacity(0.25), blurRadius: 8, offset: const Offset(0,3))]:[]),
          child: Text(t, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: sel?_kWhite:_kDeepBlue))))); }),
      GestureDetector(onTap: onMore, child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(color: _kWhite, borderRadius: BorderRadius.circular(12), border: Border.all(color: _kCardBorder)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(showMore?Icons.access_time_rounded:Icons.keyboard_arrow_up_rounded, size: 14, color: Colors.grey[500]),
          const SizedBox(width: 4),
          Text(showMore?'More':'Less', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[500], fontWeight: FontWeight.w500)),
        ]))),
    ])),
  ]);
}