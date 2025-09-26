import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/collection_event.dart';
import '../services/local_storage_service.dart';
import '../services/sync_service.dart';

class HistoryScreen extends StatefulWidget {
  final String collectorId;

  const HistoryScreen({Key? key, required this.collectorId}) : super(key: key);

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<CollectionEvent> _collections = [];
  List<CollectionEvent> _filteredCollections = [];
  bool _isLoading = true;
  bool _isOnline = true;
  String _selectedFilter = 'All';
  String _searchQuery = '';
  
  final LocalStorageService _localStorage = LocalStorageService.instance;
  final SyncService _syncService = SyncService.instance;
  final TextEditingController _searchController = TextEditingController();
  
  Map<String, dynamic> _statistics = {};

  @override
  void initState() {
    super.initState();
    _checkConnectivity();
    _loadCollections();
    _loadStatistics();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _checkConnectivity() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    setState(() {
      _isOnline = connectivityResult.first != ConnectivityResult.none;
    });
  }

  Future<void> _loadCollections() async {
    setState(() => _isLoading = true);
    
    try {
      List<CollectionEvent> collections;
      
      if (_isOnline) {
        // Try to fetch from server first, fallback to local
        collections = await _syncService.fetchCollectionHistory(widget.collectorId);
      } else {
        // Load from local storage
        collections = await _localStorage.getCollectionEventsByCollector(widget.collectorId);
      }
      
      setState(() {
        _collections = collections;
        _filteredCollections = collections;
        _isLoading = false;
      });
      
      _applyFilters();
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading collections: ${e.toString()}')),
      );
    }
  }

  Future<void> _loadStatistics() async {
    final stats = await _localStorage.getCollectionStatistics(widget.collectorId);
    setState(() => _statistics = stats);
  }

  void _applyFilters() {
    List<CollectionEvent> filtered = _collections;
    
    // Apply status filter
    if (_selectedFilter != 'All') {
      SyncStatus status = SyncStatus.values.firstWhere(
        (s) => s.toString().split('.').last.toLowerCase() == _selectedFilter.toLowerCase(),
        orElse: () => SyncStatus.synced,
      );
      filtered = filtered.where((c) => c.syncStatus == status).toList();
    }
    
    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((c) => 
        c.species.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        c.notes.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }
    
    setState(() => _filteredCollections = filtered);
  }

  void _onSearchChanged(String query) {
    setState(() => _searchQuery = query);
    _applyFilters();
  }

  void _onFilterChanged(String filter) {
    setState(() => _selectedFilter = filter);
    _applyFilters();
  }

  Future<void> _syncPendingEvents() async {
    // Show loading indicator
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            ),
            SizedBox(width: 12),
            Text('Syncing data...'),
          ],
        ),
        duration: Duration(seconds: 2),
      ),
    );
    
    final result = await _syncService.syncAllPendingEvents();
    
    // Show result
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result.message ?? (result.success ? 'Sync completed successfully!' : 'Sync failed')),
        backgroundColor: result.success ? Colors.green : Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
    
    // Reload data
    _loadCollections();
    _loadStatistics();
  }

  Color _getStatusColor(SyncStatus status) {
    switch (status) {
      case SyncStatus.synced:
        return Colors.green;
      case SyncStatus.pending:
        return Colors.orange;
      case SyncStatus.failed:
        return Colors.red;
      case SyncStatus.syncing:
        return Colors.blue;
      case SyncStatus.smsQueued:
        return Colors.purple;
      case SyncStatus.smsSent:
        return Colors.teal;
    }
  }

  String _getStatusText(SyncStatus status) {
    switch (status) {
      case SyncStatus.synced:
        return 'Synced';
      case SyncStatus.pending:
        return 'Pending';
      case SyncStatus.failed:
        return 'Failed';
      case SyncStatus.syncing:
        return 'Syncing';
      case SyncStatus.smsQueued:
        return 'SMS Queued';
      case SyncStatus.smsSent:
        return 'SMS Sent';
    }
  }

  Widget _buildStatisticsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Statistics',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Total Events',
                    _statistics['totalEvents']?.toString() ?? '0',
                    Icons.event,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Total Quantity',
                    '${_statistics['totalQuantity']?.toStringAsFixed(1) ?? '0'} kg',
                    Icons.scale,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Species',
                    _statistics['speciesCount']?.toString() ?? '0',
                    Icons.eco,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Pending Sync',
                    _statistics['pendingEvents']?.toString() ?? '0',
                    Icons.sync_problem,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.green[600]),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildCollectionCard(CollectionEvent collection) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showCollectionDetails(collection),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      collection.species,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(collection.syncStatus).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _getStatusColor(collection.syncStatus),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      _getStatusText(collection.syncStatus),
                      style: TextStyle(
                        color: _getStatusColor(collection.syncStatus),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    '${collection.timestamp.day}/${collection.timestamp.month}/${collection.timestamp.year}',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    '${collection.timestamp.hour.toString().padLeft(2, '0')}:${collection.timestamp.minute.toString().padLeft(2, '0')}',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.scale, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text('${collection.quantity} kg'),
                  const SizedBox(width: 16),
                  Icon(Icons.star, size: 16, color: Colors.amber),
                  const SizedBox(width: 8),
                  Text(
                    '${((collection.qualityMetrics.freshness + collection.qualityMetrics.purity + collection.qualityMetrics.size) / 3).toStringAsFixed(1)}/10',
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${collection.gps.latitude.toStringAsFixed(4)}, ${collection.gps.longitude.toStringAsFixed(4)}',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                ],
              ),
              if (collection.notes.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  collection.notes,
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontStyle: FontStyle.italic,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showCollectionDetails(CollectionEvent collection) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(collection.species),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Event ID', collection.eventId),
              _buildDetailRow('Quantity', '${collection.quantity} kg'),
              _buildDetailRow('Date', collection.timestamp.toString()),
              _buildDetailRow('Status', _getStatusText(collection.syncStatus)),
              const SizedBox(height: 16),
              const Text('Quality Metrics:', style: TextStyle(fontWeight: FontWeight.bold)),
              _buildDetailRow('Freshness', '${collection.qualityMetrics.freshness}/10'),
              _buildDetailRow('Purity', '${collection.qualityMetrics.purity}/10'),
              _buildDetailRow('Size', '${collection.qualityMetrics.size}/10'),
              const SizedBox(height: 16),
              const Text('Location:', style: TextStyle(fontWeight: FontWeight.bold)),
              _buildDetailRow('Latitude', collection.gps.latitude.toString()),
              _buildDetailRow('Longitude', collection.gps.longitude.toString()),
              if (collection.gps.accuracy != null)
                _buildDetailRow('Accuracy', '±${collection.gps.accuracy!.toStringAsFixed(1)}m'),
              if (collection.notes.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text('Notes:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(collection.notes),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with sync button
          Row(
            children: [
              Expanded(
                child: Text(
                  'Collection History',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[800],
                  ),
                ),
              ),
              if (_isOnline)
                IconButton(
                  onPressed: _syncPendingEvents,
                  icon: const Icon(Icons.sync),
                  tooltip: 'Sync pending events',
                ),
            ],
          ),
          const SizedBox(height: 16),

          // Statistics card
          _buildStatisticsCard(),
          const SizedBox(height: 16),

          // Search and filter
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: 'Search species or notes...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  onChanged: _onSearchChanged,
                ),
              ),
              const SizedBox(width: 12),
              DropdownButton<String>(
                value: _selectedFilter,
                items: ['All', 'Synced', 'Pending', 'Failed', 'SMS Queued']
                    .map((filter) => DropdownMenuItem(
                          value: filter,
                          child: Text(filter),
                        ))
                    .toList(),
                onChanged: (value) => _onFilterChanged(value!),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Collections list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredCollections.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.history,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No collections found',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: _filteredCollections.length,
                        itemBuilder: (context, index) {
                          return _buildCollectionCard(_filteredCollections[index]);
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
