# Sync Troubleshooting Guide

## Current Issue: Sync Failed Error

The sync is failing because the backend server is not running or not accessible. Here are the solutions:

## Solution 1: Enable Mock Mode (Recommended for Testing)

The app now has mock mode enabled by default. This allows you to test all sync functionality without a backend server.

**What Mock Mode Does:**
- ✅ Simulates successful sync operations
- ✅ Updates sync status to "synced"
- ✅ Shows success messages
- ✅ Allows you to test the complete app flow

**To Use Mock Mode:**
1. Mock mode is already enabled in `lib/config/app_config.dart`
2. Just use the app normally - sync will work without a backend
3. You'll see "(mock mode)" in success messages

## Solution 2: Start the Backend Server

If you want to test with a real backend:

1. **Navigate to backend directory:**
   ```bash
   cd ../website
   ```

2. **Install dependencies (if not done):**
   ```bash
   npm install
   ```

3. **Start the backend:**
   ```bash
   npm run dev
   ```

4. **Verify backend is running:**
   - Open browser to `http://localhost:3000/api/health`
   - Should see: `{"status":"healthy",...}`

5. **Disable mock mode:**
   - Edit `lib/config/app_config.dart`
   - Change `enableMockMode = false`
   - Hot reload the app

## Solution 3: Check Network Configuration

If backend is running but sync still fails:

1. **Check the backend URL in config:**
   ```dart
   // lib/config/app_config.dart
   static const String baseUrl = 'http://localhost:3000/api';
   ```

2. **For web testing, you might need:**
   ```dart
   static const String baseUrl = 'http://127.0.0.1:3000/api';
   ```

3. **Check browser console for CORS errors**

## Current App Status

✅ **Data Persistence Fixed**: Data now persists across page refreshes using:
- Primary: Hive local database
- Backup: SharedPreferences for web compatibility
- Auto-restore from backup if Hive data is lost

✅ **Sync Status Tracking**: You can see sync status for each collection:
- 🟢 Synced: Successfully sent to server
- 🟠 Pending: Waiting to sync
- 🔴 Failed: Sync attempt failed
- 🔵 Syncing: Currently syncing
- 🟣 SMS Queued: Queued for SMS fallback

✅ **Enhanced Error Messages**: Better error reporting for sync failures

## Testing the App

1. **Add a Collection:**
   - Fill out the form with species, quantity, quality metrics
   - Click "Submit Collection"
   - You should see "✓ Data saved locally"

2. **Check History:**
   - Go to History tab
   - See your collection with sync status
   - Try the search and filter features

3. **Test Sync:**
   - Click the sync button (🔄) in history
   - With mock mode: Should show success
   - Without backend: Will show helpful error message

4. **Test Persistence:**
   - Refresh the page (F5)
   - Your data should still be there!

## Debug Information

The app now logs detailed information to the browser console:

1. **Open browser developer tools** (F12)
2. **Go to Console tab**
3. **Look for messages like:**
   - "Starting sync for event: ..."
   - "Mock mode enabled - simulating successful sync"
   - "Sync response: 200 - ..."
   - "Restored X events from backup"

## Mock Mode vs Real Backend

| Feature | Mock Mode | Real Backend |
|---------|-----------|--------------|
| Data Persistence | ✅ Local only | ✅ Local + Server |
| Sync Status | ✅ Simulated | ✅ Real |
| Offline Mode | ✅ Works | ✅ Works |
| Multi-device Sync | ❌ No | ✅ Yes |
| Analytics | ❌ Local only | ✅ Server-side |

## Recommendation

For development and testing, **keep mock mode enabled**. This allows you to:
- Test all app features
- Verify data persistence
- Test UI/UX flows
- Develop without backend dependency

When ready for production, disable mock mode and ensure backend is properly deployed.
