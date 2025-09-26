import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/collection_event.dart';
import '../services/local_storage_service.dart';
import '../services/sync_service.dart';
import '../services/sms_service.dart';

class CollectionScreen extends StatefulWidget {
  final String collectorId;

  const CollectionScreen({Key? key, required this.collectorId})
    : super(key: key);

  @override
  State<CollectionScreen> createState() => _CollectionScreenState();
}

class _CollectionScreenState extends State<CollectionScreen> {
  Position? _currentPosition;
  bool _isLoading = false;
  bool _isSubmitting = false;
  bool _isOnline = true;

  // Form controllers
  final _formKey = GlobalKey<FormState>();
  final _speciesController = TextEditingController();
  final _quantityController = TextEditingController();
  final _notesController = TextEditingController();
  final _additionalNotesController = TextEditingController();

  // Quality metrics
  int _freshnessRating = 5;
  int _purityRating = 5;
  int _sizeRating = 5;

  // Services
  final LocalStorageService _localStorage = LocalStorageService.instance;
  final SyncService _syncService = SyncService.instance;
  final SMSService _smsService = SMSService.instance;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _checkConnectivity();
  }

  @override
  void dispose() {
    _speciesController.dispose();
    _quantityController.dispose();
    _notesController.dispose();
    _additionalNotesController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoading = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw 'Location services are disabled';
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw 'Location permissions are denied';
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw 'Location permissions are permanently denied';
      }

      final position = await Geolocator.getCurrentPosition();
      setState(() => _currentPosition = position);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _checkConnectivity() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    setState(() {
      _isOnline = connectivityResult.first != ConnectivityResult.none;
    });

    // Listen for connectivity changes
    Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
      final result = results.first;
      setState(() {
        _isOnline = result != ConnectivityResult.none;
      });
    });
  }

  Future<void> _submitCollection() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_currentPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please wait for location to be acquired')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // Create GPS location
      final gpsLocation = GPSLocation(
        latitude: _currentPosition!.latitude,
        longitude: _currentPosition!.longitude,
        altitude: _currentPosition!.altitude,
        accuracy: _currentPosition!.accuracy,
      );

      // Create quality metrics
      final qualityMetrics = QualityMetrics(
        freshness: _freshnessRating,
        purity: _purityRating,
        size: _sizeRating,
        additionalNotes: _additionalNotesController.text.trim().isEmpty 
            ? null 
            : _additionalNotesController.text.trim(),
      );

      // Create collection event
      final collectionEvent = CollectionEvent(
        collectorId: widget.collectorId,
        gps: gpsLocation,
        species: _speciesController.text.trim(),
        quantity: double.parse(_quantityController.text.trim()),
        notes: _notesController.text.trim(),
        qualityMetrics: qualityMetrics,
      );

      // Save locally first
      await _localStorage.saveCollectionEvent(collectionEvent);
      
      // Show confirmation that data is saved locally
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✓ Data saved locally'),
          duration: Duration(seconds: 1),
          backgroundColor: Colors.green,
        ),
      );

      // Try to sync immediately if online
      if (_isOnline) {
        final syncResult = await _syncService.syncCollectionEvent(collectionEvent);
        if (syncResult.success) {
          _showSuccessDialog('Collection saved and synced successfully!');
        } else {
          _showSuccessDialog('Collection saved locally. Will sync when online.');
        }
      } else {
        // Queue for SMS if offline
        await _syncService.queueForSMSTransmission(collectionEvent);
        _showOfflineDialog(collectionEvent);
      }

      // Clear form
      _clearForm();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving collection: ${e.toString()}')),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  void _clearForm() {
    _speciesController.clear();
    _quantityController.clear();
    _notesController.clear();
    _additionalNotesController.clear();
    setState(() {
      _freshnessRating = 5;
      _purityRating = 5;
      _sizeRating = 5;
    });
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Success'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showOfflineDialog(CollectionEvent event) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Offline Mode'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Collection saved locally. You can:'),
            const SizedBox(height: 8),
            const Text('• Wait for internet connection to sync'),
            const Text('• Send via SMS now'),
            const SizedBox(height: 16),
            const Text('SMS Payload:'),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                event.generateSMSPayload(),
                style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Later'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final result = await _smsService.sendCollectionEventSMS(event);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(result.success 
                      ? 'SMS sent successfully!' 
                      : 'SMS failed: ${result.error}'),
                ),
              );
            },
            child: const Text('Send SMS'),
          ),
        ],
      ),
    );
  }

  Widget _buildQualitySlider(String label, int value, ValueChanged<int> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label: $value/10',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        Slider(
          value: value.toDouble(),
          min: 1,
          max: 10,
          divisions: 9,
          label: value.toString(),
          onChanged: (double newValue) => onChanged(newValue.round()),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with connectivity status
            Row(
              children: [
                Expanded(
                  child: Text(
                    'New Collection',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[800],
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _isOnline ? Colors.green : Colors.orange,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _isOnline ? Icons.cloud_done : Icons.cloud_off,
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _isOnline ? 'Online' : 'Offline',
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Location Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.location_on, color: Colors.green),
                        const SizedBox(width: 8),
                        const Text(
                          'Current Location',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (_isLoading)
                      const Center(child: CircularProgressIndicator())
                    else if (_currentPosition != null)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Lat: ${_currentPosition!.latitude.toStringAsFixed(6)}',
                            style: const TextStyle(fontSize: 16),
                          ),
                          Text(
                            'Long: ${_currentPosition!.longitude.toStringAsFixed(6)}',
                            style: const TextStyle(fontSize: 16),
                          ),
                          if (_currentPosition!.accuracy != null)
                            Text(
                              'Accuracy: ±${_currentPosition!.accuracy!.toStringAsFixed(1)}m',
                              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                            ),
                        ],
                      )
                    else
                      TextButton.icon(
                        onPressed: _getCurrentLocation,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Get Location'),
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Collection Form
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _speciesController,
                      decoration: const InputDecoration(
                        labelText: 'Plant Species *',
                        border: OutlineInputBorder(),
                        hintText: 'e.g., Ashwagandha, Tulsi, Neem',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter the plant species';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _quantityController,
                      decoration: const InputDecoration(
                        labelText: 'Quantity (kg) *',
                        border: OutlineInputBorder(),
                        hintText: 'e.g., 2.5',
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter the quantity';
                        }
                        final quantity = double.tryParse(value.trim());
                        if (quantity == null || quantity <= 0) {
                          return 'Please enter a valid quantity';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _notesController,
                      decoration: const InputDecoration(
                        labelText: 'Collection Notes',
                        border: OutlineInputBorder(),
                        hintText: 'Additional information about the collection...',
                      ),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Quality Metrics Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Quality Assessment',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildQualitySlider(
                      'Freshness',
                      _freshnessRating,
                      (value) => setState(() => _freshnessRating = value),
                    ),
                    _buildQualitySlider(
                      'Purity',
                      _purityRating,
                      (value) => setState(() => _purityRating = value),
                    ),
                    _buildQualitySlider(
                      'Size/Maturity',
                      _sizeRating,
                      (value) => setState(() => _sizeRating = value),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _additionalNotesController,
                      decoration: const InputDecoration(
                        labelText: 'Quality Notes (Optional)',
                        border: OutlineInputBorder(),
                        hintText: 'Any specific observations about quality...',
                      ),
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitCollection,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isSubmitting
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                          SizedBox(width: 12),
                          Text('Submitting...'),
                        ],
                      )
                    : const Text(
                        'Submit Collection',
                        style: TextStyle(fontSize: 16),
                      ),
              ),
            ),
            
            // Add some bottom padding to ensure content doesn't get cut off
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}