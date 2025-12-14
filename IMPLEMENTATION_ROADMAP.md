# Kitchen Tech - Amazon-Style Marketplace for Kitchen Ads

## 🏗️ Project Structure (Refactored)

This document describes the complete refactored structure for Kitchen Tech as an Amazon-style marketplace for kitchen advertisements in Saudi Arabia.

## ✅ Completed Components

### 1. Data Models (`lib/models/`)

- ✅ `kitchen_ad.dart` - Complete kitchen advertisement model
- ✅ `advertiser.dart` - Advertiser profile model
- ✅ `user_profile.dart` - User/buyer profile model
- ✅ `plan.dart` - Subscription plans model with mock data

### 2. Repositories (`lib/repositories/`)

- ✅ `kitchen_ads_repository.dart` - Kitchen ads CRUD with mock implementation

## 📋 Implementation Roadmap

### Phase 1: Core Infrastructure (Priority: HIGH)

#### Routing Setup

Create `lib/config/router.dart` using GoRouter:

```dart
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

final router = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => HomePage()),
    GoRoute(path: '/kitchens', builder: (context, state) => KitchensListingPage()),
    GoRoute(path: '/kitchens/:id', builder: (context, state) => KitchenAdDetailsPage(id: state.params['id']!)),
    GoRoute(path: '/auth/login', builder: (context, state) => LoginPage()),
    GoRoute(path: '/auth/register', builder: (context, state) => RegisterPage()),
    GoRoute(path: '/dashboard', builder: (context, state) => AdvertiserDashboardPage()),
    GoRoute(path: '/dashboard/new-ad', builder: (context, state) => NewKitchenAdWizardPage()),
    GoRoute(path: '/plans', builder: (context, state) => PlansAndCheckoutPage()),
    GoRoute(path: '/profile', builder: (context, state) => UserProfilePage()),
    GoRoute(path: '/favorites', builder: (context, state) => FavoritesPage()),
    GoRoute(path: '/how-it-works', builder: (context, state) => HowItWorksPage()),
    GoRoute(path: '/contact', builder: (context, state) => ContactPage()),
    GoRoute(path: '/admin', builder: (context, state) => AdminPanelPage()),
  ],
  redirect: (context, state) {
    // Add role-based auth logic here
    return null;
  },
);
```

Then update `lib/app/kitchen_tech_app.dart`:

```dart
return MaterialApp.router(
  routerConfig: router,
  // ... rest of config
);
```

### Phase 2: Authentication Pages

#### `lib/features/auth/presentation/login_page.dart`

- Email/Phone input field (RTL)
- Password field
- "تسجيل الدخول" button
- "نسيت كلمة المرور؟" link
- "مستخدم جديد؟ أنشئ حسابًا" link

#### `lib/features/auth/presentation/register_page.dart`

- TabBar with "عميل" and "معلن" tabs
- Conditional form fields based on selected tab
- Validation and form submission
- Navigate based on user type after registration

### Phase 3: Home Page Refactor

#### `lib/features/home/presentation/home_page.dart` (Amazon-style)

**Structure:**

1. Amazon-style AppBar:

   - Logo
   - Large centered SearchBar
   - Menu: تصفح المطابخ، تسجيل الدخول، إنشاء حساب
   - Primary button: "أضف إعلانك"

2. Hero Section:

   - Large banner image/gradient
   - Title: "اكتشف أفضل تصاميم المطابخ في السعودية"
   - Subtitle
   - Two CTA buttons

3. Categories Grid:

   ```dart
   final categories = [
     {'name': 'مودرن', 'icon': Icons.kitchen},
     {'name': 'كلاسيك', 'icon': Icons.chair},
     {'name': 'مطابخ اقتصادية', 'icon': Icons.attach_money},
     {'name': 'مطابخ فاخرة', 'icon': Icons.diamond},
     {'name': 'مطابخ شقق', 'icon': Icons.apartment},
     {'name': 'مطابخ فلل', 'icon': Icons.villa},
     {'name': 'أجهزة وإكسسوارات', 'icon': Icons.kitchen_outlined},
   ];
   ```

4. Featured Kitchens Section (GridView of KitchenAdCard)

5. Recommended Advertisers Section

6. Footer with all required links

### Phase 4: Listings & Search

#### `lib/features/listings/presentation/kitchens_listing_page.dart`

**Components needed:**

- SearchBar widget
- Filters sidebar (web) / bottom sheet (mobile)
- Filter options:
  ```dart
  - City dropdown
  - Budget ranges
  - Kitchen types
  - Area ranges
  - Materials
  - Quality levels
  - Min rating
  ```
- Sort options dropdown
- Results GridView with KitchenAdCard
- Pagination/infinite scroll

#### Reusable Widget: `lib/shared/widgets/kitchen_ad_card.dart`

```dart
- Image
- Title
- Advertiser name
- City
- Price range
- "إعلان مميز" badge (conditional)
- Favorite icon
- Share icon
- OnTap: navigate to details
```

### Phase 5: Kitchen Ad Details

#### `lib/features/kitchen_detail/presentation/kitchen_ad_details_page.dart`

**Sections:**

1. Breadcrumb navigation
2. Image gallery (main + thumbnails)
3. Right panel:
   - Title, advertiser, city, price
   - Badges (shipping, warranty, 3D design)
4. Specifications table
5. Long description
6. Contact actions:
   - WhatsApp button
   - Call button
   - Request form (expandable)
7. Similar kitchens grid
8. Advertiser mini-profile

### Phase 6: Advertiser Dashboard

#### `lib/features/dashboard/presentation/advertiser_dashboard_page.dart`

**Layout:**

- Stats cards (Row of 4 cards):
  - Active ads
  - Monthly visits
  - Contact clicks
  - Best ad
- Ads DataTable/Grid
- FAB: "إضافة إعلان جديد"
- Subscriptions section
- Settings section

### Phase 7: New Ad Wizard

#### `lib/features/dashboard/presentation/new_kitchen_ad_wizard_page.dart`

Use Flutter Stepper or custom multi-step form:

```dart
Steps:
1. Basic Info (title, city, kitchen type, target client)
2. Technical Specs (area, materials, time, warranty)
3. Pricing (from-to, notes)
4. Media (images upload, video URL)
5. Description & Services (checkboxes)
6. Review & Publish
```

State management: use existing Provider or create WizardState.

### Phase 8: Plans & Checkout

#### `lib/features/plans/presentation/plans_and_checkout_page.dart`

Display 3 plan cards (from MockPlans.all):

- Free plan
- Basic plan
- Pro plan

On "اختر هذه الباقة", show checkout form:

- Billing details
- Payment method selection (placeholder)
- Submit button

### Phase 9: Profile & Favorites

#### `lib/features/profile/presentation/user_profile_page.dart`

- Editable form for buyer info
- Save button
- Delete account button (with confirmation)

#### `lib/features/favorites/presentation/favorites_page.dart`

- GridView of favorited kitchen ads
- Each card has remove icon
- Quick contact buttons

### Phase 10: Static Pages

#### `lib/features/info/presentation/how_it_works_page.dart`

Two-column layout:

- For Buyers (3 steps)
- For Advertisers (3 steps)

#### `lib/features/info/presentation/contact_page.dart`

- Contact form
- Static contact info (email, WhatsApp, social)

### Phase 11: Admin Panel

#### `lib/features/admin/presentation/admin_panel_page.dart`

**Sections (use TabBar):**

1. Users Management
   - DataTable of users
   - Actions: activate/deactivate/ban
2. Ads Management
   - List of ads with status
   - Approve/Reject actions
   - Mark as featured
3. Plans & Payments
   - Subscriptions list
4. Settings
   - App config (placeholder fields)

### Phase 12: Shared Widgets

Create reusable widgets in `lib/shared/widgets/`:

- `amazon_style_app_bar.dart`
- `kitchen_ad_card.dart`
- `category_card.dart`
- `advertiser_card.dart`
- `stat_card.dart` (for dashboard)
- `filter_sidebar.dart`
- `filter_bottom_sheet.dart`
- `loading_indicator.dart`
- `empty_state.dart`
- `error_widget.dart`

### Phase 13: State Management

Update existing `lib/providers/` or create new:

- `auth_provider.dart` (expand existing AuthState)
- `kitchen_ads_provider.dart`
- `favorites_provider.dart`
- `dashboard_provider.dart`
- `filters_provider.dart`

### Phase 14: Theme Updates

#### `lib/theme/app_theme.dart`

Update to Material 3 with neutral, clean colors suitable for marketplace:

```dart
ColorScheme:
- Primary: Blue/Teal (professional)
- Secondary: Orange (CTAs)
- Surface: White/Light gray
- Background: Off-white

Typography: Use Arabic-friendly fonts if available
```

## 🚀 Quick Start Implementation Order

### Minimum Viable Product (MVP) - Week 1:

1. ✅ Data models (DONE)
2. ✅ Repository interfaces (DONE)
3. Setup GoRouter
4. Create Login & Register pages
5. Refactor HomePage to Amazon-style
6. Create KitchensListingPage with basic filters
7. Create KitchenAdDetailsPage
8. Test complete buyer flow

### Enhanced Features - Week 2:

9. Create AdvertiserDashboardPage
10. Create NewKitchenAdWizardPage
11. Create PlansAndCheckoutPage
12. Create Profile & Favorites
13. Create HowItWorks & Contact
14. Test complete advertiser flow

### Admin & Polish - Week 3:

15. Create AdminPanelPage
16. Add all missing shared widgets
17. Polish RTL and responsiveness
18. Add loading states & error handling
19. Final testing & bug fixes

## 📱 Responsive Breakpoints

```dart
const double mobileBreakpoint = 600;
const double tabletBreakpoint = 900;
const double desktopBreakpoint = 1200;

bool isMobile(BuildContext context) =>
  MediaQuery.of(context).size.width < mobileBreakpoint;

bool isTablet(BuildContext context) =>
  MediaQuery.of(context).size.width >= mobileBreakpoint &&
  MediaQuery.of(context).size.width < desktopBreakpoint;

bool isDesktop(BuildContext context) =>
  MediaQuery.of(context).size.width >= desktopBreakpoint;
```

## 🔐 Auth Flow

```dart
User logs in -> Check role:
  - Buyer -> Navigate to '/'
  - Advertiser -> Navigate to '/dashboard'
  - Admin -> Navigate to '/admin'

Protected routes check:
  - If accessing /dashboard without advertiser role -> redirect to /auth/login
  - If accessing /admin without admin role -> redirect to /auth/login
```

## 📦 Required Packages

Add to `pubspec.yaml`:

```yaml
dependencies:
  go_router: ^14.0.0 # Routing
  provider: ^6.1.0 # Already exists
  cached_network_image: ^3.3.0
  image_picker: ^1.0.0 # For ad wizard
  file_picker: ^6.0.0 # For ad wizard
  url_launcher: ^6.2.0 # For WhatsApp/phone
  share_plus: ^7.2.0 # For sharing ads
  flutter_rating_bar: ^4.0.1 # For ratings
```

## 🎨 Design System

Colors:

- Primary: #1976D2 (Blue)
- Secondary: #FF9800 (Orange)
- Success: #4CAF50
- Warning: #FFC107
- Error: #F44336
- Surface: #FFFFFF
- Background: #F5F5F5

Spacing:

- xs: 4px
- sm: 8px
- md: 16px
- lg: 24px
- xl: 32px
- xxl: 48px

Border Radius:

- Small: 8px
- Medium: 16px
- Large: 24px

## 📝 Next Steps for Developer

1. **Install go_router**: `flutter pub add go_router`
2. **Create router.dart** following the structure above
3. **Update main.dart** and **kitchen_tech_app.dart** to use GoRouter
4. **Start with Auth pages** (login & register) - these are critical
5. **Refactor HomePage** to Amazon-style incrementally
6. **Build out each page** following the roadmap order
7. **Test on Web and Mobile** at each phase
8. **Add error handling and loading states** throughout

## 🐛 Common Issues & Solutions

**RTL Issues:**

- Always wrap Scaffold in Directionality(textDirection: TextDirection.rtl)
- Use Alignment.centerRight instead of centerLeft for Arabic
- Test all layouts in RTL mode

**Navigation Issues:**

- Use context.go() for navigation with GoRouter
- Use context.push() for stacked navigation
- Implement proper redirect logic for auth

**State Management:**

- Keep using Provider for consistency
- Create separate providers for each major feature
- Use Consumer/Selector for optimal rebuilds

## 📊 Project Status

- ✅ Phase 1: Data Models & Repositories (COMPLETE)
- ⏳ Phase 2: Routing Setup (PENDING)
- ⏳ Phase 3: Auth Pages (PENDING)
- ⏳ Phase 4: Home Page Refactor (PENDING)
- ⏳ Phases 5-14: (PENDING)

---

**Total Estimated Development Time:** 3-4 weeks for full implementation
**Current Progress:** ~10% (Core models and repository interfaces complete)

This README serves as the complete blueprint. Follow the phases in order for systematic implementation.
