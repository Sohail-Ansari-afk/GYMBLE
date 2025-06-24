# Gymble Flutter App

A gym management application built with Flutter that helps gym owners and members manage memberships, check-ins, plans, and payments.

## Features

- **Authentication**: User registration and login
- **Dashboard**: Overview of gym activities and stats
- **Check-in**: QR code-based gym check-in system
- **Plans**: Membership plan management
- **Payments**: Payment history and subscription management

## Project Structure

```
gymble-flutter/
├── lib/
│   ├── src/
│   │   ├── features/      # Auth, dashboard, checkin, plans, payments
│   │   ├── core/          # Shared widgets, utils
│   │   └── app.dart       # Main app
├── scripts/               # MongoDB connection helpers
└── test/                  # Unit and widget tests
```

## Getting Started

### Prerequisites

- Flutter SDK (version 3.0.0 or higher)
- Dart SDK (version 3.0.0 or higher)
- MongoDB (for backend data storage)

### Installation

1. Clone the repository
   ```
   git clone https://github.com/yourusername/gymble-flutter.git
   ```

2. Navigate to the project directory
   ```
   cd gymble-flutter
   ```

3. Install dependencies
   ```
   flutter pub get
   ```

4. Run the app
   ```
   flutter run
   ```

## MongoDB Setup

1. Install MongoDB on your system or use MongoDB Atlas cloud service
2. Create a database named 'gymble'
3. Update the connection string in `scripts/mongodb_helper.dart` if needed

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.
