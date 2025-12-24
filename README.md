# Reluna Family App

A Flutter application for family governance and management.

## Features

- 📊 **Dashboard** - Overview of family activities, decisions, and meetings
- 📜 **Constitution** - Family constitution management with versioning
- 👥 **Members** - Family member profiles and management
- 🗳️ **Decisions** - Voting system for family decisions
- 📅 **Meetings** - Schedule and manage family meetings
- 💬 **Chat** - Family communication channels
- 🔔 **Notifications** - Stay updated on family activities
- 💰 **Assets** - Family asset management
- 📚 **Education** - Educational resources for family members
- 🤝 **Philanthropy** - Charitable giving management
- 📋 **Succession** - Succession planning
- ⚖️ **Conflict Resolution** - Family dispute resolution
- 👤 **Profile & Settings** - User profile and app settings

## Tech Stack

- **Flutter** 3.27+
- **Dart** 3.6.0
- **State Management**: Riverpod
- **Routing**: auto_route
- **UI**: Adaptive design (Material/Cupertino)

## Getting Started

### Prerequisites

- Flutter SDK 3.27+
- Xcode (for iOS)
- Android Studio (for Android)

### Installation

```bash
# Clone the repository
git clone https://github.com/[username]/refamily-app.git

# Navigate to project directory
cd refamily-app

# Install dependencies
flutter pub get

# Generate routes
dart run build_runner build

# Run the app
flutter run
```

## Project Structure

```
lib/
├── core/
│   ├── adaptive/      # Adaptive UI widgets
│   ├── providers/     # Global providers
│   ├── router/        # App routing
│   ├── services/      # Core services
│   └── theme/         # App theming
├── data/
│   ├── models/        # Data models
│   └── services/      # Data services
└── features/
    ├── assets/
    ├── auth/
    ├── chat/
    ├── communication/
    ├── conflict_resolution/
    ├── constitution/
    ├── dashboard/
    ├── decisions/
    ├── education/
    ├── main/
    ├── meetings/
    ├── members/
    ├── notifications/
    ├── philanthropy/
    ├── platform/
    ├── profile/
    ├── settings/
    └── succession/
```

## License

This project is proprietary software.
