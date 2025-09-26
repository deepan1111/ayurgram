# AyurTrack Collector App - Quick Setup Guide

## 🚀 Quick Start

### 1. Prerequisites Check
```bash
# Check Flutter installation
flutter doctor

# Ensure you have:
# ✓ Flutter SDK 3.9.2+
# ✓ Android toolchain
# ✓ VS Code or Android Studio
# ✓ Connected device or emulator
```

### 2. Flutter App Setup
```bash
# Navigate to Flutter app
cd app_v1

# Install dependencies
flutter pub get

# Generate Hive adapters (IMPORTANT!)
flutter packages pub run build_runner build

# If you get conflicts:
flutter packages pub run build_runner build --delete-conflicting-outputs
```

### 3. Configure Backend URL
Edit `lib/config/app_config.dart`:
```dart
static const String baseUrl = 'http://your-backend-url:3000/api';
static const String smsGatewayNumber = '+1234567890'; // Your SMS gateway
```

### 4. Run the App
```bash
# Development mode
flutter run

# Release mode
flutter run --release
```

### 5. Backend Setup (Optional)
```bash
# Navigate to backend
cd ../website

# Install dependencies
npm install

# Start development server
npm run dev
```

## 📱 What's New in This Enhanced Version

### ✅ Core Improvements Completed

1. **Unique ID System**
   - UUID-based event IDs
   - Unique collector identifiers
   - Consistent ID management across offline/online

2. **Enhanced Data Model**
   - Comprehensive `CollectionEvent` model
   - Quality metrics (freshness, purity, size)
   - GPS location with accuracy tracking
   - FHIR-compatible metadata structure

3. **Offline-First Architecture**
   - Hive local database integration
   - Automatic data persistence
   - Intelligent sync when online
   - SMS fallback for critical data

4. **Advanced Collection Form**
   - Quality assessment sliders (1-10 scale)
   - Real-time GPS accuracy display
   - Form validation and error handling
   - Connectivity status indicator

5. **Enhanced History Screen**
   - Statistics dashboard
   - Search and filtering capabilities
   - Sync status tracking
   - Detailed collection views

6. **Robust Backend APIs**
   - MongoDB with geospatial indexing
   - Collection event CRUD operations
   - Collector history with analytics
   - Health check endpoints

7. **Smart Sync System**
   - Automatic retry with backoff
   - Batch synchronization
   - Connection health monitoring
   - Manual sync triggers

8. **SMS Fallback System**
   - Automatic SMS payload generation
   - Message splitting for long data
   - Permission handling
   - Gateway integration ready

## 🎯 Key Features Overview

### Data Capture
- ✅ Automatic GPS (lat, lng, altitude, accuracy, timestamp)
- ✅ Plant species input with validation
- ✅ Quantity tracking in kilograms
- ✅ Collection notes
- ✅ Quality metrics (freshness, purity, size)
- ✅ Additional quality observations

### Offline Capabilities
- ✅ Local Hive database storage
- ✅ Offline data persistence
- ✅ SMS fallback transmission
- ✅ Auto-sync when online
- ✅ Sync status tracking

### User Interface
- ✅ Modern, intuitive design
- ✅ Real-time connectivity status
- ✅ Quality assessment sliders
- ✅ Enhanced history with search/filter
- ✅ Statistics dashboard
- ✅ Loading states and progress indicators

### Backend Integration
- ✅ RESTful APIs with MongoDB
- ✅ Geospatial indexing for location queries
- ✅ FHIR-style metadata bundles
- ✅ Comprehensive analytics
- ✅ Health monitoring

## 📊 Architecture Overview

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   Flutter App   │    │   Local Storage  │    │   Backend API   │
│                 │    │                  │    │                 │
│ • Collection UI │◄──►│ • Hive Database  │◄──►│ • MongoDB       │
│ • History View  │    │ • Offline Data   │    │ • Geospatial    │
│ • Sync Service  │    │ • Statistics     │    │ • Analytics     │
│ • SMS Fallback  │    │ • Settings       │    │ • Health Check  │
└─────────────────┘    └──────────────────┘    └─────────────────┘
         │                       │                       │
         └───────────────────────┼───────────────────────┘
                                 │
                    ┌──────────────────┐
                    │   SMS Gateway    │
                    │ • Offline Backup │
                    │ • Critical Data  │
                    └──────────────────┘
```

## 🔧 Configuration Files

### App Configuration
- `lib/config/app_config.dart` - Main app settings
- `lib/config/mongodb_config.dart` - Database configuration
- `pubspec.yaml` - Dependencies and assets

### Backend Configuration
- `src/app/api/collections/route.ts` - Collection APIs
- `src/app/api/collector/[id]/history/route.ts` - History APIs
- `src/app/api/health/route.ts` - Health check
- `.env.local` - Environment variables

## 🚨 Important Notes

### Before Building for Production:
1. ✅ Generate Hive adapters: `flutter packages pub run build_runner build`
2. ✅ Update backend URL in `app_config.dart`
3. ✅ Configure SMS gateway number
4. ✅ Test offline functionality
5. ✅ Verify GPS permissions
6. ✅ Test SMS permissions (on physical device)

### Required Permissions (Android):
```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.SEND_SMS" />
<uses-permission android:name="android.permission.READ_SMS" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
```

## 📈 Performance & Scalability

### Local Storage
- Efficient Hive database
- Automatic cleanup of old synced data
- Statistics caching
- Export/import capabilities

### Sync Optimization
- Batch operations
- Retry with exponential backoff
- Connection health checks
- Background sync scheduling

### Memory Management
- Lazy loading of collections
- Pagination support
- Image optimization (when added)
- Efficient state management

## 🔮 Ready for Future Enhancements

The architecture is designed to easily support:
- 📷 Photo capture for species verification
- 🔗 Blockchain integration for immutable records
- 🌐 Multi-language support
- 📊 Advanced analytics dashboard
- 🌤️ Weather data integration
- 👥 Multi-collector coordination

## 🎉 Success Metrics

Your enhanced Collector App now provides:

✅ **100% Offline Capability** - Works without internet  
✅ **SMS Backup** - Critical data never lost  
✅ **Quality Tracking** - Detailed assessments  
✅ **Real-time Sync** - Automatic when online  
✅ **Geospatial Ready** - Location-based features  
✅ **FHIR Compatible** - Healthcare standards ready  
✅ **Production Ready** - Robust error handling  
✅ **Rural Friendly** - Designed for low connectivity areas  

## 📞 Next Steps

1. **Test the enhanced app** with the new features
2. **Configure your backend URL** in the config file
3. **Generate Hive adapters** before building
4. **Test offline functionality** thoroughly
5. **Deploy to your target environment**

The app is now significantly more robust and feature-complete while maintaining all your existing functionality!
