// tabs/payment.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'package:google_fonts/google_fonts.dart';
// ─────────────────────────────────────────────────────────────
// THEME TOKENS
// ─────────────────────────────────────────────────────────────
class PayColors {
  // Core palette
  static const Color indigo = Color(0xFF4F46E5);
  static const Color indigoDark = Color(0xFF3730A3);
  static const Color violet = Color(0xFF7C3AED);
  static const Color violetLight = Color(0xFFA78BFA);
  static const Color surface = Color(0xFFF5F4FF);
  static const Color cardBg = Colors.white;

  // Text
  static const Color textPrimary = Color(0xFF1E1B4B);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textMuted = Color(0xFF9CA3AF);

  // Borders
  static const Color border = Color(0xFFE5E7EB);
  static const Color borderFocus = Color(0xFF4F46E5);

  // Method-specific accents
  static const Color mpesaGreen = Color(0xFF059669);
  static const Color mpesaGreenDark = Color(0xFF065F46);
  static const Color paypalBlue = Color(0xFF003087);
  static const Color paypalGold = Color(0xFFFFC439);
  static const Color cryptoCyan = Color(0xFF06B6D4);
  static const Color cryptoPurple = Color(0xFF8B5CF6);
}

// ─────────────────────────────────────────────────────────────
// ENTRY POINT
// ─────────────────────────────────────────────────────────────
void main() => runApp(const PaymentApp());

class PaymentApp extends StatelessWidget {
  const PaymentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Techlink Repair Payment",
      theme: ThemeData(
        scaffoldBackgroundColor: PayColors.surface,
        fontFamily: 'SF Pro Display',
      ),
      home: const PaymentScreen(),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// PAYMENT METHOD ENUM
// ─────────────────────────────────────────────────────────────
enum PaymentMethod { mpesa, card, paypal, crypto }

// ─────────────────────────────────────────────────────────────
// PAYMENT SCREEN
// ─────────────────────────────────────────────────────────────
class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen>
    with SingleTickerProviderStateMixin {
  final double amount = 4500.00;
  bool _isProcessing = false;
  bool _isSuccess = false;

  late AnimationController _successCtrl;
  late Animation<double> _successScale;

  @override
  void initState() {
    super.initState();
    _successCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _successScale = CurvedAnimation(
        parent: _successCtrl, curve: Curves.elasticOut);
  }

  @override
  void dispose() {
    _successCtrl.dispose();
    super.dispose();
  }

  void _onPaymentStarted() {
    setState(() {
      _isProcessing = true;
      _isSuccess = false;
    });
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      setState(() {
        _isProcessing = false;
        _isSuccess = true;
      });
      _successCtrl.forward(from: 0);
      HapticFeedback.heavyImpact();
    });
  }

  void _handleMethodSelect(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.mpesa:
        _showSheet(MpesaSheet(amount: amount, onPay: _onPaymentStarted));
        break;
      case PaymentMethod.card:
        _showSheet(CardSheet(amount: amount, onPay: _onPaymentStarted));
        break;
      case PaymentMethod.paypal:
        _showSheet(PayPalSheet(amount: amount, onPay: _onPaymentStarted));
        break;
      case PaymentMethod.crypto:
        _showSheet(CryptoSheet(onConnect: _onPaymentStarted));
        break;
    }
  }

  void _showSheet(Widget child) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PayColors.surface,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ── HEADER ──────────────────────────────
            SliverToBoxAdapter(
              child: _PaymentHeader(amount: amount),
            ),

            // ── CONTENT ─────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const SizedBox(height: 24),

                  // Order summary card
                  _OrderCard(amount: amount),

                  const SizedBox(height: 28),

                  // Section label
                  const _SectionLabel(text: "Choose payment method"),
                  const SizedBox(height: 14),

                  // Method tiles
                  _MethodTile(
                    label: "M-Pesa",
                    subtitle: "Pay via mobile money",
                    icon: Icons.phone_android_rounded,
                    accentColor: PayColors.mpesaGreen,
                    bgColor: const Color(0xFFECFDF5),
                    method: PaymentMethod.mpesa,
                    onSelect: _handleMethodSelect,
                  ),
                  _MethodTile(
                    label: "Debit / Credit Card",
                    subtitle: "Visa, Mastercard, Amex",
                    icon: Icons.credit_card_rounded,
                    accentColor: PayColors.indigo,
                    bgColor: const Color(0xFFEEF2FF),
                    method: PaymentMethod.card,
                    onSelect: _handleMethodSelect,
                  ),
                  _MethodTile(
                    label: "PayPal",
                    subtitle: "Fast & secure checkout",
                    icon: Icons.account_balance_wallet_rounded,
                    accentColor: PayColors.paypalBlue,
                    bgColor: const Color(0xFFEFF6FF),
                    method: PaymentMethod.paypal,
                    onSelect: _handleMethodSelect,
                  ),
                  _MethodTile(
                    label: "Crypto Wallet",
                    subtitle: "MetaMask, Trust, Coinbase",
                    icon: Icons.token_rounded,
                    accentColor: PayColors.cryptoCyan,
                    bgColor: const Color(0xFFECFEFF),
                    method: PaymentMethod.crypto,
                    onSelect: _handleMethodSelect,
                    isLast: true,
                  ),

                  const SizedBox(height: 28),

                  // ── STATUS ──────────────────────
                  if (_isProcessing) const _ProcessingCard(),
                  if (_isSuccess)
                    ScaleTransition(
                      scale: _successScale,
                      child: const _SuccessCard(),
                    ),

                  // ── SECURITY FOOTER ─────────────
                  if (!_isProcessing && !_isSuccess)
                    const _SecurityFooter(),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// PAYMENT HEADER
// ─────────────────────────────────────────────────────────────
class _PaymentHeader extends StatelessWidget {
  final double amount;
  const _PaymentHeader({required this.amount});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [PayColors.indigoDark, PayColors.violet],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nav row
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.maybePop(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.lock_outline_rounded,
                        color: Colors.white, size: 13),
                    SizedBox(width: 5),
                    Text(
                      "Secure",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),

          // Amount display
          Text(
            "Repair total",
            style: TextStyle(
              color: Colors.white.withOpacity(0.65),
              fontSize: 13,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  "KES",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'poppins',
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                amount.toStringAsFixed(2),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 44,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1.5,
                  height: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            "Repair Service·",
            style: TextStyle(
              color: Colors.white.withOpacity(0.55),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// ORDER CARD
// ─────────────────────────────────────────────────────────────
class _OrderCard extends StatelessWidget {
  final double amount;
  const _OrderCard({required this.amount});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: PayColors.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: PayColors.border),
        boxShadow: [
          BoxShadow(
            color: PayColors.indigo.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.build_circle_outlined,
                    color: PayColors.indigo, size: 18),
              ),
              const SizedBox(width: 10),
              const Text(
                "Repair Invoice",
                style: TextStyle(
                  color: PayColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: PayColors.border, height: 1),
          const SizedBox(height: 14),
          _orderRow("Screen Replacement", "KES 3,200"),
          const SizedBox(height: 8),
          _orderRow("Labour & Diagnostics", "KES 800"),
          const SizedBox(height: 8),
          _orderRow("Spare Parts (Battery)", "KES 500"),
          const SizedBox(height: 12),
          const Divider(color: PayColors.border, height: 1),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Total",
                style: TextStyle(
                  color: PayColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                "KES ${amount.toStringAsFixed(2)}",
                style: const TextStyle(
                  color: PayColors.indigo,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _orderRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(
                color: PayColors.textSecondary, fontSize: 13)),
        Text(value,
            style: const TextStyle(
                color: PayColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w600)),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// SECTION LABEL
// ─────────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 14,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [PayColors.indigo, PayColors.violet],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          text.toUpperCase(),
          style: const TextStyle(
            color: PayColors.textSecondary,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// METHOD TILE
// ─────────────────────────────────────────────────────────────
class _MethodTile extends StatelessWidget {
  final String label;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
  final Color bgColor;
  final PaymentMethod method;
  final Function(PaymentMethod) onSelect;
  final bool isLast;

  const _MethodTile({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
    required this.bgColor,
    required this.method,
    required this.onSelect,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onSelect(method),
      child: Container(
        margin: EdgeInsets.only(bottom: isLast ? 0 : 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: PayColors.cardBg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: PayColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon badge
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: accentColor, size: 22),
            ),
            const SizedBox(width: 14),
            // Labels
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: PayColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: PayColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            // Chevron
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.arrow_forward_ios_rounded,
                  color: PayColors.textSecondary, size: 12),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// PROCESSING CARD
// ─────────────────────────────────────────────────────────────
class _ProcessingCard extends StatelessWidget {
  const _ProcessingCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: PayColors.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: PayColors.border),
      ),
      child: const Row(
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation(PayColors.indigo),
            ),
          ),
          SizedBox(width: 16),
          Text(
            "Processing payment…",
            style: TextStyle(
              color: PayColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// SUCCESS CARD
// ─────────────────────────────────────────────────────────────
class _SuccessCard extends StatelessWidget {
  const _SuccessCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF059669), Color(0xFF065F46)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF059669).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(Icons.check_circle_rounded, color: Colors.white, size: 52),
          const SizedBox(height: 12),
          const Text(
            "Payment Successful",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Your repair job has been confirmed.\nOur technician will be in touch shortly.",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.75),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// SECURITY FOOTER
// ─────────────────────────────────────────────────────────────
class _SecurityFooter extends StatelessWidget {
  const _SecurityFooter();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.shield_outlined, size: 14, color: PayColors.textMuted),
        const SizedBox(width: 6),
        
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// SHARED SHEET BASE
// ─────────────────────────────────────────────────────────────
class _SheetBase extends StatelessWidget {
  final Widget child;
  const _SheetBase({required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5E7EB),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
            child,
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// SHARED PAY BUTTON
// ─────────────────────────────────────────────────────────────
class _PayButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final List<Color> gradientColors;
  final bool isLoading;

  const _PayButton({
    required this.label,
    required this.onTap,
    required this.gradientColors,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isLoading
                ? [const Color(0xFFD1D5DB), const Color(0xFFD1D5DB)]
                : gradientColors,
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: isLoading
              ? []
              : [
                  BoxShadow(
                    color: gradientColors.last.withOpacity(0.35),
                    blurRadius: 14,
                    offset: const Offset(0, 5),
                  ),
                ],
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation(Colors.white)),
                )
              : Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// SHARED TEXT FIELD
// ─────────────────────────────────────────────────────────────
class _PayField extends StatelessWidget {
  final String label;
  final String hint;
  final IconData icon;
  final Color accentColor;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLength;

  const _PayField({
    required this.label,
    required this.hint,
    required this.icon,
    required this.accentColor,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    this.maxLength,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        maxLength: maxLength,
        style: const TextStyle(
          color: PayColors.textPrimary,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
        decoration: InputDecoration(
          counterText: '',
          labelText: label,
          hintText: hint,
          labelStyle:
              const TextStyle(color: PayColors.textSecondary, fontSize: 13),
          hintStyle:
              const TextStyle(color: PayColors.textMuted, fontSize: 14),
          prefixIcon: Icon(icon, color: accentColor, size: 20),
          filled: true,
          fillColor: PayColors.surface,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: PayColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide:
                BorderSide(color: accentColor, width: 1.5),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// SHEET HEADER
// ─────────────────────────────────────────────────────────────
class _SheetHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
  final Color bgColor;

  const _SheetHeader({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: accentColor, size: 22),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: PayColors.textPrimary,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              subtitle,
              style: const TextStyle(
                  color: PayColors.textSecondary, fontSize: 12),
            ),
          ],
        ),
        const Spacer(),
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.close_rounded,
                size: 16, color: PayColors.textSecondary),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// AMOUNT PILL
// ─────────────────────────────────────────────────────────────
class _AmountPill extends StatelessWidget {
  final double amount;
  final Color color;

  const _AmountPill({required this.amount, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.18)),
      ),
      child: Column(
        children: [
          Text(
            "AMOUNT DUE",
            style: TextStyle(
              color: color.withOpacity(0.7),
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.4,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "KES ${amount.toStringAsFixed(2)}",
            style: TextStyle(
              color: color,
              fontSize: 26,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// M-PESA SHEET
// ─────────────────────────────────────────────────────────────
class MpesaSheet extends StatefulWidget {
  final double amount;
  final VoidCallback onPay;

  const MpesaSheet({super.key, required this.amount, required this.onPay});

  @override
  State<MpesaSheet> createState() => _MpesaSheetState();
}

class _MpesaSheetState extends State<MpesaSheet> {
  bool _isLoading = false;
  bool _isPushSent = false;

  void _handlePay() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _isPushSent = true;
    });
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;
    Navigator.pop(context);
    widget.onPay();
  }

  @override
  Widget build(BuildContext context) {
    return _SheetBase(
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        transitionBuilder: (child, anim) =>
            FadeTransition(opacity: anim, child: child),
        child: _isLoading
            ? _LoadingState(key: const ValueKey('loading'), color: PayColors.mpesaGreen)
            : _isPushSent
                ? _PushSentState(key: const ValueKey('sent'))
                : _MpesaFormContent(
                    key: const ValueKey('form'),
                    amount: widget.amount,
                    onPay: _handlePay,
                  ),
      ),
    );
  }
}

class _MpesaFormContent extends StatelessWidget {
  final double amount;
  final VoidCallback onPay;

  const _MpesaFormContent(
      {super.key, required this.amount, required this.onPay});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _SheetHeader(
          title: "M-Pesa",
          subtitle: "Mobile money payment",
          icon: Icons.phone_android_rounded,
          accentColor: PayColors.mpesaGreen,
          bgColor: const Color(0xFFECFDF5),
        ),
        _AmountPill(amount: amount, color: PayColors.mpesaGreen),
        _PayField(
          label: "M-Pesa Phone Number",
          hint: "712 345 678",
          icon: Icons.phone_rounded,
          accentColor: PayColors.mpesaGreen,
          keyboardType: TextInputType.phone,
          maxLength: 9,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        ),
        const SizedBox(height: 4),
        const _InfoNote(
            text: "You'll receive a push notification to enter your M-Pesa PIN to pay for your repair."),
        const SizedBox(height: 16),
        _PayButton(
          label: "Pay",
          onTap: onPay,
          gradientColors: [PayColors.mpesaGreen, PayColors.mpesaGreenDark],
        ),
      ],
    );
  }
}

class _PushSentState extends StatelessWidget {
  const _PushSentState({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: const BoxDecoration(
            color: Color(0xFFECFDF5),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.smartphone_rounded,
              color: PayColors.mpesaGreen, size: 40),
        ),
        const SizedBox(height: 16),
        const Text(
          "Push Sent!",
          style: TextStyle(
            color: PayColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          "Enter your M-Pesa PIN on your phone\nto complete the repair payment.",
          textAlign: TextAlign.center,
          style: TextStyle(color: PayColors.textSecondary, fontSize: 13),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// CARD SHEET
// ─────────────────────────────────────────────────────────────
class CardSheet extends StatefulWidget {
  final double amount;
  final VoidCallback onPay;

  const CardSheet({super.key, required this.amount, required this.onPay});

  @override
  State<CardSheet> createState() => _CardSheetState();
}

class _CardSheetState extends State<CardSheet> {
  bool _isLoading = false;

  void _handlePay() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    Navigator.pop(context);
    widget.onPay();
  }

  @override
  Widget build(BuildContext context) {
    return _SheetBase(
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 350),
        child: _isLoading
            ? _LoadingState(key: const ValueKey('loading'), color: PayColors.indigo)
            : _CardFormContent(
                key: const ValueKey('form'),
                amount: widget.amount,
                onPay: _handlePay,
                isLoading: _isLoading,
              ),
      ),
    );
  }
}

class _CardFormContent extends StatelessWidget {
  final double amount;
  final VoidCallback onPay;
  final bool isLoading;

  const _CardFormContent(
      {super.key,
      required this.amount,
      required this.onPay,
      required this.isLoading});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _SheetHeader(
          title: "Card Payment",
          subtitle: "Visa · Mastercard · Amex",
          icon: Icons.credit_card_rounded,
          accentColor: PayColors.indigo,
          bgColor: const Color(0xFFEEF2FF),
        ),
        _AmountPill(amount: amount, color: PayColors.indigo),
        _PayField(
          label: "Card Number",
          hint: "1234 5678 9012 3456",
          icon: Icons.credit_card_rounded,
          accentColor: PayColors.indigo,
          keyboardType: TextInputType.number,
          maxLength: 19,
        ),
        Row(
          children: const [
            Expanded(
              child: _PayField(
                label: "Expiry",
                hint: "MM / YY",
                icon: Icons.calendar_today_rounded,
                accentColor: PayColors.indigo,
                keyboardType: TextInputType.number,
                maxLength: 5,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _PayField(
                label: "CVV",
                hint: "•••",
                icon: Icons.lock_rounded,
                accentColor: PayColors.indigo,
                keyboardType: TextInputType.number,
                maxLength: 3,
              ),
            ),
          ],
        ),
        _PayField(
          label: "Cardholder Name",
          hint: "As it appears on the card",
          icon: Icons.person_outline_rounded,
          accentColor: PayColors.indigo,
        ),
        const SizedBox(height: 4),
        _PayButton(
          label: "Pay Repair Bill · KES 4,500",
          onTap: onPay,
          gradientColors: [PayColors.indigo, PayColors.violet],
          isLoading: isLoading,
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// PAYPAL SHEET
// ─────────────────────────────────────────────────────────────
class PayPalSheet extends StatelessWidget {
  final double amount;
  final VoidCallback onPay;

  const PayPalSheet({super.key, required this.amount, required this.onPay});

  @override
  Widget build(BuildContext context) {
    return _SheetBase(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _SheetHeader(
            title: "PayPal",
            subtitle: "Fast & secure checkout",
            icon: Icons.account_balance_wallet_rounded,
            accentColor: PayColors.paypalBlue,
            bgColor: const Color(0xFFEFF6FF),
          ),
          _AmountPill(amount: amount, color: PayColors.paypalBlue),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F9FF),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFBFDBFE)),
            ),
            child: Row(
              children: const [
                Icon(Icons.info_outline_rounded,
                    color: PayColors.paypalBlue, size: 18),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "You'll be redirected to PayPal to complete your repair payment securely.",
                    style: TextStyle(
                      color: PayColors.paypalBlue,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _PayButton(
            label: "Continue to PayPal",
            onTap: () {
              Navigator.pop(context);
              onPay();
            },
            gradientColors: [PayColors.paypalGold, Color(0xFFE6A800)],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.verified_user_rounded,
                  color: PayColors.textMuted, size: 13),
              SizedBox(width: 5),
              Text(
                "Encrypted · Buyer Protection",
                style: TextStyle(color: PayColors.textMuted, fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// CRYPTO SHEET
// ─────────────────────────────────────────────────────────────
class CryptoSheet extends StatelessWidget {
  final VoidCallback onConnect;

  const CryptoSheet({super.key, required this.onConnect});

  @override
  Widget build(BuildContext context) {
    return _SheetBase(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SheetHeader(
            title: "Crypto Wallet",
            subtitle: "Connect your wallet",
            icon: Icons.token_rounded,
            accentColor: PayColors.cryptoCyan,
            bgColor: const Color(0xFFECFEFF),
          ),
          const SizedBox(height: 16),
          const _SectionLabel(text: "Select wallet"),
          const SizedBox(height: 12),
          _WalletOption(
            name: "MetaMask",
            icon: Icons.token_rounded,
            color: const Color(0xFFF6851B),
            onTap: () {
              Navigator.pop(context);
              onConnect();
            },
          ),
          const SizedBox(height: 10),
          _WalletOption(
            name: "Trust Wallet",
            icon: Icons.shield_rounded,
            color: const Color(0xFF3375BB),
            onTap: () {
              Navigator.pop(context);
              onConnect();
            },
          ),
          const SizedBox(height: 10),
          _WalletOption(
            name: "Coinbase Wallet",
            icon: Icons.account_balance_rounded,
            color: const Color(0xFF0052FF),
            onTap: () {
              Navigator.pop(context);
              onConnect();
            },
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.auto_awesome_rounded,
                  color: PayColors.cryptoCyan.withOpacity(0.6), size: 13),
              const SizedBox(width: 6),
              Text(
                "Powered by Web3Auth",
                style: TextStyle(
                  color: PayColors.cryptoCyan.withOpacity(0.6),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WalletOption extends StatelessWidget {
  final String name;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _WalletOption({
    required this.name,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: PayColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: PayColors.border),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              name,
              style: const TextStyle(
                color: PayColors.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            const Icon(Icons.chevron_right_rounded,
                color: PayColors.textSecondary, size: 20),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// LOADING STATE (shared)
// ─────────────────────────────────────────────────────────────
class _LoadingState extends StatelessWidget {
  final Color color;
  const _LoadingState({super.key, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            "Processing…",
            style: TextStyle(
              color: PayColors.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// INFO NOTE
// ─────────────────────────────────────────────────────────────
class _InfoNote extends StatelessWidget {
  final String text;
  const _InfoNote({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline_rounded,
              size: 14, color: PayColors.textMuted),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                  color: PayColors.textMuted, fontSize: 11.5),
            ),
          ),
        ],
      ),
    );
  }
}