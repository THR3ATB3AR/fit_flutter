# FitFlutter 🏋️‍♀️🦋

| [![Crowdin](https://badges.crowdin.net/fit-flutter/localized.svg)](https://crowdin.com/project/fit-flutter) | [![GitHub release (latest by date)](https://img.shields.io/github/v/release/THR3ATB3AR/fit_flutter)](https://github.com/THR3ATB3AR/fit_flutter/releases/latest) | [![GitHub downloads](https://img.shields.io/github/downloads/THR3ATB3AR/fit_flutter/latest/total)](https://github.com/THR3ATB3AR/fit_flutter/releases/latest) | [![GitHub forks](https://img.shields.io/github/forks/THR3ATB3AR/fit_flutter)](https://github.com/THR3ATB3AR/fit_flutter/forks) | [![GitHub stars](https://img.shields.io/github/stars/THR3ATB3AR/fit_flutter)](https://github.com/THR3ATB3AR/fit_flutter/stargazers) |
| ------------------------------------------------------------------------------------------------------ | ---------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------ |

FitFlutter is a Flutter-based application designed to browse and download FitGirl Repacks.  It provides a convenient, cross-platform way to access FitGirl's extensive library of compressed game installers.  Think of it as a *very* unofficial FitGirl client.  This project is intended for educational purposes and to improve my Flutter skills.

**Disclaimer:**  This application is not affiliated with or endorsed by FitGirl.  Using this application to download copyrighted material without permission is illegal in many jurisdictions.  You are solely responsible for complying with all applicable laws and regulations.  Use this application at your own risk. I am not responsible for how you use it.

## Features ✨

* **Search Repacks:** Quickly find the repack you're looking for using a built-in search function.
* **Repack Details:** View detailed information about each repack, including game title, original size, repack size, compression details, and more.
* **Screenshots:**  Browse screenshots of the game before downloading.
* **"FuckingFast" Downloads:** Download repacks directly using the "FuckingFast" (direct download) links (if available).
* **New And Popular Repacks:** See a list of the latest repacks added to the site and the most popular repacks.
* **Auto Updates:** The application can automatically check for and download updates to ensure you always have the latest features and fixes.
* **Windows 11 Acrylic Design:** The app features a modern Windows 11 acrylic design for a sleek and visually appealing interface.
* **Windows Accent Color:** The application adapts to the user's Windows accent color for a more integrated and personalized experience.
* **Torrent Support:** Download repacks using torrent files (requires a torrent client).
* **Cross-Platform Support:** FitFlutter is designed to work seamlessly on Windows, Android and Linux.
* **Caching Repacks:** Save scraped repacks to disk for faster loading.
* **Auto Install Repacks:** Automatically install downloaded repacks to a specified directory, streamlining the setup process.

## Screenshots

![Alt text](images/readme/1.png?raw=true "Home Page")
![Alt text](images/readme/2.png?raw=true "Repack Library")
![Alt text](images/readme/3.png?raw=true "Repack Screenshots")
![Alt text](images/readme/4.png?raw=true "Download Manager")
![Alt text](images/readme/5.png?raw=true "Settings")

## Roadmap & Future Enhancements 🚀

FitFlutter is continuously evolving!  Here's a glimpse of what's coming:

I am open for contributions and suggestions!

## Known Issues 🐛

This section lists known issues that have been reported.  While these issues have been observed, they may not affect all users or all devices.  We are working to resolve them.

* **Null Check Errors:**  If you encounter a Null Exception or a similar "null check" error, deleting the application's settings file will likely resolve the issue.
  * **Windows:** Delete the settings file located at `%APPDATA%\com.example\fit_flutter\FitFlutter`.
  * **Android:** Clear the application's data through your device's settings menu (usually found under "Apps" or "Application Manager").
* **Aero Theme** The aero theme causes lag on window drag in Windows 11.
* **Limited Testing:** The application has undergone limited testing primarily on a single device/configuration.  Therefore, some issues may be specific to certain devices, operating system versions, or user configurations.  We are actively seeking broader testing to identify and address such issues.

## Installation

### Windows

To install and run the latest setup of FitFlutter, follow these steps:

1. **Download the Latest Release:**

   * Visit the [Releases](https://github.com/THR3ATB3AR/fit_flutter/releases/latest) page on GitHub.
   * Download the latest release for your operating system.
2. **Run Setup:**

   * Install the app to a directory of your choice.

### Linux

1. **Download the tar.gz File:**

   * Visit the [Releases](https://github.com/THR3ATB3AR/fit_flutter/releases/latest) page on GitHub.
   * Download the latest `fit_flutter.tar.gz` file for Linux.
2. **Extract the tar.gz File:**

   ```bash
   tar -xzf fit_flutter.tar.gz -C /path/to/install/directory
   ```

3. **Run the Application:**

   ```bash
   cd /path/to/install/directory/fit_flutter
   ./fit_flutter
   ```

## Building

1. **Prerequisites:**

   * Flutter SDK installed and configured. (See [Flutter Installation Guide](https://docs.flutter.dev/get-started/install))
   * Dart SDK (usually comes with Flutter).
   * An emulator or physical device for testing.
2. **Clone the Repository:**

   ```bash
   git clone https://github.com/THR3ATB3AR/fit_flutter.git
   cd fit_flutter
   ```

3. **Get Dependencies:**

   ```bash
   flutter pub get
   ```

4. **Run the App:**

   ```bash
   flutter run
   ```

   or to build:

   ```bash
   flutter build windows # for windows
   flutter build android # for android
   flutter build linux # for linux
   ```

   See [Flutter build documentation](https://docs.flutter.dev/deployment/build-guides)

## Acknowledgements

* FitGirl Repacks (for the repack content, though this project is unofficial).
* The Flutter team and community.
* Google Gemini for creating this readme

## Contact

If you have any questions or suggestions, feel free to open an issue on GitHub.
