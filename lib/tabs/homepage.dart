// tabs/homepage.dart
import 'package:flutter/material.dart';
import 'payment.dart';
import 'profile.dart';
import '../sidebar items/feedback.dart';
import '../auth_flow/loginscreen.dart';
import '../sidebar items/helpSupportpage.dart';
import '../sidebar items/settings.dart';
import '../sidebar items/messages.dart';
import '../service_pages/phone_repair_page.dart';
import '../service_pages/laptop_repair_page.dart';
import '../service_pages/home_appliance_page.dart';
import '../service_pages/electrical_services_page.dart';
import '../sidebar items/paymentHistory.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../service_pages/cctv_Installation_page.dart';
import '../service_pages/plumbing_service_page.dart';
import 'tech_news.dart';

void main() {
  runApp(const AfribytApp());
}

class AfribytApp extends StatelessWidget {
  const AfribytApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Define the primary color palette
    const Color primaryPurple = Color(0xFF6A1B9A); // Deep Purple
    const Color accentBlue = Color(0xFF29B6F6); // Light Blue (Used for active navbar)
    // Less bright background color
    const Color lessBrightBackground = Color(0xFFF0F0F5);

    return MaterialApp(
      title: 'Bytly Marketplace',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Font family set to Roboto for Bolt-like aesthetic
        fontFamily: 'Roboto',
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryPurple,
          primary: primaryPurple,
          secondary: accentBlue,
          background: lessBrightBackground,
        ),
        scaffoldBackgroundColor: lessBrightBackground,
        useMaterial3: true,
      ),
      home: const AfribytHomeScreen(),
    );
  }
}

// --- MAIN SCREEN WIDGET (Manages Bottom Navigation State) ---

class AfribytHomeScreen extends StatefulWidget {
  const AfribytHomeScreen({super.key});

  @override
  State<AfribytHomeScreen> createState() => _AfribytHomeScreenState();
}

class _AfribytHomeScreenState extends State<AfribytHomeScreen> {
  // State to track the selected bottom navigation tab (0=Home, 1=Request, 2=Payment, 3=Profile)
  int _currentBottomTabIndex = 0;
  
  // State for the inner Services/News tab (only relevant for Home screen, index 0)
  int _selectedContentTabIndex = 0;

  // Defines the content for each main screen
  Widget _getBody(int index) {
    switch (index) {
      case 0:
        // Home screen needs the inner tab state and handler
        return _HomeContent(
          selectedContentTabIndex: _selectedContentTabIndex,
          onContentTabSelected: (idx) {
            setState(() {
              _selectedContentTabIndex = idx;
            });
          },
        );
      case 2:
        return const PaymentApp();
      case 3:
        return const ProfileScreen();
      default:
        return const Center(child: Text('Error: Screen not found'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const _CustomDrawer(),
      // The body dynamically changes based on the selected bottom tab
      body: SafeArea(
        child: _getBody(_currentBottomTabIndex),
      ),
      // Custom Bottom Navigation Bar passes its tap events back to the state
      bottomNavigationBar: _CustomBottomNavBar(
        selectedIndex: _currentBottomTabIndex,
        onTap: (index) {
          setState(() {
            _currentBottomTabIndex = index;
            // Optionally reset inner Services/News tab when returning to Home
            if (index == 0) {
              _selectedContentTabIndex = 0;
            }
          });
        },
      ),
    );
  }
}

// --- HOME SCREEN CONTENT (Only rendered when bottom tab is Home) ---

class _HomeContent extends StatelessWidget {
  final int selectedContentTabIndex;
  final Function(int) onContentTabSelected;

  const _HomeContent({
    required this.selectedContentTabIndex,
    required this.onContentTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const SizedBox(height: 10.0),
            // 1. Custom Header
            const _CustomHeader(),
            const SizedBox(height: 15.0),

            // 2. Promo Card
            const _PromoCard(),
            const SizedBox(height: 15.0),

            // 3. Custom Tab Selection Bar (Services/News)
            _CustomTabBar(
              selectedIndex: selectedContentTabIndex,
              onTabSelected: onContentTabSelected,
            ),
            const SizedBox(height: 20.0),

            // 4. Conditional Content Body (Services or News)
            if (selectedContentTabIndex == 0)
              const _ServicesView()
            else
              const NewsUpdatesSection(),

            const SizedBox(height: 10.0),
          ],
        ),
      ),
    );
  }
}

// --- Custom Tab Bar (Services/News) ---

class _CustomTabBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTabSelected;

  const _CustomTabBar({
    required this.selectedIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    final Color primaryPurple = Theme.of(context).colorScheme.primary;
    final Color accentBlue = Theme.of(context).colorScheme.secondary;

    return Container(
      height: 45,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Tab 1: Services
          Expanded(
            child: GestureDetector(
              onTap: () => onTabSelected(0),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  // Gradient background if selected, transparent if not
                  gradient: selectedIndex == 0
                      ? LinearGradient(
                          colors: [primaryPurple, accentBlue],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  color: selectedIndex == 0 ? null : Colors.transparent,
                ),
                child: Center(
                  child: Text(
                    'Services',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: selectedIndex == 0 ? Colors.white : Colors.grey[600],
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Tab 2: News & Updates
          Expanded(
            child: GestureDetector(
              onTap: () => onTabSelected(1),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  gradient: selectedIndex == 1
                      ? LinearGradient(
                          colors: [primaryPurple, accentBlue],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  color: selectedIndex == 1 ? null : Colors.transparent,
                ),
                child: Center(
                  child: Text(
                    'Tech news',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: selectedIndex == 1 ? Colors.white : Colors.grey[600],
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
}

// --- SERVICES VIEW ---

class _ServicesView extends StatelessWidget {
  const _ServicesView();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _SectionTitle(title: 'My services', showSeeAll: true),
        const SizedBox(height: 16.0, ),
        const _MyBookingsList(),
        const SizedBox(height: 30.0),
        const _SectionTitle(title: 'Available services', showDropdown: true),
        const SizedBox(height: 16.0),
        PopularServicesGrid(),
      ],
    );
  }
}


// --- EXISTING WIDGETS (Header, Promo, Sections, Drawer) ---



class _CustomHeader extends StatefulWidget {
  const _CustomHeader({super.key});

  @override
  State<_CustomHeader> createState() => _CustomHeaderState();
}

class _CustomHeaderState extends State<_CustomHeader> {

  final AuthService _authService = AuthService();
  final UserService _userService =
    UserService();

  String username = "User";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  Future<void> loadUser() async {

  final user =
      await _userService.getSavedUser();

  if (!mounted) return;

  setState(() {

    username =
        user?.name ?? "User";

    isLoading = false;
  });
}

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [

        Row(
          children: [

            const CircleAvatar(
              radius: 24,
              backgroundColor: Color(0xFFE0E0E0),
              child: Icon(Icons.person, color: Colors.white),
            ),

            const SizedBox(width: 12),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                const Text(
                  "Hello,",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                isLoading
                    ? const SizedBox(
                        width: 80,
                        height: 12,
                        child: LinearProgressIndicator(),
                      )
                    : Text(
                        username,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937),
                        ),
                      ),
              ],
            ),
          ],
        ),

        Row(
          children: [

            Text(
              '.',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),

            const SizedBox(width: 4),

            IconButton(
              icon: const Icon(Icons.menu_rounded),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            ),
          ],
        ),
      ],
    );
  }
}


class _PromoCard extends StatelessWidget {
  const _PromoCard();

  @override
  Widget build(BuildContext context) {
    final Color primaryPurple = Theme.of(context).colorScheme.primary;
    final Color accentBlue = Theme.of(context).colorScheme.secondary;

    return Container(
      height: 150,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryPurple.withOpacity(0.95), accentBlue.withOpacity(0.9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: primaryPurple.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            bottom: -20,
            child: Icon(
              Icons.work_history_rounded,
              size: 150,
              color: Colors.white.withOpacity(0.15),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Bytly Service Market',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                const SizedBox(height: 4),
                const Text(
                  'We bring the service to your doorstep!',
                  style: TextStyle(fontSize: 14, color: Color.fromARGB(255, 255, 255, 255)),
                ),
                const Spacer(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final bool showSeeAll;
  final bool showDropdown;

  const _SectionTitle({
    required this.title,
    this.showSeeAll = false,
    this.showDropdown = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937)),
        ),
        if (showSeeAll)
          Text(
            'See all',
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.secondary),
          )
        else if (showDropdown)
          Row(
            children: const [
              Text(
                '.',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937)),
              ),
              Icon(Icons.keyboard_arrow_down, size: 20, color: Color(0xFF1F2937)),
            ],
          )
      ],
    );
  }
}

class _MyBookingsList extends StatelessWidget {
  const _MyBookingsList();

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> bookings = [
      {'title': 'Phone repair', 'icon': Icons.camera_alt, 'time': '3 days left', 'items': '1 session'},
      {'title': 'Microwave repair', 'icon': Icons.trending_up, 'time': '1 month left', 'items': '4 posts'},
      {'title': 'Website Development', 'icon': Icons.code, 'time': 'Pending', 'items': 'Review'},
    ];

    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: bookings.length,
        itemBuilder: (context, index) {
          final booking = bookings[index];
          return Padding(
            padding: EdgeInsets.only(right: index == bookings.length - 1 ? 0 : 15.0),
            child: _BookingItemCard(booking: booking),
          );
        },
      ),
    );
  }
}

class _BookingItemCard extends StatelessWidget {
  final Map<String, dynamic> booking;
  const _BookingItemCard({required this.booking});

  @override
  Widget build(BuildContext context) {
    final Color primaryPurple = Theme.of(context).colorScheme.primary;
    final Color accentBlue = Theme.of(context).colorScheme.secondary;

    return Container(
      width: 300,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: primaryPurple.withOpacity(0.25),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                gradient: LinearGradient(
                  colors: [primaryPurple.withOpacity(0.1), accentBlue.withOpacity(0.1)],
                  begin: Alignment.bottomLeft,
                  end: Alignment.topRight,
                ),
              ),
              child: Icon(
                booking['icon'] as IconData,
                color: primaryPurple,
                size: 28,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 155,
                  child: Text(
                    booking['title'] as String,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF1F2937)),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${booking['time']} • ${booking['items']}',
                  style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class PopularServicesGrid extends StatelessWidget {
  PopularServicesGrid({super.key});

  final List<Map<String, dynamic>> services = [
    const {
      'title': 'Phone repair',
      'rating': 4.9,
      'image': 'assets/download (7).jpg',
      'icon': Icons.phone_android_rounded,
      'page': PhoneRepairPage(),
    },
    {
      'title': 'Laptop repair',
      'rating': 5.0,
      'image': 'assets/download (6).jpg',
      'icon': Icons.laptop_mac_rounded,
      'page': LaptopRepairDetailsPage(),
    },
    {
      'title': 'Appliance repair',
      'rating': 4.7,
      'image': 'assets/Mesa Appliance Repair Service.jpg',
      'icon': Icons.build_rounded,
      'page': HomeApplianceRepairDetailsPage(),
    },
    {
      'title': 'Electrical services',
      'rating': 4.8,
      'image': 'assets/download (5).jpg',
      'icon': Icons.electrical_services_rounded,
      'page': ElectricalServicesDetailsPage(),
    },
    
   {
      'title': 'Plumbing services',
      'rating': 4.8,
      'image': 'assets/CCTV installation.png',
      'icon': Icons.plumbing_rounded,
      'page': PlumbingPage(),
    },
    {
      'title': 'CCTV installation',
      'rating': 4.8,
      'image': 'assets/CCTV installation.png',
      'icon': Icons.electrical_services_rounded,
      'page': CctvInstallationPage(),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16.0,
        mainAxisSpacing: 16.0,
        childAspectRatio: 0.9,
      ),
      itemCount: services.length,
      itemBuilder: (context, index) {
        final service = services[index];
        return ServiceGridCard(
          title: service['title'],
          rating: service['rating'],
          imagePath: service['image'],
          icon: service['icon'],
          page: service['page'],
        );
      },
    );
  }
}

class ServiceGridCard extends StatelessWidget {
  final String title;
  final double rating;
  final String imagePath;
  final IconData icon;
  final Widget page;

  const ServiceGridCard({
    super.key,
    required this.title,
    required this.rating,
    required this.imagePath,
    required this.icon,
    required this.page,
  });

  @override
  Widget build(BuildContext context) {
    final Color iconColor = Theme.of(context).colorScheme.primary;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => page),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          image: DecorationImage(
            image: AssetImage(imagePath),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.30),
              BlendMode.darken,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 10,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 50,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.35),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 30, color: iconColor),
              ),
              const Spacer(),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.star_rounded,
                    size: 18,
                    color: Colors.yellowAccent,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    rating.toStringAsFixed(1),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

class ServiceDetailPage extends StatelessWidget {
  final String title;

  const ServiceDetailPage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Text(
          "Welcome to $title service page!",
          style: const TextStyle(fontSize: 22),
        ),
      ),
    );
  }
}


// --- UPDATED BOTTOM NAVIGATION BAR (Accepts state handler) ---

class _CustomBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;

  const _CustomBottomNavBar({required this.selectedIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final Color accentBlue = Theme.of(context).colorScheme.secondary;

    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            spreadRadius: 5,
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _BottomNavItem(
              icon: Icons.home_rounded,
              label: 'Home',
              index: 0,
              isSelected: selectedIndex == 0,
              color: accentBlue,
              onTap: onTap),
          
          _BottomNavItem(
              icon: Icons.payment_rounded,
              label: 'Payment',
              index: 2,
              isSelected: selectedIndex == 2,
              color: accentBlue,
              onTap: onTap),
          _BottomNavItem(
              icon: Icons.person_outline_rounded,
              label: 'Profile',
              index: 3,
              isSelected: selectedIndex == 3,
              color: accentBlue,
              onTap: onTap),
        ],
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int index;
  final bool isSelected;
  final Color color;
  final Function(int) onTap;

  const _BottomNavItem({
    required this.icon,
    required this.label,
    required this.index,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 26, color: isSelected ? color : Colors.grey[400]),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
                fontSize: 10, // Slightly reduced font size to fit long label
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? color : Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}

class _CustomDrawer extends StatelessWidget {
  const _CustomDrawer();

  // Placeholder navigation functions for each item
void _navigateToMessages(BuildContext context) {
    Navigator.pop(context);
    // TODO: Replace with actual navigation to your ProfilePage()
     Navigator.push(context, MaterialPageRoute(builder: (context) => const MessagesScreen()));
    print('Navigating to Messages');
  }
  void _navigateToPayHistory(BuildContext context) {
    Navigator.pop(context);
    // TODO: Replace with actual navigation to your ProfilePage()
     Navigator.push(context, MaterialPageRoute(builder: (context) => const TransactionHistoryScreen()));
    print('Navigating to Payment History');
  }


  void _navigateToSettings(BuildContext context) {
    Navigator.pop(context);
    // TODO: Replace with actual navigation to your SettingsPage()
     Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen()));
    print('Navigating to Settings');
  }

  void _navigateToHelp(BuildContext context) {
    Navigator.pop(context);
    // TODO: Replace with actual navigation to your HelpPage()
    Navigator.push(context, MaterialPageRoute(builder: (context) => const HelpAndSupportScreen()));
    print('Navigating to Help & Support');
  }

  void _navigateToFeedback(BuildContext context) {
    Navigator.pop(context);
    
     Navigator.push(context, MaterialPageRoute(builder: (context) => const FeedbackScreen()));
    print('Navigating to Feedback');
  }

  void _handleLogout(BuildContext context) {
    Navigator.pop(context);
    // TODO: Add your secure logout logic (e.g., clearing tokens)
     Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
    print('Logging out...');
  }
  
  // --- BUILD METHOD ---
  @override
  Widget build(BuildContext context) {
    final Color primaryPurple = Theme.of(context).colorScheme.primary;
    // secondary is often 'accentBlue', but check your theme
    final Color accentBlue = Theme.of(context).colorScheme.secondary; 

    return Drawer(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(25),
          bottomRight: Radius.circular(25),
        ),
      ),
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primaryPurple, accentBlue],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(25),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: const [
                Text(
                  'Bytly Menu',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text(
                  'Quick Navigation',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
          // CALLING THE ITEMS WITH NAVIGATION FUNCTIONS
          _buildDrawerItem(context, Icons.person_rounded, 'Messages',
              onTap: () => _navigateToMessages(context)),
          _buildDrawerItem(context, Icons.person_rounded, 'Payment History',
              onTap: () => _navigateToPayHistory(context)),
          _buildDrawerItem(context, Icons.settings_rounded, 'Settings',
              onTap: () => _navigateToSettings(context)),
          _buildDrawerItem(context, Icons.help_outline_rounded, 'Help & Support',
              onTap: () => _navigateToHelp(context)),
          _buildDrawerItem(context, Icons.feedback_rounded, 'Feedback',
              onTap: () => _navigateToFeedback(context)),
          
          const Divider(height: 32, thickness: 1, indent: 16, endIndent: 16),
          
          _buildDrawerItem(context, Icons.logout_rounded, 'Logout',
              color: primaryPurple, onTap: () => _handleLogout(context)),
        ],
      ),
    );
  }

  // --- DRAWER ITEM FUNCTION MODIFIED ---
  Widget _buildDrawerItem(BuildContext context, IconData icon, String title,
      {Color? color, required VoidCallback onTap}) { // ADDED required VoidCallback onTap
    return ListTile(
      leading: Icon(icon, color: color ?? Colors.grey[700]),
      title: Text(
        title,
        style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: color ?? const Color(0xFF1F2937)),
      ),
      onTap: onTap, // ASSIGNING THE PROVIDED FUNCTION HERE
    );
  }
}