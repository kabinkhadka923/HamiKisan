# Quick Reference: Nepali Localization

## 🎯 Quick Start

### Switch Language (User)
Profile → Select Language → नेपाली

### Use in Code (Developer)
```dart
// Import
import '../widgets/localized_text.dart';

// Option 1: Widget
LocalizedText('key_name')

// Option 2: String
Text(context.tr('key_name'))
```

## 📝 Common Translation Keys

| English | Key | Nepali |
|---------|-----|--------|
| Home | `home` | गृहपृष्ठ |
| Marketplace | `marketplace` | बजार |
| Community | `community` | समुदाय |
| Profile | `profile` | प्रोफाइल |
| Login | `login` | लगइन |
| Register | `register` | दर्ता गर्नुहोस् |
| Save | `save` | सुरक्षित गर्नुहोस् |
| Cancel | `cancel` | रद्द गर्नुहोस् |
| Edit | `edit` | सम्पादन गर्नुहोस् |
| Delete | `delete` | मेटाउनुहोस् |
| Submit | `submit` | पेश गर्नुहोस् |
| Search | `search` | खोज्नुहोस् |
| Welcome | `welcome` | स्वागत छ |
| Farmer | `farmer` | किसान |
| Kisan Doctor | `kisan_doctor` | किसान डाक्टर |

## 🔧 Add New Translation

1. Edit `lib/providers/localization_provider.dart`
2. Add to both English and Nepali sections:

```dart
'English': {
  'new_key': 'English Text',
},
'Nepali': {
  'new_key': 'नेपाली पाठ',
},
```

3. Use in code: `context.tr('new_key')`

## ✅ Checklist for New Features

- [ ] Add English translation key
- [ ] Add Nepali translation key
- [ ] Use `context.tr()` or `LocalizedText`
- [ ] Remove `const` if using localized text
- [ ] Test in both languages

## 🐛 Common Issues

**Issue**: "Unused import: localization_provider.dart"
- **Solution**: Ignore - it's a false positive. The import is needed for `context.tr()`

**Issue**: "Methods can't be invoked in constant expressions"
- **Solution**: Remove `const` keyword from widgets using `context.tr()`

**Issue**: Text not updating when language changes
- **Solution**: Make sure you're using `context.tr()` or `LocalizedText`, not hardcoded strings

## 📊 Current Status

- **Total Keys**: 120+
- **Coverage**: ~95%
- **Languages**: 2 (English, Nepali)
- **Screens Localized**: 6+

---
For full documentation, see `NEPALI_LOCALIZATION_GUIDE.md`
