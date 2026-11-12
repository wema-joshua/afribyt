// tabs/profile.dart

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../repositories/user_repository.dart';
import '../models/user_model.dart';

// ─────────────────────────────────────────
// THEME TOKENS
// ─────────────────────────────────────────
class AppColors {
  static const Color primary = Color(0xFF4F46E5);       // indigo-600
  static const Color primaryLight = Color(0xFF818CF8);  // indigo-400
  static const Color accent = Color(0xFF7C3AED);        // violet-600
  static const Color accentLight = Color(0xFFA78BFA);   // violet-400
  static const Color surface = Color(0xFFF8F7FF);       // soft lavender white
  static const Color cardBg = Colors.white;
  static const Color textPrimary = Color(0xFF1E1B4B);   // deep indigo
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color divider = Color(0xFFE5E7EB);
  static const Color tagBg = Color(0xFFEEF2FF);
  static const Color tagText = Color(0xFF4F46E5);
}

// ─────────────────────────────────────────
// USER MODEL
// ─────────────────────────────────────────
class UserProfile {
  final String username;
  final String email;
  final String country;
  final String county;
  final String subCounty;

  UserProfile({
    required this.username,
    required this.email,
    required this.country,
    required this.county,
    required this.subCounty,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      username: json['username'] ?? json['name'] ?? 'User',
      email: json['email'] ?? '',
      country: json['country'] ?? '',
      county: json['county'] ?? '',
      subCounty: json['subcounty'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        "name": username,
        "email": email,
        "country": country,
        "county": county,
        "subcounty": subCounty,
      };
}

// ─────────────────────────────────────────
// PROFILE SCREEN
// ─────────────────────────────────────────
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  final AuthService authService = AuthService();
  late Future<UserProfile> profileFuture;
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    profileFuture = fetchProfile();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  // ── FETCH (cache-first) ─────────────────
  Future<UserProfile> fetchProfile() async {
    final userService = UserService();
    final cachedProfile = await userService.getSavedUser();
    if (cachedProfile != null) {
      refreshProfileInBackground();
      return UserProfile(
        username: cachedProfile.name,
        email: cachedProfile.email,
        country: cachedProfile.country,
        county: cachedProfile.county,
        subCounty: cachedProfile.subcounty,
      );
    }
    return fetchOnlineProfile();
  }

  Future<UserProfile> fetchOnlineProfile() async {
    final token = await authService.getToken();
    if (token == null) throw Exception("User not logged in");

    final response = await http.get(
      Uri.parse("https://techlink-backend-ra33.onrender.com/profile"),
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await UserService().saveUser(UserModel.fromJson(data));
      return UserProfile.fromJson(data);
    } else {
      throw Exception("Failed to load profile");
    }
  }

  Future<void> refreshProfileInBackground() async {
    try {
      final token = await authService.getToken();
      if (token == null) return;
      final response = await http.get(
        Uri.parse("https://techlink-backend-ra33.onrender.com/profile"),
        headers: {"Authorization": "Bearer $token"},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await UserService().saveUser(UserModel.fromJson(data));
        if (mounted) {
          setState(() {
            profileFuture = Future.value(UserProfile.fromJson(data));
          });
        }
      }
    } catch (_) {} // silent fail — works offline
  }

  // ── UPDATE PROFILE ───────────────────────
  Future<void> updateProfile(UserProfile user) async {
    final token = await authService.getToken();
    if (token == null) throw Exception("No token found");

    final response = await http.put(
      Uri.parse("https://techlink-backend-ra33.onrender.com/profile/update"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: json.encode(user.toJson()),
    );

    if (response.statusCode == 200) {
      final existingUser = await UserRepository().getLocalUser();
      if (existingUser == null) throw Exception("User not found");

      await UserService().saveUser(UserModel(
        id: existingUser.id,
        name: user.username,
        email: user.email,
        role: existingUser.role,
        country: user.country,
        county: user.county,
        subcounty: user.subCounty,
      ));

      setState(() => profileFuture = Future.value(user));

      if (mounted) {
        _showToast("Profile updated successfully", isError: false);
      }
    } else {
      throw Exception("Failed to update profile");
    }
  }

  void _showToast(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 8),
            Flexible(child: Text(message)),
          ],
        ),
        backgroundColor: isError ? Colors.red[700] : AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  // ── BUILD ────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: FutureBuilder<UserProfile>(
        future: profileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const _LoadingView();
          }
          if (snapshot.hasError) {
            return _ErrorView(
              message: snapshot.error.toString(),
              onRetry: () => setState(() => profileFuture = fetchProfile()),
            );
          }

          // Kick off fade-in on first data
          _fadeCtrl.forward();
          final user = snapshot.data!;

          return FadeTransition(
            opacity: _fadeAnim,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // ── HERO SLIVER ──────────────
                SliverToBoxAdapter(child: _HeroHeader(user: user)),

                // ── INFO CARDS ───────────────
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      const SizedBox(height: 24),
                      _SectionLabel(label: "Account Info"),
                      const SizedBox(height: 12),
                      _InfoCard(
                        icon: Icons.person_outline_rounded,
                        label: "Username",
                        value: user.username,
                        iconColor: AppColors.primary,
                      ),
                      _InfoCard(
                        icon: Icons.email_outlined,
                        label: "Email",
                        value: user.email,
                        iconColor: AppColors.accent,
                      ),
                      const SizedBox(height: 8),
                      _SectionLabel(label: "Location"),
                      const SizedBox(height: 12),
                      _InfoCard(
                        icon: Icons.public_rounded,
                        label: "Country",
                        value: user.country.isEmpty ? "Not set" : user.country,
                        iconColor: const Color(0xFF0EA5E9),
                      ),
                      _InfoCard(
                        icon: Icons.location_city_rounded,
                        label: "County",
                        value: user.county.isEmpty ? "Not set" : user.county,
                        iconColor: const Color(0xFF10B981),
                      ),
                      _InfoCard(
                        icon: Icons.map_outlined,
                        label: "Sub-county",
                        value:
                            user.subCounty.isEmpty ? "Not set" : user.subCounty,
                        iconColor: const Color(0xFFF59E0B),
                      ),
                      const SizedBox(height: 24),

                      // ── EDIT BUTTON ──────────
                      _EditButton(
                        onTap: () => _openEditSheet(context, user),
                      ),
                    ]),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _openEditSheet(BuildContext context, UserProfile user) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => EditProfileSheet(user: user, onSave: updateProfile),
    );
  }
}

// ─────────────────────────────────────────
// HERO HEADER
// ─────────────────────────────────────────
class _HeroHeader extends StatelessWidget {
  final UserProfile user;
  const _HeroHeader({required this.user});

  String get _initials {
    final parts = user.username.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return user.username.isNotEmpty
        ? user.username[0].toUpperCase()
        : '?';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF3730A3), Color(0xFF6D28D9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
          child: Column(
            children: [
              // ── TOP ROW ──────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "My Profile",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.verified_rounded,
                            color: Colors.white, size: 14),
                        SizedBox(width: 4),
                        Text(
                          "Active",
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

              // ── AVATAR ───────────────────
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Colors.white, Color(0xFFC4B5FD)],
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 46,
                      backgroundColor: const Color(0xFF4338CA),
                      child: Text(
                        _initials,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF7C3AED),
                      shape: BoxShape.circle,
                      border:
                          Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(Icons.camera_alt_rounded,
                        color: Colors.white, size: 14),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // ── NAME & EMAIL ─────────────
              Text(
                user.username,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                user.email,
                style: const TextStyle(
                  color: Color(0xFFC4B5FD),
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
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
// SECTION LABEL
// ─────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 16,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.accent],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────
// INFO CARD
// ─────────────────────────────────────────
class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color iconColor;

  const _InfoCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider, width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon badge
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 14),
          // Label + value
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          // Chevron
          Icon(Icons.chevron_right_rounded,
              color: AppColors.textSecondary.withOpacity(0.5), size: 20),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// EDIT BUTTON
// ─────────────────────────────────────────
class _EditButton extends StatelessWidget {
  final VoidCallback onTap;
  const _EditButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primary, AppColors.accent],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.edit_outlined, color: Colors.white, size: 18),
            SizedBox(width: 8),
            Text(
              "Edit Profile",
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// LOADING VIEW
// ─────────────────────────────────────────
class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation(AppColors.primary),
            ),
          ),
          SizedBox(height: 16),
          Text(
            "Loading profile…",
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// ERROR VIEW
// ─────────────────────────────────────────
class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.wifi_off_rounded,
                  color: Color(0xFFEF4444), size: 32),
            ),
            const SizedBox(height: 16),
            const Text(
              "Couldn't load profile",
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: onRetry,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.accent],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  "Try again",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
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
// EDIT PROFILE SHEET
// ─────────────────────────────────────────
class EditProfileSheet extends StatefulWidget {
  final UserProfile user;
  final Function(UserProfile) onSave;

  const EditProfileSheet({
    super.key,
    required this.user,
    required this.onSave,
  });

  @override
  State<EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<EditProfileSheet> {
  late final TextEditingController _usernameCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _countryCtrl;
  late final TextEditingController _countyCtrl;
  late final TextEditingController _subCountyCtrl;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _usernameCtrl = TextEditingController(text: widget.user.username);
    _emailCtrl = TextEditingController(text: widget.user.email);
    _countryCtrl = TextEditingController(text: widget.user.country);
    _countyCtrl = TextEditingController(text: widget.user.county);
    _subCountyCtrl = TextEditingController(text: widget.user.subCounty);
  }

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _emailCtrl.dispose();
    _countryCtrl.dispose();
    _countyCtrl.dispose();
    _subCountyCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    setState(() => _isSaving = true);
    try {
      await widget.onSave(
        UserProfile(
          username: _usernameCtrl.text.trim(),
          email: _emailCtrl.text.trim(),
          country: _countryCtrl.text.trim(),
          county: _countyCtrl.text.trim(),
          subCounty: _subCountyCtrl.text.trim(),
        ),
      );
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Update failed: ${e.toString()}"),
            backgroundColor: Colors.red[700],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(24, 0, 24, bottomInset + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── DRAG HANDLE ───────────────
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

          // ── HEADER ────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Edit Profile",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.4,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    "Update your information",
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close_rounded,
                      size: 18, color: AppColors.textSecondary),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // ── FIELDS ────────────────────
          _SheetField(
            label: "Username",
            icon: Icons.person_outline_rounded,
            controller: _usernameCtrl,
          ),
          _SheetField(
            label: "Email",
            icon: Icons.email_outlined,
            controller: _emailCtrl,
            keyboardType: TextInputType.emailAddress,
          ),
          _SheetField(
            label: "Country",
            icon: Icons.public_rounded,
            controller: _countryCtrl,
          ),
          _SheetField(
            label: "County",
            icon: Icons.location_city_rounded,
            controller: _countyCtrl,
          ),
          _SheetField(
            label: "Sub-county",
            icon: Icons.map_outlined,
            controller: _subCountyCtrl,
          ),

          const SizedBox(height: 12),

          // ── SAVE BUTTON ───────────────
          GestureDetector(
            onTap: _isSaving ? null : _handleSave,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                gradient: _isSaving
                    ? const LinearGradient(
                        colors: [Color(0xFFADA6F0), Color(0xFFBDA8F5)],
                      )
                    : const LinearGradient(
                        colors: [AppColors.primary, AppColors.accent],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: _isSaving
                    ? []
                    : [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
              ),
              child: Center(
                child: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        ),
                      )
                    : const Text(
                        "Save Changes",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
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
// SHEET FIELD
// ─────────────────────────────────────────
class _SheetField extends StatelessWidget {
  final String label;
  final IconData icon;
  final TextEditingController controller;
  final TextInputType keyboardType;

  const _SheetField({
    required this.label,
    required this.icon,
    required this.controller,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13,
          ),
          prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
          filled: true,
          fillColor: AppColors.surface,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.divider),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}