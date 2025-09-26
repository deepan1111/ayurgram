import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'screens/collection_screen.dart';
import 'screens/history_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/qr_scanner_screen.dart';

// Main Dashboard Screen
class CollectorDashboard extends StatefulWidget {
  final String collectorId;
  final String collectorName;

  const CollectorDashboard({
    Key? key,
    required this.collectorId,
    required this.collectorName,
  }) : super(key: key);

  @override
  State<CollectorDashboard> createState() => _CollectorDashboardState();
}

class _CollectorDashboardState extends State<CollectorDashboard> {
  int _selectedIndex = 0;
  bool _isOnline = true;
  int _pendingSyncCount = 0;

  @override
  void initState() {
    super.initState();
    _checkConnectivity();
    _loadPendingSync();
  }

  Future<void> _checkConnectivity() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    setState(() {
      _isOnline = connectivityResult.first != ConnectivityResult.none;
    });

    // Listen for connectivity changes
    Connectivity().onConnectivityChanged.listen((
      List<ConnectivityResult> results,
    ) {
      final result = results.first;
      setState(() {
        _isOnline = result != ConnectivityResult.none;
      });
      if (_isOnline) {
        _syncOfflineData();
      }
    });
  }

  Future<void> _loadPendingSync() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _pendingSyncCount = prefs.getInt('pending_sync_count') ?? 0;
    });
  }

  Future<void> _syncOfflineData() async {
    // Sync offline data when connection is restored
    if (_pendingSyncCount > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Syncing $_pendingSyncCount offline records...'),
          backgroundColor: Colors.orange,
        ),
      );
      // Add sync logic here
      await Future.delayed(Duration(seconds: 2));
      setState(() {
        _pendingSyncCount = 0;
      });
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('pending_sync_count', 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header with connectivity status
            _buildHeader(),
            // Main content area
            Expanded(
              child: IndexedStack(
                index: _selectedIndex,
                children: [
                  _buildHomeView(),
                  CollectionScreen(collectorId: widget.collectorId),
                  HistoryScreen(collectorId: widget.collectorId),
                  ProfileScreen(
                    collectorId: widget.collectorId,
                    collectorName: widget.collectorName,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome back,',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              Text(
                widget.collectorName,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[800],
                ),
              ),
            ],
          ),
          Row(
            children: [
              if (_pendingSyncCount > 0)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.sync, size: 16, color: Colors.white),
                      SizedBox(width: 4),
                      Text(
                        '$_pendingSyncCount',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              SizedBox(width: 8),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _isOnline ? Colors.green : Colors.red,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(
                      _isOnline ? Icons.wifi : Icons.wifi_off,
                      size: 16,
                      color: Colors.white,
                    ),
                    SizedBox(width: 4),
                    Text(
                      _isOnline ? 'Online' : 'Offline',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHomeView() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quick Actions
          Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.green[800],
            ),
          ),
          SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.2,
            children: [
              _buildQuickActionCard(
                icon: Icons.add_location_alt,
                title: 'New Collection',
                subtitle: 'Record harvest',
                color: Colors.green,
                onTap: () {
                  setState(() {
                    _selectedIndex = 1;
                  });
                },
              ),
              _buildQuickActionCard(
                icon: Icons.qr_code_scanner,
                title: 'Scan QR',
                subtitle: 'Verify batch',
                color: Colors.blue,
                onTap: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => QRScannerScreen()),
                  );
                  if (result != null) {
                    // Handle the scanned QR code result
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('QR Code scanned: $result'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                },
              ),
              _buildQuickActionCard(
                icon: Icons.history,
                title: 'Recent Activity',
                subtitle: 'View history',
                color: Colors.orange,
                onTap: () {
                  setState(() {
                    _selectedIndex = 2;
                  });
                },
              ),
              _buildQuickActionCard(
                icon: Icons.sync,
                title: 'Sync Data',
                subtitle: _pendingSyncCount > 0
                    ? '$_pendingSyncCount pending'
                    : 'All synced',
                color: Colors.purple,
                onTap: _isOnline ? _syncOfflineData : null,
              ),
            ],
          ),
          SizedBox(height: 24),

          // Today's Summary
          Text(
            'Today\'s Summary',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.green[800],
            ),
          ),
          SizedBox(height: 16),
          _buildSummaryCard(),

          SizedBox(height: 24),

          // Compliance Status
          Text(
            'Compliance Status',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.green[800],
            ),
          ),
          SizedBox(height: 16),
          _buildComplianceCard(),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 3,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green[400]!, Colors.green[600]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryItem('Collections', '12', Icons.grass),
          _buildSummaryItem('Weight (kg)', '45.5', Icons.scale),
          _buildSummaryItem('Species', '3', Icons.eco),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(label, style: TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }

  Widget _buildComplianceCard() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildComplianceItem(
            'Harvest Zone',
            'Approved',
            Icons.check_circle,
            Colors.green,
          ),
          Divider(height: 24),
          _buildComplianceItem(
            'Seasonal Restrictions',
            'Compliant',
            Icons.check_circle,
            Colors.green,
          ),
          Divider(height: 24),
          _buildComplianceItem(
            'Conservation Limits',
            '60% Used',
            Icons.info,
            Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildComplianceItem(
    String title,
    String status,
    IconData icon,
    Color color,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 20),
            SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
          ],
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            status,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNavigation() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: (index) {
        setState(() {
          _selectedIndex = index;
        });
      },
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.green[700],
      unselectedItemColor: Colors.grey[400],
      items: [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(
          icon: Icon(Icons.add_circle_outline),
          label: 'Collect',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ],
    );
  }
}
