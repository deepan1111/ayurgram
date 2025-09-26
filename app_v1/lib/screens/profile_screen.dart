import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  final String collectorId;
  final String collectorName;

  const ProfileScreen({
    Key? key,
    required this.collectorId,
    required this.collectorName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Profile',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.green[800],
            ),
          ),
          SizedBox(height: 24),

          // Profile Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.green[100],
                    child: Icon(
                      Icons.person,
                      size: 50,
                      color: Colors.green[800],
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    collectorName,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Collector ID: $collectorId',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  SizedBox(height: 16),
                  _buildInfoRow(Icons.location_on, 'Region: Western Forest'),
                  _buildInfoRow(Icons.work, 'Experience: 3 years'),
                  _buildInfoRow(Icons.phone, '+91 98765 43210'),
                  _buildInfoRow(Icons.email, 'collector@example.com'),
                ],
              ),
            ),
          ),

          SizedBox(height: 24),

          // Statistics Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Collection Statistics',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  _buildStatRow('Total Collections', '156'),
                  _buildStatRow('This Month', '23'),
                  _buildStatRow('Average Rating', '4.8'),
                ],
              ),
            ),
          ),

          SizedBox(height: 24),

          // Settings Section
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.notifications),
                  title: Text('Notifications'),
                  trailing: Switch(
                    value: true,
                    onChanged: (value) {
                      // TODO: Implement notification settings
                    },
                  ),
                ),
                Divider(),
                ListTile(
                  leading: Icon(Icons.language),
                  title: Text('Language'),
                  trailing: Icon(Icons.chevron_right),
                  onTap: () {
                    // TODO: Implement language settings
                  },
                ),
                Divider(),
                ListTile(
                  leading: Icon(Icons.help),
                  title: Text('Help & Support'),
                  trailing: Icon(Icons.chevron_right),
                  onTap: () {
                    // TODO: Implement help & support
                  },
                ),
                Divider(),
                ListTile(
                  leading: Icon(Icons.logout, color: Colors.red),
                  title: Text('Logout', style: TextStyle(color: Colors.red)),
                  onTap: () {
                    // Navigate to welcome screen and remove all previous routes
                    Navigator.of(
                      context,
                    ).pushNamedAndRemoveUntil('/', (route) => false);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          SizedBox(width: 8),
          Text(text, style: TextStyle(color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600])),
          Text(
            value,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
