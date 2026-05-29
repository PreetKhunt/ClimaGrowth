import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_model.dart';
import '../providers/auth_provider.dart';
import '../utils/constants.dart';
import '../utils/formatters.dart';
import 'address_list_screen.dart';
import 'farm_map_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: _buildProfileHeader(user),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => _showEditSheet(context, auth, user),
              ),
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () => Navigator.pushNamed(context, '/settings'),
              ),
            ],
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              _buildStatsRow(user),
              const SizedBox(height: 12),
              _buildMenuItems(context, auth),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(UserModel? user) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor.withOpacity(0.08),
            Theme.of(context).scaffoldBackgroundColor,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 16),
      child: Row(
        children: [
          // Profile photo
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Theme.of(context).primaryColor,
                width: 2,
              ),
            ),
            child: ClipOval(
              child: Container(
                color: Colors.grey[300],
                child: const Icon(Icons.person, size: 40),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Name and details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  user?.name.isNotEmpty == true ? user!.name : 'Farmer',
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      user?.village.isNotEmpty == true
                          ? user!.village
                          : 'Padra, Gujarat',
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Verified Farmer',
                    style: TextStyle(
                      fontSize: 11,
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(UserModel? user) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          _buildStatCard('3', 'Farms'),
          const SizedBox(width: 12),
          _buildStatCard('12', 'Crops'),
          const SizedBox(width: 12),
          _buildStatCard('245', 'Points'),
        ],
      ),
    );
  }

  Widget _buildStatCard(String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          border:
              Border.all(color: const Color.fromRGBO(0, 0, 0, 0.07), width: 1),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFFE55934)),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItems(BuildContext context, AuthProvider auth) {
    final user = auth.user;
    final menuItems = [
      (
        'My Farm on Map',
        'Mark & view farm location',
        Icons.agriculture_outlined,
        const Color(0xFF00FF88)
      ),
      (
        'My Addresses',
        'Manage delivery addresses',
        Icons.location_on_outlined,
        const Color(0xFF4CC9F0)
      ),
      (
        'My Farms',
        '3 farms registered',
        Icons.landscape_outlined,
        const Color(0xFF7CB342)
      ),
      (
        'My Crops',
        '12 crops growing',
        Icons.agriculture_outlined,
        const Color(0xFF558B2F)
      ),
      (
        'Order History',
        '8 orders placed',
        Icons.receipt_outlined,
        const Color(0xFFFBC02D)
      ),
      (
        'Saved Items',
        '5 items in wishlist',
        Icons.favorite_outline,
        const Color(0xFFE91E63)
      ),
      (
        'Mission Points',
        '245 points earned',
        Icons.emoji_events_outlined,
        const Color(0xFF9C27B0)
      ),
      (
        'Crop Calendar',
        'Next: irrigation',
        Icons.calendar_today_outlined,
        const Color(0xFF03A9F4)
      ),
      (
        'Voice Diary',
        '23 entries recorded',
        Icons.mic_outlined,
        const Color(0xFF009688)
      ),
      (
        'Disease Scan',
        '4 scans this month',
        Icons.bug_report_outlined,
        const Color(0xFFF44336)
      ),
      (
        'Family Members',
        '2 connected',
        Icons.people_outline,
        const Color(0xFF8B7355)
      ),
      (
        'Carbon Credits',
        '42 credits earned',
        Icons.eco_outlined,
        const Color(0xFF4CAF50)
      ),
      (
        'KYC Documents',
        'Verification pending',
        Icons.description_outlined,
        const Color(0xFF9E9E9E)
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          ...menuItems.map((item) {
            return MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () => _handleMenuTap(context, item.$1),
                child: Container(
                  height: 64,
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                        color: const Color.fromRGBO(0, 0, 0, 0.07), width: 1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: item.$4.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(item.$3, color: item.$4, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              item.$1,
                              style: const TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              item.$2,
                              style: TextStyle(
                                  fontSize: 12, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right,
                          color: Colors.grey[400], size: 20),
                    ],
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: 12),
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () => _confirmSignOut(context, auth),
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    'Logout',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.red[600],
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  void _handleMenuTap(BuildContext context, String label) {
    switch (label) {
      case 'My Farm on Map':
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const FarmMapScreen()));
        break;
      case 'My Addresses':
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const AddressListScreen()));
        break;
      default:
        break;
    }
  }

  void _showEditSheet(
      BuildContext context, AuthProvider auth, UserModel? user) {
    showModalBottomSheet(
      context: context,
      builder: (_) => const Center(
        child: Text('Edit profile (TODO: implement)'),
      ),
    );
  }

  void _confirmSignOut(BuildContext context, AuthProvider auth) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Sign out?'),
        content: const Text('You will be returned to the login screen.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await auth.signOut();
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(
                    context, '/login', (_) => false);
              }
            },
            child: const Text('Sign out', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
