// auth_flow/signUpScreen.dart
import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../tabs/homepage.dart';

// --- Color Palette ---
const Color _kCyan = Color(0xFF00E5FF);
const Color _kSoftWhite = Color(0xFFFFFFFF);
const Color _kFieldBg = Color(0x26FFFFFF);

void main() {
  runApp(const SignUpApp());
}

class SignUpApp extends StatelessWidget {
  const SignUpApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SignUpScreen(),
    );
  }
}

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  String? _selectedRole;
  bool _showForm = false;

  String _fullName = "";
  String _email = "";
  String _phone = "";
  String _country = "";
  String _county = "";
  String _subcounty = "";
  String _estate = "";
  String _password = "";
  String _jobType = "";

  void _selectRole(String role) {
    setState(() {
      _selectedRole = role;
      _showForm = true;
    });
  }

  void _resetRole() {
    setState(() {
      _selectedRole = null;
      _showForm = false;
    });
  }

  Future<void> _submitToBackend() async {
    final url = _selectedRole == 'customer'
        ? 'https://bytly-backend.onrender.com/customerSignUp'
        : 'https://bytly-backend.onrender.com/technicianSignUp';

    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("Please wait...")));

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "name": _fullName,
          "email": _email,
          "phonenumber": _phone,
          "country": _country,
          "county": _county,
          "subcounty": _subcounty,
          "estate": _estate,
          "password": _password,
          if (_selectedRole == "technician") "jobtype": _jobType,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Registration Successful!")));

        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const AfribytApp()),
            );
          }
        });
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(response.body)));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      _submitToBackend();
    }
  }

  // --- Neon Input Field ---
  Widget _input(String hint, Function(String?) onSaved,
      {bool obscure = false,
      String? Function(String?)? validator,
      IconData icon = Icons.edit_outlined}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(color: _kCyan, width: 1.8),
          color: _kFieldBg,
          boxShadow: [
            BoxShadow(
              color: _kCyan.withOpacity(0.45),
              blurRadius: 14,
              spreadRadius: 1,
            ),
          ],
        ),
        child: TextFormField(
          style: const TextStyle(color: _kSoftWhite, fontSize: 15),
          obscureText: obscure,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle:
                TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 15),
            prefixIcon: Icon(icon, color: _kCyan, size: 20),
            border: InputBorder.none,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          ),
          validator: validator ?? (v) => v!.isEmpty ? "Required" : null,
          onSaved: onSaved,
        ),
      ),
    );
  }

  Widget _buildFormFields(String role) {
    List<Widget> fields = [
      _input('Full Name', (v) => _fullName = v!, icon: Icons.person_outline),
      _input('Email', (v) => _email = v!, icon: Icons.email_outlined,
          validator: (v) => !v!.contains("@") ? "Invalid Email" : null),
      _input('Phone Number', (v) => _phone = v!, icon: Icons.phone_outlined),
      const SizedBox(height: 8),
      _section("Location"),
      _input('Country', (v) => _country = v!, icon: Icons.public_outlined),
      _input('County', (v) => _county = v!, icon: Icons.location_on_outlined),
      _input('Subcounty', (v) => _subcounty = v!,
          icon: Icons.location_city_outlined),
      _input('Estate', (v) => _estate = v!, icon: Icons.home_outlined),
      const SizedBox(height: 8),
      _section("Security"),
      _input('Password', (v) => _password = v!,
          icon: Icons.lock_outline,
          obscure: true,
          validator: (v) => v!.length < 6 ? "Min 6 chars" : null),
    ];

    if (role == 'technician') {
      fields.add(_input('Job Type', (v) => _jobType = v!,
          icon: Icons.build_outlined));
    }

    return Column(children: fields);
  }

  Widget _section(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: const TextStyle(
            color: _kCyan,
            fontSize: 14,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.4,
          ),
        ),
      ),
    );
  }

  Widget _buildCardContent() {
    if (!_showForm) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Create Account",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w800,
              color: _kSoftWhite,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Join Bytly today!",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: Colors.white.withOpacity(0.65),
            ),
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              _roleBtn("customer", "Customer", Icons.person_outline),
              const SizedBox(width: 12),
              _roleBtn("technician", "Technician", Icons.build_outlined),
            ],
          ),
        ],
      );
    }

    return Form(
      key: _formKey,
      child: Column(
        children: [
          const Text(
            "Create Account",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w800,
              color: _kSoftWhite,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Join Bytly today!",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15, color: Colors.white.withOpacity(0.65)),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: _resetRole,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _kCyan.withOpacity(0.5), width: 1),
                color: _kCyan.withOpacity(0.08),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.swap_horiz, color: _kCyan, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    "← Change Role",
                    style: const TextStyle(color: _kCyan, fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          _buildFormFields(_selectedRole!),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              gradient: const LinearGradient(
                colors: [Color(0xFF00C6FF), Color(0xFF8A2BE2)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: _kCyan.withOpacity(0.55),
                  blurRadius: 20,
                  spreadRadius: 1,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _handleSubmit,
                borderRadius: BorderRadius.circular(30),
                child: const Center(
                  child: Text(
                    "Sign Up",
                    style: TextStyle(
                      color: _kSoftWhite,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _roleBtn(String role, String label, IconData icon) {
    bool selected = _selectedRole == role;
    return Expanded(
      child: GestureDetector(
        onTap: () => _selectRole(role),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(vertical: 28),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: selected
                ? const LinearGradient(
                    colors: [Color(0xFF00C6FF), Color(0xFF8A2BE2)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            border: Border.all(
              color: selected ? _kCyan : _kCyan.withOpacity(0.3),
              width: selected ? 2.0 : 1.2,
            ),
            color: selected ? null : _kFieldBg,
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: _kCyan.withOpacity(0.4),
                      blurRadius: 15,
                      spreadRadius: 1,
                    ),
                  ]
                : [],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon,
                  color: selected ? _kSoftWhite : _kCyan, size: 26),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  color: _kSoftWhite,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w400,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _glowOrb(double size, Color color, double opacity) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color.withOpacity(opacity), color.withOpacity(0.0)],
        ),
      ),
    );
  }

  Widget _glassCard(Widget child) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 450),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 36),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                color: const Color(0x22FFFFFF),
                border:
                    Border.all(color: Colors.white.withOpacity(0.25), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: _kCyan.withOpacity(0.18),
                    blurRadius: 40,
                    spreadRadius: 2,
                  ),
                  BoxShadow(
                    color: const Color(0xFF7B1FA2).withOpacity(0.25),
                    blurRadius: 40,
                    spreadRadius: 2,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF0D0060),
                    Color(0xFF1A006B),
                    Color(0xFF3A0080),
                    Color(0xFF0A0050),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          Positioned(
              top: -60,
              left: -60,
              child: _glowOrb(260, const Color(0xFF1565C0), 0.7)),
          Positioned(
              top: -40,
              left: screenWidth * 0.55,
              child: _glowOrb(200, const Color(0xFF7B1FA2), 0.65)),
          Positioned(
              top: screenHeight * 0.6,
              left: screenWidth * 0.6,
              child: _glowOrb(180, const Color(0xFF1565C0), 0.6)),
          Positioned(
              top: screenHeight * 0.65,
              left: -30,
              child: _glowOrb(150, const Color(0xFF6A1B9A), 0.55)),
          Positioned(
              top: screenHeight * 0.75,
              left: screenWidth * 0.3,
              child: _glowOrb(100, _kCyan, 0.25)),
          SafeArea(
            child: _showForm
                ? SingleChildScrollView(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                    child: _glassCard(_buildCardContent()),
                  )
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Center(
                      child: _glassCard(_buildCardContent()),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}