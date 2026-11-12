# Running the app in Debug mode

This guide will walk you through running the Flutter app in **debug mode** using either **Android Studio** or **VSCode**. The setup also involves using **build_runner** and is tested with **Flutter version 3.50** and **Dart 3.14**.

## Prerequisites

- **Flutter 3.50**: Make sure Flutter is installed and is updated to version 3.50. Dart 3.14 is bundled with it.
- **Dart SDK**: Comes bundled with Flutter, so no separate installation needed.
- **Build Runner**: To generate necessary files, you need to use `build_runner`.
- **Device/Emulator**: Android or iOS emulator, or a physical device connected via USB.

## Option 1: Using Android Studio

### Step 1: Install Android Studio

- Download and install Android Studio from [here](https://developer.android.com/studio).

### Step 2: Flutter & Dart Plugins

- Open Android Studio, go to **File** > **Settings** > **Plugins**.
- Search for the following plugins and install them:
    - **Flutter**: [Link to Plugin](https://plugins.jetbrains.com/plugin/9212-flutter)
    - **Dart**: [Link to Plugin](https://plugins.jetbrains.com/plugin/6351-dart)

### Step 3: Open Your Flutter Project

- Launch Android Studio and **Open** your existing Flutter project or create a new one.

### Step 4: Run the App in Debug Mode

- **Terminal**: You can use the terminal inside Android Studio to run `flutter pub run build_runner build` to generate necessary files.
- **Run App**: Click on the green **Play** button in the toolbar or press **Shift + F9** to run the app in **Debug Mode**.
- Alternatively, you can use the terminal to run:
  ```bash
  flutter run
  ```
  to start the app in debug mode.

### Notes on Build Runner

- Use the following command when making changes to your generated files:
  ```bash
  flutter pub run build_runner build
  ```
    - **Watch Mode**: If you want to automatically regenerate files on file changes:
  ```bash
  flutter pub run build_runner watch
  ```

## Option 2: Using Visual Studio Code (VSCode)

### Step 1: Install VSCode

- Download and install VSCode from [here](https://code.visualstudio.com/).

### Step 2: Install Extensions

- Install the following extensions for a better Flutter development experience:
    - **Flutter**: [Link to Extension](https://marketplace.visualstudio.com/items?itemName=Dart-Code.flutter)
    - **Dart**: [Link to Extension](https://marketplace.visualstudio.com/items?itemName=Dart-Code.dart-code)
- To install extensions:
    - Open VSCode, click on the **Extensions** icon on the sidebar (or press **Cmd + Shift + X** on macOS or **Ctrl + Shift + X** on Windows).
    - In the search bar, type **Flutter** and click **Install**.
    - Repeat for the **Dart** extension.

### Step 3: Open Your Flutter Project

- Open VSCode and **Open Folder** to access your Flutter project.

### Step 4: Run the App in Debug Mode

- **Run Build Runner**: First, run `flutter pub run build_runner build` in the terminal to generate files as needed.
- **Start Debugging**: Press **F5** or click on **Run** > **Start Debugging** to run the app in debug mode.
- You can also use the **Run and Debug** tab from the sidebar to start debugging with more options.

### Shortcut Commands

- **Flutter Run**: You can also start your Flutter app in debug mode using the terminal with:
  ```bash
  flutter run
  ```
- **Hot Reload & Restart**: While in debug mode, you can use **Hot Reload** (`r`) and **Hot Restart** (`R`) in the terminal to quickly test changes.

## Connecting a Real Android Device or Using an Emulator

### Connecting a Real Android Device

1. **Enable Developer Options** on your Android device:
    - Go to **Settings** > **About Phone** > **Build Number**.
    - Tap **Build Number** seven times to enable **Developer Options**.
2. **Enable USB Debugging**:
    - Go to **Settings** > **Developer Options** > **USB Debugging** and turn it on.
3. **Connect Your Device**:
    - Connect your Android device to your computer via USB.
4. **Verify Device Connection**:
    - Run the following command to check if your device is detected:
   ```bash
   flutter devices
   ```
    - Your device should appear in the list. You can now run the app using:
   ```bash
   flutter run
   ```

### Using an Android Emulator

1. **Create an Emulator in Android Studio**:
    - Open Android Studio and click on **Tools** > **AVD Manager**.
    - Click **Create Virtual Device** and follow the prompts to configure your emulator.
2. **Start the Emulator**:
    - Once created, start the emulator by clicking the **Play** button next to your virtual device.
3. **Run the Flutter App**:
    - Make sure the emulator is running, then run:
   ```bash
   flutter run
   ```
    - Your app should launch on the emulator.

## Useful Commands Summary

- **Run Build Runner**:
  ```bash
  flutter pub run build_runner build
  ```
- **Watch for Changes**:
  ```bash
  flutter pub run build_runner watch
  ```
- **Run Flutter App**:
  ```bash
  flutter run
  ```
- **Hot Reload**: Press `r` in the terminal after making changes.
- **Hot Restart**: Press `R` for a full restart.

## Links for Reference

- **Flutter Plugin for Android Studio**: [JetBrains Flutter Plugin](https://plugins.jetbrains.com/plugin/9212-flutter)
- **Dart Plugin for Android Studio**: [JetBrains Dart Plugin](https://plugins.jetbrains.com/plugin/6351-dart)
- **Flutter Extension for VSCode**: [VSCode Marketplace](https://marketplace.visualstudio.com/items?itemName=Dart-Code.flutter)
- **Dart Extension for VSCode**: [VSCode Marketplace](https://marketplace.visualstudio.com/items?itemName=Dart-Code.dart-code)

## Conclusion

With this setup, you should be able to run your Flutter app in debug mode using either Android Studio or VSCode, ensuring a productive development environment with **build_runner** capabilities.

If you run into any issues, make sure your Flutter version is correctly set up, your plugins/extensions are updated, and your connected devices or emulators are properly configured.

