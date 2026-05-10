# OTP Verification Flow Implementation Guide

## Overview
This implementation adds a complete OTP (One-Time Password) verification flow to the Flutter signup process. The flow verifies the user's email address and confirms the account creation before collecting personal information.

## Implementation Details

### 1. **Endpoints Added** (`lib/core/services/endpoints.dart`)
```dart
static const String checkEmailExistence = '/Account/EmailExistance';
static const String sendOtp = '/Account/send-otp';
static const String verifyOtp = '/Account/verify-otp';
```

### 2. **State Management** (`lib/feature/auth/cubit/register_cubit.dart`)

#### New States Added:
- `CheckingEmailExistence` - Loading state for email verification
- `EmailExists` - Email already registered
- `EmailDoesNotExist` - Email available for registration
- `OtpSending` - Loading state for OTP send
- `OtpSent` - OTP successfully sent
- `OtpSendFailure` - OTP send failed with error message
- `OtpVerifying` - Loading state for OTP verification
- `OtpVerified` - OTP verified successfully
- `OtpVerifyFailure` - OTP verification failed with error message

#### New Methods Added:
```dart
Future<void> checkEmailExistence(String emailAddress)
Future<void> sendOtp(String emailAddress)
Future<void> verifyOtp(String emailAddress, String otpCode)
```

### 3. **UI Components Created**

#### A. OTP Countdown Timer Widget (`lib/feature/auth/widget/otp_countdown_timer.dart`)
- **Purpose**: Manages the 5-minute countdown timer for OTP expiration
- **Features**:
  - Automatically counts down from 5 minutes (300 seconds)
  - Formats time as "M:SS" for display
  - Calls `onTimerFinish()` callback when timer reaches zero
  - Provides `restartTimer()` method for resend functionality
  - Properly disposes timer on widget destruction
  - Optional `onTick` callback for updates on each second

**Key Methods**:
- `restartTimer()` - Resets and restarts the 5-minute countdown
- `_formatTime(Duration)` - Formats duration as "M:SS"

#### B. OTP Verification Screen (`lib/feature/auth/views/register/otp_verification.dart`)
- **Purpose**: Collects and verifies 6-digit OTP
- **Features**:
  - **Input Validation**:
    - Exactly 6 digits required
    - Numeric keyboard only (no special characters)
    - Auto-limiting to 6 characters
    - Large, centered display with letter spacing
  
  - **Timer Management**:
    - Shows 5-minute countdown
    - Disables resend button while timer is active
    - Shows "Send OTP Again" button when timer finishes
    - Timer persists while user stays on screen
    - Auto-restarts on successful resend
  
  - **Error Handling**:
    - Shows loading state during verification
    - Displays error messages in red banner
    - Invalid OTP shows: "Invalid OTP code."
    - Network errors show appropriate error messages
  
  - **Flow**:
    - User enters 6-digit OTP
    - Click Verify button
    - Upon success: Navigate to personal info screen (registerNameScreen)
    - Upon failure: Show error and allow retry

- **Navigation**:
  - Receives `email` and `password` as parameters
  - Saves password to cubit before proceeding
  - Navigates to `Routes.registerNameScreen` on success

### 4. **Email Registration Screen Updated** (`lib/feature/auth/views/register/email_registter.dart`)

#### Updated Flow:
1. User fills email and password
2. Clicks "Next" button
3. **Email Existence Check**:
   - Calls `checkEmailExistence(email)`
   - Shows loading state
4. **Based on Result**:
   - **Email Exists**: Shows snackbar "This email is already registered."
   - **Email Doesn't Exist**: 
     - Calls `sendOtp(email)`
     - Shows loading state
     - Navigates to OTP verification screen
     - Passes email and password to OTP screen

#### Error Handling:
- Email validation errors prevented at form level
- Network errors handled by Cubit
- User-friendly error messages via snackbars

### 5. **Route Registration** (`lib/core/constant/routes.dart`)
Added new route constant:
```dart
static const String otpVerificationScreen = '/otpVerificationScreen';
```

Note: OTP screen uses `Navigator.push()` instead of named route for better parameter passing.

## Complete User Flow

```
┌─────────────────────────────────────────────────────────────┐
│ 1. Email & Password Screen (email_registter.dart)           │
│    - User enters email, password, confirm password           │
│    - Validates email format and password strength           │
│    - Click "Next" button                                    │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│ 2. Check Email Existence API Call                           │
│    POST /api/Account/EmailExistance                         │
│    { "email": "user@example.com" }                          │
└────────────┬────────────────────────────────┬───────────────┘
             │                                │
    ┌────────▼──────────┐         ┌──────────▼──────────┐
    │ Email Exists      │         │ Email Available     │
    │ Show Error        │         │ Send OTP            │
    │ Stop              │         │                     │
    └───────────────────┘         └──────────┬──────────┘
                                             │
                                  ┌──────────▼──────────┐
                                  │ Send OTP API Call   │
                                  │ POST /api/Account/  │
                                  │ send-otp            │
                                  │ { "email": ... }    │
                                  └──────────┬──────────┘
                                             │
                                  ┌──────────▼──────────┐
                                  │ 3. OTP Screen       │
                                  │ - 6-digit input     │
                                  │ - 5-min timer       │
                                  │ - Resend button     │
                                  └──────────┬──────────┘
                                             │
                                  ┌──────────▼──────────┐
                                  │ 4. Verify OTP       │
                                  │ POST /api/Account/  │
                                  │ verify-otp          │
                                  │ {                   │
                                  │   "email": ...,     │
                                  │   "otp": "123456"   │
                                  │ }                   │
                                  └──────────┬──────────┘
                                             │
                            ┌────────────────┼────────────────┐
                            │                                 │
                   ┌────────▼──────────┐         ┌──────────▼──────────┐
                   │ OTP Invalid       │         │ OTP Valid           │
                   │ Show Error        │         │ Navigate to         │
                   │ Allow Retry       │         │ Personal Info Screen│
                   │                   │         │ (registerNameScreen)│
                   └───────────────────┘         └─────────────────────┘
                                                            │
                                                  ┌─────────▼──────────┐
                                                  │ 5. Personal Info    │
                                                  │ Screen continues... │
                                                  └────────────────────┘
```

## API Response Format

All API calls follow the project's standard response format:
```json
{
  "success": true/false,
  "statusCode": 200,
  "data": {...},
  "error": "error message if success is false"
}
```

### Email Existence Check Response:
- `success: true` → Email exists (cannot register)
- `success: false` → Email available (proceed with OTP)

### Send OTP Response:
- `success: true` → OTP sent successfully
- `success: false` → Failed to send OTP

### Verify OTP Response:
- `success: true` → OTP is valid, proceed to next screen
- `success: false` → OTP is invalid, show error

## Key Features Implemented

✅ **Email Validation**
- Check if email already exists before sending OTP
- Prevent duplicate account registrations

✅ **OTP Generation & Sending**
- Call send-otp endpoint
- Show loading state during send
- Handle network errors gracefully

✅ **OTP Input**
- Exactly 6 digits enforced
- Numeric keyboard only
- Large, easy-to-read input field
- Auto-preventing overflow

✅ **Countdown Timer**
- 5-minute countdown from OTP send
- "M:SS" format display
- Persists while user stays on screen
- Properly cleaned up on dispose

✅ **Resend Functionality**
- "Send OTP Again" button appears when timer finishes
- Button disabled while timer is active
- Clicking resend:
  - Calls send-otp endpoint again
  - Clears OTP input field
  - Restarts 5-minute timer
  - Shows loading state

✅ **OTP Verification**
- Sends email and OTP to verify endpoint
- Loading state during verification
- Shows error messages for invalid OTP
- Navigates to next screen on success
- Maintains email and password state

✅ **Error Handling**
- Email already registered: Snackbar notification
- Network errors: User-friendly error messages
- Invalid OTP: Error banner with message
- OTP send errors: Snackbar notifications

✅ **Loading States**
- Email check loading state
- OTP send loading state
- OTP verify loading state
- Button disabled during loading
- Loading spinner in button

✅ **User Experience**
- Clear messaging at each step
- Immediate visual feedback
- Intuitive button states
- No data loss on errors
- Ability to retry failed operations

## Testing Checklist

- [ ] Email already exists → Shows error snackbar
- [ ] Email is new → Sends OTP and navigates to OTP screen
- [ ] OTP countdown starts at 5 minutes
- [ ] Timer displays correctly (M:SS format)
- [ ] Resend button is disabled while timer is active
- [ ] Resend button appears when timer finishes
- [ ] Clicking resend sends new OTP
- [ ] Timer restarts after resend
- [ ] Invalid OTP shows error message
- [ ] Valid OTP navigates to personal info screen
- [ ] Network errors handled gracefully
- [ ] Loading states work correctly
- [ ] Buttons properly enabled/disabled based on state
- [ ] No data loss when returning to previous screens
- [ ] Timer properly disposed when leaving screen

## Architecture Notes

This implementation follows the project's existing patterns:
- **State Management**: Cubit for managing OTP flow states
- **API Calls**: Using existing ApiService with error handling
- **Navigation**: Named routes for main flow, push for OTP screen
- **Widgets**: Reusable auth layout components
- **Error Handling**: User-friendly snackbar messages
- **Clean Code**: Separated concerns, reusable widgets

## Files Modified/Created

### Modified:
1. `lib/core/services/endpoints.dart` - Added 3 OTP endpoints
2. `lib/feature/auth/cubit/register_state.dart` - Added OTP states
3. `lib/feature/auth/cubit/register_cubit.dart` - Added OTP methods
4. `lib/core/constant/routes.dart` - Added OTP route
5. `lib/feature/auth/views/register/email_registter.dart` - Updated for email check and OTP flow

### Created:
1. `lib/feature/auth/widget/otp_countdown_timer.dart` - Timer widget
2. `lib/feature/auth/views/register/otp_verification.dart` - OTP screen

## Integration Notes

The OTP flow integrates seamlessly with the existing signup process:
- Existing registration flow continues unchanged after OTP verification
- Personal info, education, and employment screens work as before
- Confirmation screen shows success message
- All existing validation and error handling remains intact
