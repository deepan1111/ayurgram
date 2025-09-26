# AyurTrack Collector App - Enhanced Version

## Overview

The AyurTrack Collector App is a comprehensive Flutter-based mobile application designed for medicinal plant collectors in rural areas. This enhanced version includes offline-first functionality, SMS fallback, quality metrics tracking, and robust synchronization capabilities.

## 🚀 Key Features

### ✅ Completed Enhancements

1. **Unique ID Generation**
   - Each collection event has a UUID-based unique identifier
   - Each collector has a unique collector ID
   - Event IDs are preserved across offline/online operations

2. **Enhanced Data Capture**
   - Automatic GPS capture (latitude, longitude, altitude, accuracy, timestamp)
   - Plant species input with validation
   - Quantity tracking in kilograms
   - Comprehensive notes field
   - **NEW**: Quality metrics (freshness, purity, size/maturity on 1-10 scale)
   - **NEW**: Additional quality notes

3. **Offline-First Architecture**
   - Local storage using Hive database
   - Data persists locally when offline
   - Automatic sync when internet becomes available
   - **NEW**: SMS fallback for critical data transmission
   - **NEW**: Comprehensive sync status tracking

4. **Enhanced UI/UX**
   - Real-time connectivity status indicator
   - Quality assessment sliders
   - Improved form validation
   - Loading states and progress indicators
   - **NEW**: Enhanced history screen with filtering and search
   - **NEW**: Statistics dashboard
   - **NEW**: Detailed collection event views

5. **Backend Integration**
   - RESTful API with MongoDB
   - **NEW**: Geospatial indexing for location-based queries
   - **NEW**: FHIR-style metadata bundles
   - **NEW**: Comprehensive collection history API
   - **NEW**: Health check endpoints

## 📱 App Structure

### Core Models

#### CollectionEvent
```dart
class CollectionEvent {
  final String eventId;           // UUID
  final String collectorId;       // Collector identifier
  final GPSLocation gps;          // Location data
  final String species;           // Plant species name
  final double quantity;          // Quantity in kg
  final String notes;             // Collection notes
  final QualityMetrics qualityMetrics; // Quality assessment
  final DateTime timestamp;       // Collection time
  final SyncStatus syncStatus;    // Sync state
  final String? smsPayload;       // SMS backup data
}
```

#### QualityMetrics
```dart
class QualityMetrics {
  final int freshness;      // 1-10 scale
  final int purity;         // 1-10 scale  
  final int size;           // 1-10 scale
  final String? additionalNotes;
}
```

#### SyncStatus
```dart
enum SyncStatus {
  pending,    // Waiting to sync
  syncing,    // Currently syncing
  synced,     // Successfully synced
  failed,     // Sync failed
  smsQueued,  // Queued for SMS
  smsSent     // SMS sent
}
```

### Services Architecture

#### LocalStorageService
- Hive-based local database
- Offline data persistence
- Statistics calculation
- Data export/import capabilities

#### SyncService  
- Backend synchronization
- Retry logic with exponential backoff
- Batch sync operations
- Connection health monitoring

#### SMSService
- SMS fallback for offline scenarios
- Message splitting for long payloads
- Permission handling
- Gateway integration ready

## 🛠️ Setup Instructions

### Prerequisites
- Flutter SDK (3.9.2+)
- Dart SDK
- Android Studio / VS Code
- Node.js (for backend)
- MongoDB

### Flutter App Setup

1. **Install Dependencies**
   ```bash
   cd app_v1
   flutter pub get
   ```

2. **Generate Hive Adapters**
   ```bash
   flutter packages pub run build_runner build
   ```

3. **Configure Backend URL**
   - Edit `lib/config/app_config.dart`
   - Update `baseUrl` with your backend URL
   - Configure SMS gateway number

4. **Run the App**
   ```bash
   flutter run
   ```

### Backend Setup

1. **Install Dependencies**
   ```bash
   cd ../website
   npm install
   ```

2. **Configure Environment**
   - Create `.env.local` file
   - Add MongoDB connection string
   - Configure other environment variables

3. **Start Backend**
   ```bash
   npm run dev
   ```

## 📊 API Endpoints

### Collection Events
- `POST /api/collections` - Create/update collection event
- `GET /api/collections` - Get collections with filtering
- `GET /api/collector/{id}/history` - Get collector history
- `POST /api/collector/{id}/history` - Get nearby collections

### Health & Monitoring
- `GET /api/health` - Health check endpoint

### Authentication
- `POST /api/auth/signup` - User registration
- `POST /api/auth/login` - User authentication

## 🔄 Sync Process

### Online Mode
1. Data captured and saved locally
2. Immediate sync attempt to backend
3. Status updated based on result
4. Retry failed syncs periodically

### Offline Mode
1. Data saved locally with pending status
2. SMS payload generated for critical data
3. Option to send SMS immediately
4. Auto-sync when connection restored

### SMS Fallback Format
```
AYUR:{eventId}:{collectorId}:{lat}:{lng}:{species}:{quantity}:{freshness}:{purity}:{timestamp}
```

## 📈 Quality Metrics

The app now captures detailed quality assessments:

- **Freshness** (1-10): How fresh the collected material is
- **Purity** (1-10): Absence of contaminants or foreign matter
- **Size/Maturity** (1-10): Appropriate size and maturity level
- **Additional Notes**: Free-form quality observations

## 🗺️ Geospatial Features

- Automatic GPS coordinate capture
- Accuracy measurement and display
- Geospatial indexing in MongoDB
- Nearby collection queries
- Location-based filtering

## 📱 Enhanced History Screen

### Features
- Real-time statistics dashboard
- Search by species or notes
- Filter by sync status
- Detailed collection views
- Manual sync trigger
- Export capabilities

### Statistics Tracked
- Total collection events
- Total quantity collected
- Number of unique species
- Sync status breakdown
- Average quality ratings

## 🔧 Configuration

### App Configuration (`lib/config/app_config.dart`)
- Backend URLs and endpoints
- SMS gateway settings
- Sync parameters
- UI preferences
- Feature flags

### Key Settings
```dart
static const String baseUrl = 'your-backend-url';
static const String smsGatewayNumber = 'your-sms-gateway';
static const int syncTimeoutSeconds = 30;
static const int periodicSyncIntervalMinutes = 5;
```

## 🚨 Error Handling

### Network Errors
- Automatic retry with exponential backoff
- Graceful degradation to offline mode
- User-friendly error messages

### Data Validation
- Form validation for required fields
- GPS coordinate validation
- Quality metrics range validation

### Sync Failures
- Failed events marked for retry
- Manual sync options
- SMS fallback activation

## 🔐 Security Considerations

### Data Protection
- Local data encrypted with Hive
- Secure API communication
- Authentication token management

### Privacy
- GPS data only collected when needed
- User consent for location services
- Data retention policies

## 🧪 Testing

### Unit Tests
```bash
flutter test
```

### Integration Tests
```bash
flutter test integration_test/
```

### Backend Tests
```bash
cd ../website
npm test
```

## 📦 Deployment

### Flutter App
1. Build release APK:
   ```bash
   flutter build apk --release
   ```

2. Build App Bundle:
   ```bash
   flutter build appbundle --release
   ```

### Backend Deployment
1. Configure production environment
2. Set up MongoDB Atlas
3. Deploy to your preferred platform (Vercel, Heroku, etc.)

## 🔮 Future Enhancements

### Planned Features
- [ ] Blockchain integration for immutable records
- [ ] Advanced analytics dashboard
- [ ] Multi-language support
- [ ] Photo capture for species verification
- [ ] Weather data integration
- [ ] Collector performance metrics

### FHIR Integration
The app is prepared for FHIR (Fast Healthcare Interoperability Resources) integration:
- FHIR-style metadata bundles
- Observation resources for collections
- Location resources for GPS data
- Extensible for healthcare standards

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 📞 Support

For support and questions:
- Create an issue in the repository
- Contact the development team
- Check the documentation wiki

---

## 🎯 Key Improvements Summary

This enhanced version provides:

✅ **Robust offline functionality** with Hive local storage  
✅ **SMS fallback** for critical data transmission  
✅ **Quality metrics tracking** with detailed assessments  
✅ **Enhanced UI/UX** with real-time status indicators  
✅ **Comprehensive sync system** with retry logic  
✅ **Geospatial indexing** for location-based queries  
✅ **FHIR-ready architecture** for healthcare standards  
✅ **Statistics and analytics** dashboard  
✅ **Modular architecture** ready for blockchain integration  

The app is now production-ready for rural deployment with excellent offline capabilities and user experience.
