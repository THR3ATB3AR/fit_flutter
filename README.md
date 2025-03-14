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
* **Popular Repacks:** See a list of the most popular repacks.
* **New Repacks:**  Browse the latest repacks added to the site.
* **Auto Updates:** The application can automatically check for and download updates to ensure you always have the latest features and fixes.
* **Windows 11 Acrylic Design:** The app features a modern Windows 11 acrylic design for a sleek and visually appealing interface.
* **Windows Accent Color:** The application adapts to the user's Windows accent color for a more integrated and personalized experience.
* **Torrent Support:** Download repacks using torrent files (requires a torrent client).
* **Cross-Platform Support:** FitFlutter is designed to work seamlessly on both Windows and Linux, with plans to support Android in the future.

## Screenshots

![Alt text](images/readme/1.png?raw=true "Home Page")
![Alt text](images/readme/2.png?raw=true "Repack Info")
![Alt text](images/readme/3.png?raw=true "Repack Screenshots")
![Alt text](images/readme/4.png?raw=true "Repack Search")

## Roadmap & Future Enhancements 🚀

FitFlutter is continuously evolving!  Here's a glimpse of what's coming:

* [ ] 📱 **Android Support:** Implement and test full support for Android devices.
* [ ] 🎨 **More Themes:** Add support for light and dark theme to allow users to personalize the app's appearance.
* [ ] 🔄️ **Cache for Repacks:**  Utilize previously scraped data for faster access.

I am open for contributions and suggestions!

## Known Issues 🐛

These issues have been reported by tester and may not affect all users:

* **Windows 10 Transparency:** On Windows 10, the entire application window may appear transparent.
* **Windows 10 Drag Lag/Cursor Copying:** On Windows 10, dragging the application window can be slow and may create visual artifacts, like multiple copies of the cursor.  This seems to be related to window redrawing.
* **Limited Testing:** The application has had limited testing (only one tester), these issues might not reproduce on all devices.

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
