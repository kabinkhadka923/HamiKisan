# Community Tab Implementation - Complete Guide

## Overview
The Community Tab is a local-level farmer group management system that organizes farmers into hierarchical groups (Ward → Municipality → District → Province) with verified leaders managing information flow.

## ✅ COMPLETED - Backend & Infrastructure

### 1. Data Models (`lib/models/community_models.dart`)
- `CommunityGroup` - Group structure with leader info
- `CommunityNotice` - Announcements with types (subsidy, training, emergency, etc.)
- `CommunityMarketPrice` - Daily market price updates
- `CommunityFeedback` - Farmer requests/complaints
- `CommunityMessage` - Controlled messaging

### 2. Service Layer (`lib/services/community_service.dart`)
Complete CRUD operations for:
- Group management
- Notice posting/editing
- Market price updates
- Feedback handling
- Message moderation

### 3. Database (`lib/services/database.dart`)
6 new tables with proper indexes:
- `community_groups`
- `community_members`
- `community_notices`
- `community_market_prices`
- `community_feedback`
- `community_messages`

### 4. State Management (`lib/providers/community_provider.dart`)
Full provider with methods for:
- Loading group data
- Managing notices
- Posting prices
- Handling feedback
- Message moderation
- Admin functions

### 5. Integration
- Added to `MultiProvider` in `main.dart`
- Database version upgraded to 3
- Ready for UI implementation

## 🚧 TODO - UI Implementation

### Screens to Create:

#### 1. **Community Screen** (`lib/screens/community_screen.dart`)
Main screen with tabs:
- **Notices Tab** - View announcements
- **Market Prices Tab** - Daily price updates
- **Feedback Tab** - Submit/view requests
- **Messages Tab** - Group chat (controlled)

#### 2. **Leader Dashboard** (`lib/screens/community/leader_dashboard.dart`)
For group leaders:
- Post new notices
- Update market prices
- Respond to feedback
- Approve messages
- View statistics

#### 3. **Admin Dashboard** (`lib/screens/community/admin_dashboard.dart`)
For Admin/SuperAdmin:
- View all groups
- Create new groups
- Assign leaders
- System statistics
- Manage all feedback

### Components to Create:

#### Notice Card (`lib/widgets/community/notice_card.dart`)
- Display notice with icon based on type
- Show author, date, view count
- Pin indicator
- Tap to view full details

#### Market Price Card (`lib/widgets/community/price_card.dart`)
- Product name and category
- Min/Max/Avg prices
- Market location
- Date posted

#### Feedback Card (`lib/widgets/community/feedback_card.dart`)
- User info
- Subject and message
- Status indicator
- Response (if any)

#### Message Bubble (`lib/widgets/community/message_bubble.dart`)
- Sender info
- Message content
- Timestamp
- Approval status (for leaders)

## Features by Role

### **Farmers**
1. View group notices
2. Check market prices
3. Submit feedback/requests
4. Send messages (requires approval)
5. View group info

### **Group Leaders**
1. All farmer features +
2. Post/edit/delete notices
3. Pin important announcements
4. Update market prices
5. Respond to feedback
6. Approve/reject messages
7. View group statistics

### **Admin/SuperAdmin**
1. All leader features +
2. View all groups
3. Create new groups
4. Assign/change leaders
5. Deactivate groups
6. System-wide statistics
7. Manage all feedback

## Usage Examples

### Initialize Community for User
```dart
final communityProvider = Provider.of<CommunityProvider>(context, listen: false);
await communityProvider.initialize(userId);
```

### Post a Notice (Leader)
```dart
final notice = CommunityNotice(
  id: '',
  groupId: selectedGroup.id,
  title: 'Subsidy Program Available',
  content: 'New fertilizer subsidy program starting next week...',
  type: NoticeType.subsidy,
  authorId: currentUser.id,
  authorName: currentUser.name,
  createdAt: DateTime.now(),
);
await communityProvider.createNotice(notice);
```

### Update Market Price (Leader)
```dart
final price = CommunityMarketPrice(
  id: '',
  groupId: selectedGroup.id,
  productName: 'Tomato',
  category: 'vegetable',
  minPrice: 40.0,
  maxPrice: 60.0,
  avgPrice: 50.0,
  unit: 'kg',
  marketLocation: 'Kalimati Market',
  priceDate: DateTime.now(),
  postedById: currentUser.id,
  postedByName: currentUser.name,
  createdAt: DateTime.now(),
);
await communityProvider.postMarketPrice(price);
```

### Submit Feedback (Farmer)
```dart
final feedback = CommunityFeedback(
  id: '',
  groupId: selectedGroup.id,
  userId: currentUser.id,
  userName: currentUser.name,
  type: FeedbackType.cropIssue,
  subject: 'Pest Problem',
  message: 'My tomato crop is affected by pests...',
  createdAt: DateTime.now(),
  isUrgent: true,
);
await communityProvider.submitFeedback(feedback);
```

## Next Steps

1. Create Community Screen UI with tabs
2. Implement Leader Dashboard
3. Add Admin management screens
4. Create reusable widgets
5. Add sample data for testing
6. Integrate with navigation
7. Add localization support

## File Structure
```
lib/
├── models/
│   └── community_models.dart ✅
├── services/
│   ├── community_service.dart ✅
│   └── database.dart ✅ (updated)
├── providers/
│   └── community_provider.dart ✅
├── screens/
│   ├── community_screen.dart ⏳
│   └── community/
│       ├── leader_dashboard.dart ⏳
│       └── admin_dashboard.dart ⏳
└── widgets/
    └── community/
        ├── notice_card.dart ⏳
        ├── price_card.dart ⏳
        ├── feedback_card.dart ⏳
        └── message_bubble.dart ⏳
```

✅ = Complete
⏳ = Pending

## Testing Checklist

- [ ] Create sample groups
- [ ] Test notice posting
- [ ] Test market price updates
- [ ] Test feedback submission
- [ ] Test message moderation
- [ ] Test leader permissions
- [ ] Test admin functions
- [ ] Test UI responsiveness
- [ ] Test localization
- [ ] Test offline functionality
