# Kitchen Tech - Amazon-Style Marketplace Refactoring

## 🎯 Executive Summary

This document provides a complete summary of the refactoring work for Kitchen Tech to transform it into an Amazon-style marketplace for kitchen advertisements in Saudi Arabia.

## ✅ What Has Been Completed

### 1. Core Data Models Created

All essential data models have been created in `lib/models/`:

- **`kitchen_ad.dart`** - Complete model for kitchen advertisements with:

  - All required fields (title, price range, city, materials, etc.)
  - Status enum (pending, active, rejected, expired, paused)
  - Full JSON serialization
  - Views and contact clicks tracking
  - Rating support

- **`advertiser.dart`** - Advertiser profile model with:

  - Three types: Company, Workshop, Freelancer
  - Business information fields
  - Rating and statistics
  - Plan subscription tracking

- **`user_profile.dart`** - User/buyer model with:

  - Three roles: Buyer, Advertiser, Admin
  - Favorites list support
  - Role-based access helpers

- **`plan.dart`** - Subscription plans with:
  - Complete plan structure
  - Mock data for 3 plans (Free, Basic, Pro)
  - Feature lists in Arabic

### 2. Repository Interface Created

- **`lib/repositories/kitchen_ads_repository.dart`**:
  - Abstract interface for all kitchen ad operations
  - Complete mock implementation with 2 sample ads
  - Ready for backend integration
  - Includes search, filtering, CRUD operations

### 3. Existing Project Structure

The project already has:

- ✅ Flutter app with RTL support
- ✅ Provider state management
- ✅ Existing AuthState
- ✅ Basic routing system
- ✅ Login page (needs minor updates)
- ✅ Home, Listings, Product Detail screens (need major refactoring)
- ✅ Material 3 theme
- ✅ go_router package installed (v17.0.1)

## 📋 What Needs To Be Done

### Critical Path (Priority 1 - Week 1)

#### 1. Router Setup (2-3 hours)

Create `lib/config/app_router.dart`:

```dart
import 'package:go_router/go_router.dart';

final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', name: 'home', builder: (context, state) => HomePage()),
    GoRoute(path: '/kitchens', name: 'kitchens', builder: (context, state) => KitchensListingPage()),
    GoRoute(path: '/kitchens/:id', name: 'kitchen-detail', builder: (context, state) {
      return KitchenAdDetailsPage(kitchenId: state.pathParameters['id']!);
    }),
    GoRoute(path: '/auth/login', name: 'login', builder: (context, state) => LoginPage()),
    GoRoute(path: '/auth/register', name: 'register', builder: (context, state) => RegisterPage()),
    // ... add all other routes
  ],
  redirect: (context, state) {
    // TODO: Add authentication checks
    return null;
  },
);
```

Update `lib/app/kitchen_tech_app.dart`:

```dart
import 'package:go_router/go_router.dart';
import '../config/app_router.dart';

class KitchenTechApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: router,
      title: 'KitchenTech',
      locale: const Locale('ar'),
      // ... rest stays the same
    );
  }
}
```

#### 2. Refactor HomePage (4-6 hours)

Update `lib/features/home/presentation/home_screen.dart`:

**Required Changes:**

1. **New AppBar** (Amazon-style):

   - Centered large search bar
   - Menu items: تصفح المطابخ, تسجيل الدخول, إنشاء حساب
   - Primary CTA: "أضف إعلانك"

2. **Hero Section** (replace current hero):

   ```dart
   Container(
     height: 400,
     decoration: BoxDecoration(/* gradient or image */),
     child: Column(
       children: [
         Text('اكتشف أفضل تصاميم المطابخ في السعودية'),
         Text('منصة تجمع شركات المطابخ، الورش، والمصممين'),
         Row(
           children: [
             ElevatedButton('استعرض المطابخ'),
             OutlinedButton('سجّل كمورّد مطابخ'),
           ],
         ),
       ],
     ),
   )
   ```

3. **Categories Section** (new):

   ```dart
   GridView.builder(
     gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
       crossAxisCount: isDesktop ? 4 : 2,
     ),
     itemCount: categories.length,
     itemBuilder: (context, index) {
       return CategoryCard(
         title: categories[index].name,
         icon: categories[index].icon,
         onTap: () => context.go('/kitchens?category=${categories[index].id}'),
       );
     },
   )
   ```

4. **Featured Kitchens** (update to use mock repo):

   ```dart
   FutureBuilder<List<KitchenAd>>(
     future: MockKitchenAdsRepository().getFeatured(),
     builder: (context, snapshot) {
       if (snapshot.hasData) {
         return GridView.builder(
           itemCount: snapshot.data!.length,
           itemBuilder: (context, index) {
             return KitchenAdCard(ad: snapshot.data![index]);
           },
         );
       }
       return CircularProgressIndicator();
     },
   )
   ```

5. **Footer** (keep existing but ensure all links work)

#### 3. Create RegisterPage (3-4 hours)

Create `lib/features/auth/presentation/register_page.dart`:

```dart
class RegisterPage extends StatefulWidget {
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  UserRole _selectedRole = UserRole.buyer;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Tab Bar
          SegmentedButton<UserRole>(
            segments: [
              ButtonSegment(value: UserRole.buyer, label: Text('عميل')),
              ButtonSegment(value: UserRole.advertiser, label: Text('معلن')),
            ],
            selected: {_selectedRole},
            onSelectionChanged: (Set<UserRole> newSelection) {
              setState(() => _selectedRole = newSelection.first);
            },
          ),

          // Conditional Form
          if (_selectedRole == UserRole.buyer)
            _BuyerRegistrationForm()
          else
            _AdvertiserRegistrationForm(),
        ],
      ),
    );
  }
}
```

#### 4. Refactor ListingsScreen (4-5 hours)

Update `lib/features/listings/presentation/listings_screen.dart`:

**Add:**

- Filter sidebar/bottom sheet with all specified filters
- Sort dropdown
- Use `MockKitchenAdsRepository().search()` for data
- Pagination or "Load More"
- Update to use `KitchenAdCard` widget

#### 5. Create KitchenAdCard Widget (2 hours)

Create `lib/shared/widgets/kitchen_ad_card.dart`:

```dart
class KitchenAdCard extends StatelessWidget {
  final KitchenAd ad;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () => context.go('/kitchens/${ad.id}'),
        child: Column(
          children: [
            // Image with favorite button overlay
            Stack(
              children: [
                CachedNetworkImage(imageUrl: ad.mainImageUrl),
                if (ad.isFeatured)
                  Positioned(
                    top: 8, right: 8,
                    child: Chip(label: Text('إعلان مميز')),
                  ),
                Positioned(
                  top: 8, left: 8,
                  child: IconButton(
                    icon: Icon(Icons.favorite_border),
                    onPressed: () {/* toggle favorite */},
                  ),
                ),
              ],
            ),

            // Info
            Padding(
              padding: EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(ad.title, style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  Text(ad.advertiserName),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 16),
                      Text(ad.city),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text('${ad.priceFrom.toInt()} - ${ad.priceTo.toInt()} ريال'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

#### 6. Refactor ProductDetailScreen to KitchenAdDetailsPage (5-6 hours)

Update `lib/features/product/presentation/product_detail_screen.dart`:

**New Structure:**

1. Breadcrumb navigation
2. Image gallery (swipeable with thumbnails)
3. Right panel with all details
4. Specifications table
5. Description
6. Contact buttons:
   ```dart
   Row(
     children: [
       ElevatedButton.icon(
         icon: Icon(Icons.whatsapp),
         label: Text('تواصل عبر واتساب'),
         onPressed: () async {
           final url = 'https://wa.me/966xxxxxxxx?text=...';
           if (await canLaunchUrl(Uri.parse(url))) {
             await launchUrl(Uri.parse(url));
           }
         },
       ),
       ElevatedButton.icon(
         icon: Icon(Icons.phone),
         label: Text('اتصال هاتفي'),
         onPressed: () {/* launch tel: */},
       ),
     ],
   )
   ```
7. Contact form (collapsible)
8. Similar kitchens section
9. Advertiser mini-profile

### Important Features (Priority 2 - Week 2)

#### 7. AdvertiserDashboardPage (1 day)

Create `lib/features/dashboard/presentation/advertiser_dashboard_page.dart`:

- Stats cards (4 metrics)
- Ads table with status filters
- FAB for new ad
- Subscriptions section
- Settings section

#### 8. NewKitchenAdWizardPage (1-2 days)

Create `lib/features/dashboard/presentation/new_kitchen_ad_wizard_page.dart`:

- 6-step Stepper
- Form validation per step
- Image upload handling (placeholder)
- Save draft functionality
- Final submission

#### 9. PlansAndCheckoutPage (0.5 day)

Create `lib/features/plans/presentation/plans_page.dart`:

- Display 3 plan cards from `MockPlans.all`
- Checkout form (placeholder payment)

#### 10. Profile & Favorites (0.5 day each)

- `lib/features/profile/presentation/user_profile_page.dart`
- `lib/features/favorites/presentation/favorites_page.dart`

### Nice-to-Have (Priority 3 - Week 3)

#### 11. Static Pages (0.5 day)

- HowItWorksPage
- ContactPage

#### 12. AdminPanelPage (1-2 days)

- Users management
- Ads approval
- Plans overview

#### 13. Shared Widgets Library (ongoing)

Create in `lib/shared/widgets/`:

- `amazon_app_bar.dart`
- `category_card.dart`
- `advertiser_card.dart`
- `stat_card.dart`
- `filter_sidebar.dart`
- `loading_indicator.dart`
- `empty_state.dart`

### 14. Polish & Testing (ongoing)

- Add loading states everywhere
- Add error handling
- Test RTL thoroughly
- Test responsive breakpoints
- Fix any navigation issues
- Add analytics tracking (placeholders)

## 🏗️ Recommended Implementation Order

### Day 1-2: Foundation

1. ✅ Data models (DONE)
2. ✅ Repository (DONE)
3. Setup GoRouter
4. Update RegisterPage

### Day 3-5: Core User Flows

5. Refactor HomePage (Amazon-style)
6. Create KitchenAdCard widget
7. Refactor ListingsScreen with filters
8. Refactor ProductDetail to KitchenAdDetails

### Day 6-8: Advertiser Features

9. AdvertiserDashboardPage
10. NewKitchenAdWizardPage
11. PlansAndCheckoutPage

### Day 9-10: Additional Features

12. Profile & Favorites pages
13. Static pages (HowItWorks, Contact)

### Day 11-12: Admin & Polish

14. AdminPanelPage (basic)
15. Shared widgets library
16. Testing & bug fixes

### Day 13-14: Final Polish

17. Performance optimization
18. RTL and responsive testing
19. Error handling
20. Documentation

## 📦 Required New Packages

Add to `pubspec.yaml`:

```yaml
dependencies:
  go_router: ^17.0.1 # ✅ Already installed
  provider: ^6.1.0 # ✅ Already exists
  cached_network_image: ^3.3.0
  image_picker: ^1.0.0
  file_picker: ^6.0.0
  url_launcher: ^6.2.0
  share_plus: ^7.2.0
  flutter_rating_bar: ^4.0.1
```

Install with:

```bash
flutter pub add cached_network_image image_picker file_picker url_launcher share_plus flutter_rating_bar
```

## 🎨 Design System Reference

### Colors

```dart
// lib/theme/app_colors.dart
class AppColors {
  static const primary = Color(0xFF1976D2);      // Blue
  static const secondary = Color(0xFFFF9800);    // Orange
  static const success = Color(0xFF4CAF50);
  static const warning = Color(0xFFFFC107);
  static const error = Color(0xFFF44336);
  static const surface = Color(0xFFFFFFFF);
  static const background = Color(0xFFF5F5F5);
}
```

### Spacing

```dart
// lib/theme/app_spacing.dart
class AppSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
  static const xxl = 48.0;
}
```

## 🔄 Migration Strategy

### Phase 1: Non-Breaking Changes (Week 1)

- Add new models
- Add new pages (don't delete old ones yet)
- Setup new routing (parallel to old)
- Test new flows

### Phase 2: Replace Old Screens (Week 2)

- Redirect old routes to new pages
- Update all navigation calls
- Test thoroughly

### Phase 3: Cleanup (Week 3)

- Remove unused old screens
- Remove unused widgets
- Clean up imports
- Final testing

## 📝 Testing Checklist

### Buyer Flow

- [ ] Browse home page
- [ ] Search kitchens
- [ ] Apply filters
- [ ] View kitchen details
- [ ] Add to favorites
- [ ] Contact advertiser (WhatsApp)
- [ ] View profile
- [ ] View favorites

### Advertiser Flow

- [ ] Register as advertiser
- [ ] Login
- [ ] View dashboard
- [ ] Create new ad (all steps)
- [ ] Edit ad
- [ ] Pause/resume ad
- [ ] View subscription
- [ ] Upgrade plan

### Admin Flow

- [ ] Login as admin
- [ ] View users list
- [ ] Approve/reject ads
- [ ] Mark ad as featured
- [ ] View subscriptions

### Responsive Testing

- [ ] Mobile (< 600px)
- [ ] Tablet (600-1200px)
- [ ] Desktop (> 1200px)

### RTL Testing

- [ ] All text aligns right
- [ ] All icons flip correctly
- [ ] Forms work in RTL
- [ ] Navigation works in RTL

## 🚀 Quick Start Commands

```bash
# Install new packages
flutter pub add cached_network_image image_picker file_picker url_launcher share_plus flutter_rating_bar

# Check for issues
flutter analyze

# Run on web
flutter run -d chrome

# Build for production
flutter build web --release --base-href /KT/

# Deploy
./deploy_web.ps1
```

## 📊 Current Progress

| Component         | Status            | Progress |
| ----------------- | ----------------- | -------- |
| Data Models       | ✅ Complete       | 100%     |
| Repositories      | ✅ Complete       | 100%     |
| Router Setup      | ⏳ Pending        | 0%       |
| Auth Pages        | 🟡 Partial        | 50%      |
| Home Page         | 🟡 Needs Refactor | 30%      |
| Listings Page     | 🟡 Needs Refactor | 40%      |
| Details Page      | 🟡 Needs Refactor | 40%      |
| Dashboard         | ⏳ Pending        | 0%       |
| Ad Wizard         | ⏳ Pending        | 0%       |
| Plans Page        | ⏳ Pending        | 0%       |
| Profile/Favorites | ⏳ Pending        | 0%       |
| Static Pages      | ⏳ Pending        | 0%       |
| Admin Panel       | ⏳ Pending        | 0%       |
| **Overall**       | 🟡 In Progress    | **15%**  |

## 🎯 Next Immediate Steps

1. **Right now:** Setup GoRouter in `lib/config/app_router.dart`
2. **Today:** Refactor HomePage to Amazon-style
3. **Tomorrow:** Create KitchenAdCard and refactor ListingsScreen
4. **This week:** Complete core buyer flow (browse → details → contact)

## 📞 Need Help?

If you need clarification on any component:

1. Refer to `IMPLEMENTATION_ROADMAP.md` for detailed specifications
2. Check existing code in `lib/features/` for patterns
3. Use mock data from repositories for testing
4. Follow RTL and Material 3 guidelines

---

**Last Updated:** December 11, 2025
**Project Status:** Foundation Complete, Ready for Core Implementation
**Estimated Completion:** 2-3 weeks for MVP
