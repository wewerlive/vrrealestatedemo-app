# VR Real Estate Demo - App

This Flutter project is a demonstration of a VR Real Estate application. It includes features such as user authentication, device management, and estate browsing.

## Table of Contents

- [VR Real Estate Demo - App](#vr-real-estate-demo---app)
  - [Table of Contents](#table-of-contents)
  - [Project Structure](#project-structure)
  - [Setup](#setup)
    - [Prerequisites](#prerequisites)
    - [Installation](#installation)
      - [Installing Flutter](#installing-flutter)
        - [macOS](#macos)
        - [Windows](#windows)
      - [Project Setup](#project-setup)
  - [Running the Project](#running-the-project)
  - [Troubleshooting](#troubleshooting)

## Project Structure

The main project structure is as follows:

```
vrrealstatedemo/
├── android/
├── ios/
├── lib/
│   ├── screens/
│   │   ├── DevicesPage.dart
│   │   ├── EstatesPage.dart
│   │   └── LoginPage.dart
│   └── main.dart
├── assets/
│   └── app-icon.png
├── pubspec.yaml
├── README.md
└── .env
```

## Setup

### Prerequisites

Before you begin, ensure you have met the following requirements:

- Flutter SDK (latest stable version)
- Dart SDK
- Android Studio / Xcode (for iOS development)
- An IDE (e.g., VS Code, IntelliJ IDEA)

### Installation

#### Installing Flutter

##### macOS

1. Download the Flutter SDK from the [official Flutter website](https://flutter.dev/docs/get-started/install/macos).
2. Extract the downloaded file in the desired location, e.g.:

   ```bash
   cd ~/development
   unzip ~/Downloads/flutter_macos_<version>-stable.zip
   ```

3. Add Flutter to your path:

   ```bash
   export PATH="$PATH:`pwd`/flutter/bin"
   ```

4. Run `flutter doctor` to check for any additional dependencies you may need to install.

##### Windows

1. Download the Flutter SDK from the [official Flutter website](https://flutter.dev/docs/get-started/install/windows).
2. Extract the zip file and place the contained `flutter` folder in the desired installation location for the Flutter SDK (e.g., `C:\src\flutter`).
3. Update your path:
   - From the Start search bar, type 'env' and select "Edit environment variables for your account"
   - Under "User variables" check if there is an entry called "Path"
   - If the entry exists, append the full path to `flutter\bin` using `;` as a separator from existing values.
   - If the entry doesn't exist, create a new user variable named `Path` with the full path to `flutter\bin` as its value.
4. Run `flutter doctor` to check for any additional dependencies you may need to install.

#### Project Setup

1. Clone the repository:

   ```bash
   git clone https://github.com/wewerlive/vrrealstatedemo.git
   cd vrrealstatedemo
   ```

2. Install dependencies:

   ```bash
   flutter pub get
   ```

3. Set up environment variables:
   - Create a `.env` file in the root directory of the project
   - Add necessary environment variables (e.g., API endpoints, keys)

## Running the Project

To run the project, use the following command:

```bash
flutter run
```

This will start the app on your connected device or emulator.

## Troubleshooting

Here are some common issues you might encounter and how to resolve them:

1. **"flutter command not found" error**
   - Ensure Flutter is correctly added to your PATH.
   - Try restarting your terminal or IDE.

2. **Build fails due to missing dependencies**
   - Run `flutter pub get` to fetch all dependencies.

3. **Android SDK not found**
   - Ensure Android Studio is installed and the Android SDK is properly set up.
   - Run `flutter doctor` to check for any issues with Android setup.

4. **iOS build fails**
   - Ensure Xcode is installed (for macOS users).
   - Run `sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer` to set the correct Xcode path.

5. **WebSocket connection issues**
   - Check your internet connection.
   - Verify that the WebSocket server URL in the `.env` file is correct.

If you encounter any other issues, please check the [Flutter documentation](https://flutter.dev/docs) or open an issue in the project repository.