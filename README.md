# GymBro Project

## Overview
GymBro is a fitness tracking application that allows users to log their exercises and monitor their progress. This project includes an Android home widget that displays the user's current exercise streak, providing a quick overview of their activity directly on the home screen.

## Features
- **Exercise Logging**: Users can log their exercises, including duration, repetitions, and notes.
- **Streak Tracking**: The app tracks the user's exercise streak, encouraging consistent activity.
- **Home Widget**: A widget that displays the current exercise streak with a visual indicator (fire icon) that changes color based on whether the user has exercised today.

## Widget Details
The home widget is designed to provide users with immediate feedback on their exercise streak:
- **Fire Icon**: Displays an orange icon if the user has exercised today; otherwise, it shows a gray icon.
- **Streak Count**: Shows the number of consecutive days the user has exercised.

## Setup Instructions
1. **Clone the Repository**: 
   ```
   git clone <repository-url>
   cd gymbro
   ```

2. **Open the Project**: Open the project in your preferred IDE (e.g., Android Studio).

3. **Configure the Widget**:
   - Implement the `StreakWidgetProvider` class in `android/app/src/main/kotlin/com/example/gymbro/StreakWidgetProvider.kt`.
   - Create the widget layout in `android/app/src/main/res/layout/streak_widget_layout.xml`.
   - Define the widget properties in `android/app/src/main/res/xml/streak_widget_info.xml`.
   - Update the `AndroidManifest.xml` to register the widget provider.

4. **Run the App**: Build and run the app on an Android device or emulator. Add the widget to your home screen to see your exercise streak.

## Usage
- **Logging Exercises**: Users can log exercises through the main app interface. The widget will automatically update to reflect the latest streak information.
- **Interacting with the Widget**: Tapping on the widget can be configured to open the main app, allowing users to view detailed exercise logs or add new exercises.

## Contributing
Contributions are welcome! Please submit a pull request or open an issue for any enhancements or bug fixes.

## License
This project is licensed under the MIT License. See the LICENSE file for more details.