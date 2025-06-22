// lib/profile.dart

import 'package:flutter/material.dart';

class ProfilePageContent extends StatefulWidget {
  const ProfilePageContent({Key? key}) : super(key: key);

  @override
  State<ProfilePageContent> createState() => _ProfilePageContentState();
}

class _ProfilePageContentState extends State<ProfilePageContent> {
  // Dummy user data for demonstration
  String _userName = 'John Doe';
  String _userEmail = 'john.doe@example.com';
  String _userPhone = '+1 123 456 7890';
  String _profileImageUrl = 'https://placehold.co/150x150/007AFF/FFFFFF?text=JD'; // Placeholder image

  // Function to show a SnackBar message
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.indigo,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Profile Header Section
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.indigo.shade50,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey.shade200,
                      backgroundImage: NetworkImage(_profileImageUrl),
                      onBackgroundImageError: (exception, stacktrace) {
                        // Fallback to an icon if image fails to load
                        Image.asset('assets/images/placeholder_user.png'); // You might add a local asset
                        print('Profile image failed to load: $exception');
                      },
                      child: _profileImageUrl.isEmpty
                          ? const Icon(Icons.person, size: 60, color: Colors.grey)
                          : null,
                    ),
                    const SizedBox(height: 15),
                    Text(
                      _userName,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.blueGrey[900],
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      _userEmail,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      _userPhone,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          _showSnackBar('Edit Profile clicked!');
                          // TODO: Navigate to Edit Profile screen
                        },
                        icon: const Icon(Icons.edit, color: Colors.white),
                        label: const Text('Edit Profile', style: TextStyle(fontSize: 16)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 25),

              // Account Settings Section
              Align(

                child: Text(
                  'Account Settings',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey[800],
                  ),
                ),
              ),
              const SizedBox(height: 15),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: Column(
                  children: [
                    _buildProfileOption(
                      icon: Icons.history,
                      title: 'Order History',
                      onTap: () {
                        _showSnackBar('Order History clicked!');
                        // TODO: Navigate to Order History screen
                      },
                    ),
                    _buildDivider(),
                    _buildProfileOption(
                      icon: Icons.payment,
                      title: 'Payment Methods',
                      onTap: () {
                        _showSnackBar('Payment Methods clicked!');
                        // TODO: Navigate to Payment Methods screen
                      },
                    ),
                    _buildDivider(),
                    _buildProfileOption(
                      icon: Icons.location_on,
                      title: 'Address Book',
                      onTap: () {
                        _showSnackBar('Address Book clicked!');
                        // TODO: Navigate to Address Book screen
                      },
                    ),
                    _buildDivider(),
                    _buildProfileOption(
                      icon: Icons.settings,
                      title: 'Settings',
                      onTap: () {
                        _showSnackBar('Settings clicked!');
                        // TODO: Navigate to Settings screen
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // Logout Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    _showSnackBar('Logging out...');
                    // TODO: Implement actual logout logic (e.g., clear user session, navigate to login)
                  },
                  icon: const Icon(Icons.logout, color: Colors.red),
                  label: const Text('Logout', style: TextStyle(fontSize: 16, color: Colors.red)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: const BorderSide(color: Colors.red, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to build a profile option ListTile
  Widget _buildProfileOption({required IconData icon, required String title, required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.indigo, size: 28),
      title: Text(
        title,
        style: const TextStyle(fontSize: 17, color: Colors.black87),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
    );
  }

  // Helper method for a subtle divider
  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: Divider(
        height: 1,
        color: Colors.grey[200],
      ),
    );
  }
}