# Rozgar App - Firebase Authentication & Database Implementation Guide

## Overview
Complete Firebase Auth and Firestore integration has been implemented across your Flutter job portal app. All user flows now properly authenticate users and persist data to the database.

## What Was Implemented

### 1. **Core Services Created**

#### `lib/services/auth_service.dart`
- Singleton pattern for Firebase Auth management
- Methods: `signUp()`, `login()`, `logout()`, `resetPassword()`
- Stream: `authStateChanges` for reactive auth state
- Automatic error handling with user-friendly messages
- User role management

#### `lib/services/database_service.dart`
- Singleton pattern for Firestore operations
- User operations: `getUserProfile()`, `updateUserProfile()`, `updateUserFields()`
- Job operations: `getAllJobs()`, `getJobsByLocation()`, `createJob()`, `updateJob()`, `deleteJob()`
- Application operations: `createApplication()`, `getUserApplications()`, `updateApplicationStatus()`
- Stream-based real-time updates for reactive UI
- Company dashboard stats

### 2. **Screens Updated with Firebase**

| Screen | Changes |
|--------|---------|
| **Login** | Uses Firebase Auth, email validation, error handling |
| **Signup** | Firebase Auth + Firestore user document creation |
| **Home** | Streams jobs from Firestore, location filtering |
| **MyProfile** | Displays user profile from Firestore with real-time updates |
| **BuildProfile** | Saves skills, education, contact info to Firestore |
| **MyApplication** | Streams user job applications from Firestore |
| **App Root** | Auth state guard - redirects to Login if not authenticated |

### 3. **Firestore Collections Schema**

#### `users/{uid}`
```
{
  id: string (UID),
  fullName: string,
  email: string (lowercase),
  phoneNumber: string,
  cnic: string,
  address: string,
  skills: array<string>,
  educations: array<{id, degree, institution, year}>,
  cvUrl: string (optional),
  role: string (user|company|admin),
  profileComplete: boolean,
  createdAt: timestamp,
  updatedAt: timestamp
}
```

#### `jobs/{jobId}`
```
{
  id: string,
  jobTitle: string,
  companyId: string (company's uid),
  companyName: string,
  location: string,
  salary: string,
  requiredSkills: array<string>,
  description: string,
  postedDate: timestamp,
  jobType: string (Full-time|Part-time),
  imageUrl: string,
  visible: boolean,
  closed: boolean
}
```

#### `applications/{applicationId}`
```
{
  id: string,
  jobId: string (ref to jobs/{jobId}),
  userId: string (ref to users/{uid}),
  jobTitle: string,
  companyName: string,
  status: string (Applied|Under Review|Interview|Rejected|Accepted),
  appliedDate: timestamp,
  interviewDate: string (optional),
  feedback: string (optional),
  updatedAt: timestamp
}
```

## Setup Instructions

### 1. **Deploy Firestore Rules**
```bash
# Install Firebase CLI (if not already)
npm install -g firebase-tools

# Login to Firebase
firebase login

# Deploy rules to your project
firebase deploy --only firestore:rules
```

### 2. **Create Firestore Indexes**
In Firebase Console:
1. Go to **Firestore Database** → **Indexes** → **Composite Indexes**
2. Add these indexes:

**For jobs collection:**
- Fields: `requiredSkills` (Array) + `location` (Ascending) + `postedDate` (Descending)
- Fields: `companyId` (Ascending) + `postedDate` (Descending)

**For applications collection:**
- Fields: `userId` (Ascending) + `appliedDate` (Descending)
- Fields: `jobId` (Ascending) + `status` (Ascending)

### 3. **Test the App Locally**

```bash
# Clean and rebuild
flutter clean
flutter pub get

# Run on emulator or device
flutter run
```

**Test Flow:**
1. Tap "Sign up" → Create new account
2. Fill in email, password, name
3. Account created? → User doc in Firestore `users` collection
4. Redirect to Build Profile
5. Add skills, education, contact info → Saved to Firestore
6. Go Home → Jobs stream in from Firestore
7. See user profile in MyProfile → Real-time updates from Firestore

## Key Features Enabled

✅ **User Authentication**
- Email/password signup & login
- Password reset
- Auto-logout on app restart

✅ **Data Persistence**
- User profiles stored in Firestore
- Job listings stored centrally
- Application history tracked

✅ **Real-Time Updates**
- StreamBuilder integration for reactive UI
- Home page updates when new jobs posted
- MyProfile shows latest user data

✅ **Error Handling**
- Firebase auth errors → User-friendly messages
- Validation on all forms
- Duplicate email detection

✅ **Security**
- Firestore rules enforce owner-only profile access
- Auth required for sensitive operations
- No hardcoded admin keys

## Authentication Flow

```
User Opens App
      ↓
Check Firebase Auth State
      ↓
   Logged In?
   /        \
 YES        NO
  ↓         ↓
 Home    → Login
(Stream   (Firebase Auth)
  Jobs)   ↓
       Sign Up Option
       (Create User Doc)
       ↓
    Build Profile
    (Save Skills/Education)
    ↓
    Home (Jobs Stream)
```

## Database Flow

```
Signup → Create Auth User → Create users/{uid} doc
  ↓
BuildProfile → Update users/{uid} with skills/education
  ↓
Home → Query/Stream jobs from jobs collection
  ↓
Apply Job → Create applications/{appId} document
  ↓
MyApplication → Stream applications filtered by userId
```

## Common Issues & Solutions

### Issue: "PlatformException: 7: PERMISSION_DENIED"
**Solution:** Check Firestore rules. Ensure the user's UID matches the document ID they're trying to access.

### Issue: "FirebaseException: Invalid query constraints"
**Solution:** Create the required composite indexes in Firebase Console (see Setup Instructions #2).

### Issue: Jobs not showing on Home screen
**Solution:** 
1. Verify jobs exist in Firestore `jobs` collection
2. Check browser console for `getAllJobsStream()` errors
3. Ensure your Firestore rules allow reads on the jobs collection

### Issue: Profile not saving
**Solution:**
1. Verify user is authenticated (`_authService.currentUser` is not null)
2. Check Firestore console for the `users` collection
3. Verify rules allow updates: `request.auth.uid == userId`

## Next Steps

### For Company Features
1. Update company registration to set `role: 'company'`
2. Wire `lib/company/screens/postjob.dart` to save jobs to Firestore
3. Wire `lib/company/screens/manageapplicants.dart` to stream applications

### For Admin Features
1. Create admin registration flow with `role: 'admin'`
2. Wire admin dashboard to stream analytics (job count, app count)
3. Add user management (ban, verify, etc.)

### For Production
1. Enable email verification before allowing login
2. Set up Cloud Storage for CV uploads
3. Add Cloud Functions for notifications
4. Implement proper role-based access control
5. Set up Firebase Analytics

## Files Reference

| File | Purpose |
|------|---------|
| `lib/services/auth_service.dart` | Authentication logic |
| `lib/services/database_service.dart` | Firestore CRUD operations |
| `lib/app.dart` | App root with auth state guard |
| `lib/user/screens/Login/Login.dart` | Firebase login |
| `lib/user/screens/Signup/Signup.dart` | Firebase signup |
| `lib/user/screens/home/home.dart` | Firestore job stream |
| `lib/user/screens/MyProfile/Myprofile.dart` | User profile from Firestore |
| `lib/user/screens/BuildProfile/BuildProfile.dart` | Save profile to Firestore |
| `lib/user/screens/MyApplication/Myapplication.dart` | User applications stream |
| `firestore.rules` | Firestore security rules |

## Testing Checklist

- [ ] Can create account with valid email
- [ ] Cannot create account with duplicate email
- [ ] Cannot create account with weak password
- [ ] Cannot login with wrong password
- [ ] Profile saves after signup completion
- [ ] Profile visible in MyProfile screen
- [ ] Jobs display on Home screen
- [ ] Jobs filter by location
- [ ] Applications saved to Firestore
- [ ] Applications visible in MyApplication
- [ ] Logout clears auth state
- [ ] Re-login works after logout

---

**Last Updated:** May 7, 2026  
**Firebase Version:** Latest (v9+)  
**Flutter Version:** 3.0+
