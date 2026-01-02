# 🧹 Cleanup Instructions - 5 Minutes

## ⚡ Quick Cleanup Guide

### Issue Found
- 1 placeholder file to delete
- 2 files to rename (farmer-specific)
- Multiple import updates needed

---

## 🔴 Step 1: Delete Placeholder File (1 minute)

**File to delete:**
```
lib/screens/kisan_doctor_screen.dart
```

**Why?** It's just a "Coming Soon" placeholder. The real implementation is in `lib/screens/kisan_doctor/kisan_doctor_dashboard_screen.dart`

**How to delete:**
- Right-click file → Delete
- Or use terminal: `rm lib/screens/kisan_doctor_screen.dart`

---

## 🟡 Step 2: Rename Farmer Notifications (1 minute)

**File to rename:**
```
lib/screens/notifications_screen.dart
```

**Rename to:**
```
lib/screens/farmer_notifications_screen.dart
```

**Why?** To avoid conflict with `lib/screens/kisan_doctor/notifications_screen.dart`

**How to rename:**
- Right-click → Rename
- Or use terminal: `mv lib/screens/notifications_screen.dart lib/screens/farmer_notifications_screen.dart`

---

## 🟡 Step 3: Rename Farmer Profile (1 minute)

**File to rename:**
```
lib/screens/profile_screen.dart
```

**Rename to:**
```
lib/screens/farmer_profile_screen.dart
```

**Why?** To avoid conflict with `lib/screens/kisan_doctor/profile_screen.dart`

**How to rename:**
- Right-click → Rename
- Or use terminal: `mv lib/screens/profile_screen.dart lib/screens/farmer_profile_screen.dart`

---

## 🔵 Step 4: Update Imports (2 minutes)

### Find & Replace in your project:

**Search for:**
```dart
import 'screens/notifications_screen.dart';
```

**Replace with:**
```dart
import 'screens/farmer_notifications_screen.dart';
```

---

**Search for:**
```dart
import 'screens/profile_screen.dart';
```

**Replace with:**
```dart
import 'screens/farmer_profile_screen.dart';
```

---

**Search for:**
```dart
NotificationsScreen()
```

**Replace with:**
```dart
FarmerNotificationsScreen()
```

---

**Search for:**
```dart
ProfileScreen()
```

**Replace with:**
```dart
FarmerProfileScreen()
```

---

## ✅ Verification Checklist

After cleanup, verify:

- [ ] `lib/screens/kisan_doctor_screen.dart` is deleted
- [ ] `lib/screens/farmer_notifications_screen.dart` exists
- [ ] `lib/screens/farmer_profile_screen.dart` exists
- [ ] All imports updated
- [ ] No compilation errors
- [ ] App runs without issues

---

## 📁 Final Structure

```
lib/screens/
├── kisan_doctor/ ✅ (NEW - Doctor panel)
│   ├── kisan_doctor_dashboard_screen.dart
│   ├── consultation_screen.dart
│   ├── appointments_screen.dart
│   ├── notifications_screen.dart (Doctor)
│   ├── feedback_screen.dart
│   └── profile_screen.dart (Doctor)
├── farmer_notifications_screen.dart ✅ (Renamed)
├── farmer_profile_screen.dart ✅ (Renamed)
├── doctor_screen.dart ✅ (Keep - Farmer-doctor chat)
└── ... (other screens)
```

---

## 🎯 Commands (Terminal)

Run these commands in order:

```bash
# Step 1: Delete placeholder
rm lib/screens/kisan_doctor_screen.dart

# Step 2: Rename farmer notifications
mv lib/screens/notifications_screen.dart lib/screens/farmer_notifications_screen.dart

# Step 3: Rename farmer profile
mv lib/screens/profile_screen.dart lib/screens/farmer_profile_screen.dart

# Step 4: Update class names in renamed files
# (Use Find & Replace in IDE)

# Step 5: Verify
flutter pub get
flutter analyze
```

---

## 🚀 After Cleanup

Your project will have:
- ✅ No duplicate files
- ✅ Clear separation: Farmer vs Doctor
- ✅ Organized structure
- ✅ Ready for production

---

## ⏱️ Total Time: 5 Minutes

1. Delete file: 1 min
2. Rename file 1: 1 min
3. Rename file 2: 1 min
4. Update imports: 2 min

---

**Do this cleanup before deploying!**
