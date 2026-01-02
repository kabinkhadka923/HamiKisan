# HamiKisan Localization Guide

## Overview
HamiKisan now supports full English/Nepali bilingual functionality. Users can switch languages from their Profile screen, and the entire app will update instantly.

## How It Works

### 1. LocalizationProvider
Located in `lib/providers/localization_provider.dart`, this provider:
- Manages current language state (English/Nepali)
- Stores language preference in SharedPreferences
- Provides 100+ translations for common app terms
- Syncs with user profile in database

### 2. Helper Widget & Extension
Located in `lib/widgets/localized_text.dart`:

**LocalizedText Widget:**
```dart
LocalizedText('profile')  // Automatically translates based on current language
```

**Context Extension:**
```dart
context.tr('welcome')  // Quick translation method
```

### 3. How to Add Translations to Any Screen

#### Method 1: Using LocalizedText Widget
```dart
// Instead of:
Text('Profile')

// Use:
LocalizedText('profile')
```

#### Method 2: Using Context Extension
```dart
// Instead of:
Text('Welcome Back')

// Use:
Text(context.tr('welcome_back'))
```

#### Method 3: Using Consumer (for dynamic content)
```dart
Consumer<LocalizationProvider>(
  builder: (context, loc, child) {
    return Text(loc.translate('home'));
  },
)
```

## Available Translation Keys

### Common
- `continue`, `cancel`, `save`, `delete`, `edit`, `submit`
- `search`, `filter`, `loading`, `error`, `success`
- `yes`, `no`, `ok`, `close`

### Authentication
- `login`, `register`, `logout`, `email`, `password`
- `username`, `phone_number`, `name`
- `forgot_password`, `sign_in`, `sign_up`

### Profile
- `profile`, `edit_profile`, `my_profile`, `my_posts`
- `settings`, `profile_completion`, `address`
- `change_password`, `current_password`, `new_password`

### Navigation
- `home`, `community`, `marketplace`, `tools`
- `doctor`, `weather`, `market_prices`, `notifications`

### Community
- `create_post`, `post`, `comment`, `like`, `share`
- `comments`, `likes`, `shares`

### Marketplace
- `buy`, `sell`, `price`, `quantity`, `description`
- `category`, `add_product`, `my_products`
- `product_name`, `contact_seller`

### Weather
- `temperature`, `humidity`, `wind_speed`, `rainfall`
- `forecast`, `today`, `tomorrow`, `this_week`

### Market Prices
- `vegetable`, `fruit`, `grain`
- `min_price`, `max_price`, `avg_price`, `per_kg`

### Tools
- `crop_calculator`, `insurance_calculator`
- `government_schemes`, `learning_resources`, `soil_testing`

### Doctor/Consultation
- `consult_doctor`, `ai_diagnosis`, `upload_image`
- `take_photo`, `diagnosis_result`, `treatment`, `prevention`

### Roles
- `farmer`, `kisan_doctor`, `admin`, `super_admin`

### Messages
- `welcome`, `welcome_back`, `please_login`
- `registration_successful`, `login_successful`
- `profile_updated`, `post_created`, `product_added`
- `error_occurred`, `invalid_credentials`

## Adding New Translations

To add new translations, edit `lib/providers/localization_provider.dart`:

```dart
static final Map<String, Map<String, String>> _translations = {
  'English': {
    'your_new_key': 'Your English Text',
    // ... more keys
  },
  'Nepali': {
    'your_new_key': 'तपाईंको नेपाली पाठ',
    // ... more keys
  },
};
```

## Example: Localizing a Complete Screen

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/localization_provider.dart';
import '../widgets/localized_text.dart';

class MyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: LocalizedText('my_screen_title'),
      ),
      body: Column(
        children: [
          // Using LocalizedText widget
          LocalizedText('welcome', 
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          
          // Using context extension
          Text(context.tr('description')),
          
          // For buttons
          ElevatedButton(
            onPressed: () {},
            child: Text(context.tr('submit')),
          ),
          
          // For dynamic content
          Consumer<LocalizationProvider>(
            builder: (context, loc, child) {
              return Text(loc.translate('dynamic_content'));
            },
          ),
        ],
      ),
    );
  }
}
```

## Language Switching

Users can switch languages from:
1. **Profile Screen** → "Change Language" / "भाषा परिवर्तन गर्नुहोस्"
2. **Language Selection Screen** (first-time users)

The language preference is:
- Saved to SharedPreferences
- Synced with user profile in database
- Applied immediately across the entire app

## Testing

To test localization:
1. Run the app
2. Go to Profile screen
3. Tap "Change Language"
4. Select "नेपाली (Nepali)"
5. Observe all localized text update to Nepali
6. Switch back to English to verify

## Next Steps

To complete full app localization:
1. Update `home_screen.dart` with translations
2. Update `login_screen.dart` and `register_screen.dart`
3. Update all dashboard screens
4. Update marketplace and community screens
5. Update doctor and tools screens

Use the pattern shown in `profile_screen.dart` as a reference.
