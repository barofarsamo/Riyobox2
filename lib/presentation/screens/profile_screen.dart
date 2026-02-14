import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:riyobox/providers/auth_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF1C1C2A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1C1C2A),
        title: const Text('My Profile', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          TextButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Profile updated successfully!')),
              );
            },
            child: const Text('SAVE', style: TextStyle(color: Colors.yellow, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildProfileImage(),
            const SizedBox(height: 24),
            _buildProfileField('Full Name', auth.isAuthenticated ? 'User' : 'Guest'),
            _buildProfileField('Email', auth.isAuthenticated ? 'user@example.com' : 'Not signed in'),
            _buildProfileField('Role', auth.role ?? 'N/A'),
            const SizedBox(height: 32),
            _buildActionItem(
              context,
              title: 'Change Password',
              icon: Icons.lock_outline,
              onTap: () {},
            ),
            _buildActionItem(
              context,
              title: 'Watch History',
              icon: Icons.history,
              onTap: () => context.push('/my-riyobox'),
            ),
            _buildActionItem(
              context,
              title: 'App Settings',
              icon: Icons.settings_outlined,
              onTap: () => context.push('/settings'),
            ),
             _buildActionItem(
              context,
              title: 'Payment Methods',
              icon: Icons.payment,
              onTap: () {},
            ),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ListTile(
                tileColor: Colors.red.withAlpha(25),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text('Sign Out', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.red),
                onTap: () {
                  _showLogoutDialog(context, auth);
                },
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileImage() {
    return Center(
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.yellow, width: 2),
            ),
            child: const CircleAvatar(
              radius: 60,
              backgroundImage: NetworkImage('https://picsum.photos/seed/profile/200/200'),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Colors.yellow,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.camera_alt, color: Colors.black, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 4),
          TextField(
            controller: TextEditingController(text: value),
            style: const TextStyle(color: Colors.white, fontSize: 16),
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFF2A2A3A),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.yellow, width: 1),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionItem(BuildContext context, {required String title, required IconData icon, required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.yellow),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: onTap,
    );
  }

  void _showLogoutDialog(BuildContext context, AuthProvider auth) {
     showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A3A),
        title: const Text('Sign Out', style: TextStyle(color: Colors.white)),
        content: const Text('Are you sure you want to sign out?', style: TextStyle(color: Colors.grey)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(color: Colors.white))),
          TextButton(
            onPressed: () {
              auth.logout();
              context.go('/login');
            },
            child: const Text('Sign Out', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
  }
}
