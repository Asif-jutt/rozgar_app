# Rozgar Job Portal - UI Implementation Guide

## Project Structure Overview

### Models (`lib/user/models/`)

- **job_model.dart** - Job data model with JSON serialization
  - Job title, company, location, salary, skills, job type
  - Posted date and description tracking

- **application_model.dart** - Job application model
  - Application status tracking (Applied, Under Review, Interview, Rejected, Accepted)
  - Interview date and feedback support

- **user_model.dart** - User profile model
  - User credentials and contact information
  - Skills and education history
  - CV URL support

### Constants (`lib/user/constants/`)

- **app_constants.dart** - Centralized design system
  - **AppColors**: Primary (Deep Blue), Secondary (Amber), Status colors
  - **AppStrings**: All UI text labels for easy localization
  - **AppTextStyles**: Predefined text styles (Headlines, Body, Labels, Button)
  - **AppDimensions**: Spacing, padding, border radius constants
  - **AppSpacing**: Consistent spacing values

### Custom Widgets (`lib/user/widgets/`)

- **job_card.dart** - Reusable job listing card with grid support
  - Displays job title, company, location, salary, skills
  - Apply button and card interaction handlers

- **custom_widgets.dart** - Form and UI components
  - `CustomTextField`: Enhanced text input with icons and validation
  - `CustomButton`: Reusable button with loading state
  - `CustomSearchBar`: Search bar with filter toggle

- **app_bar_widgets.dart** - Navigation components
  - `CustomAppBar`: Professional app bar with actions
  - `CustomBottomNavigationBar`: Material bottom nav
  - `UserDrawer`: Feature-rich drawer with user profile
  - `NavigationItem`: Navigation item data model

### Screens (`lib/user/screens/`)

#### 1. **Login Screen** (`Login/Login.dart`)

- Stateful widget with CNIC, Email, Password fields
- Password visibility toggle
- Forgot password link
- Sign up navigation
- Loading state support

#### 2. **Signup Screen** (`Signup/Signup.dart`)

- Full name, email, password, confirm password
- Password matching validation
- Loading state during registration

#### 3. **Home Screen** (`home/home.dart`)

- **Grid layout** showing 2 jobs per row
- Search bar with filter button
- Filter chips (Location, Salary, Job Type)
- Sample job data with realistic information
- Bottom navigation (Home, My Jobs, Messages)
- Drawer navigation

#### 4. **Build Profile Screen** (`BuildProfile/BuildProfile.dart`)

- Skill selection with multi-select filter chips
- Selected skills display
- Education dropdown selection
- Address and email input
- Upload CV button
- Create profile action

#### 5. **My Profile Screen** (`MyProfile/Myprofile.dart`)

- Profile header with avatar and user info
- **Grid layout** for skills display
- Education list with institution details
- Other info cards (Phone, Location)
- Bottom navigation (Home, Find Jobs, Edit)

#### 6. **My Applications Screen** (`MyApplication/Myapplication.dart`)

- **Segmented tabs**: All / Archived / Interviews
- Application cards with status badges
- Status color coding (Applied, Under Review, Interview, Rejected, Accepted)
- Applied date and interview date display
- Action buttons (View Details, Update)
- Empty state handling

## Key Features Implemented

### Design System

✅ Consistent color scheme with primary/secondary colors
✅ Professional typography hierarchy
✅ Standardized spacing and padding
✅ Reusable dimensions and border radius

### Navigation

✅ Bottom navigation bars on all screens
✅ Professional drawer with user profile
✅ Named routes for all screens
✅ Back button support

### UI Components

✅ Custom text fields with prefix/suffix icons
✅ Loading buttons with spinner
✅ Search bar with filter toggle
✅ Filter chips for multi-select
✅ Status badges with color coding
✅ Job cards with grid layout
✅ Application cards with detailed info

### Data Models

✅ Job model with full details
✅ Application model with status tracking
✅ User profile with education history
✅ JSON serialization for all models

## Usage Guide

### Add New Screen

1. Create file in `lib/user/screens/ScreenName/`
2. Import `app_constants.dart` for design tokens
3. Use `CustomAppBar`, `CustomBottomNavigationBar` for consistency
4. Add route to `lib/user/app.dart`

### Styling Elements

```dart
// Use constants instead of hardcoded values
import 'package:rozgar_app/user/constants/app_constants.dart';

// Colors
backgroundColor: AppColors.primaryColor;

// Text styles
Text('Title', style: AppTextStyles.headline4);

// Spacing
SizedBox(height: AppSpacing.verticalSpaceLarge);

// Dimensions
BorderRadius.circular(AppDimensions.radiusLarge);
```

### Creating Reusable Cards

Use `GridView.builder` with `SliverGridDelegateWithFixedCrossAxisCount`:

```dart
GridView.builder(
  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 2,
    childAspectRatio: 0.55,
    crossAxisSpacing: AppSpacing.horizontalSpaceMedium,
    mainAxisSpacing: AppSpacing.verticalSpaceMedium,
  ),
  itemBuilder: (context, index) => JobCard(...),
)
```

## Screens Overview

| Screen          | Navigation         | Features                              |
| --------------- | ------------------ | ------------------------------------- |
| Login           | Drawer             | Email auth, forgot password           |
| Signup          | From Login         | Account creation                      |
| Home            | AppBar + BottomNav | Job feed grid, search, filters        |
| Build Profile   | Drawer             | Skills, education, CV upload          |
| My Profile      | BottomNav          | Skills grid, education list, info     |
| My Applications | BottomNav          | Status tracking, tabs, action buttons |

## Available Routes

- `/home` - Job listings
- `/Login` - Login screen
- `/Signup` - Registration
- `/buildprofile` - Profile setup
- `/myprofile` - View profile
- `/myapplication` - Applications

## Next Steps

1. **Connect to Backend**: Replace sample data with API calls
2. **Add State Management**: Use Provider or Riverpod
3. **Implement Authentication**: Firebase or custom backend
4. **Add Image Support**: User avatars and company logos
5. **Push Notifications**: For job alerts and messages

## Color Reference

- **Primary**: #0D47A1 (Deep Blue)
- **Primary Light**: #1976D2
- **Secondary**: #FFC400 (Amber)
- **Success**: #4CAF50 (Green)
- **Warning**: #FFA726 (Orange)
- **Error**: #E53935 (Red)
- **Info**: #29B6F6 (Light Blue)
