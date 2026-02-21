# HamiKisan Application - Default User Credentials

## Updated: January 31, 2026

### Regular Users

#### Farmer Account
- **Username**: `9800000000` (same as phone number)
- **Password**: `@Testuser123`
- **Email**: testuser@hamikisan.com
- **Phone**: 9800000000
- **Role**: Farmer
- **Name**: Test Farmer
- **Location**: Kathmandu, Nepal

#### Doctor Account
- **Username**: `9800000001` (same as phone number)
- **Password**: `@Testdoctor123`
- **Email**: testdoctor@hamikisan.com
- **Phone**: 9800000001
- **Role**: Kisan Doctor
- **Name**: Test Doctor
- **Location**: Pokhara, Nepal
- **Specialization**: Crop Disease Specialist

### Admin Accounts

#### Super Admin
- **Username**: `HamiSuperKisan`
- **Password**: `@PhulasiPokhari.`
- **Email**: superadmin@hamikisan.com
- **Role**: Super Admin
- **Access URLs**: 
  - `/admin`
  - `/HamiSuperAdmin`
- **Admin Key**: `HAMIKISAN_KRISHI_ADMIN_2024`
- **Permissions**: Full system access, system control, manage admins

#### Kisan Admin
- **Username**: `KisanAdmin`
- **Password**: `@NepaliKisan923.`
- **Email**: kisanadmin@hamikisan.com
- **Role**: Kisan Admin
- **Access URLs**: 
  - `/admin`
  - `/kisan-admin`
- **Admin Key**: `HAMIKISAN_KRISHI_ADMIN_2024`
- **Permissions**: Manage users, manage content, approve users

## Two-Factor Authentication

All admin accounts require 2FA verification after entering credentials.
- **Demo 2FA Code**: `123456`

## Notes

1. All passwords are securely hashed using SHA-256 with salt
2. Database version is set to `v4` to force re-initialization with new credentials
3. Admin routes are protected with security keys and role verification
4. On web platform, database features are limited and some advanced features may not be available
5. Old demo users (farmer/farmer123, doctor/doctor123) have been removed
