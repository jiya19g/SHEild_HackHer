SHEild - Women's Safety App
SHEild is a mobile application designed to provide safety and security for women, integrating various safety features and tools for guardians, children, and administrators. The app offers real-time emergency alerts, risk analysis based on crime rates in India, and self-defense resources. It includes features like the SOS offline button, risk notifications based on location, emergency numbers, and shake-to-alert functionality. The app also provides users with magnometer-based camera detection, self-defense training, and a review system for locations.

Features
SOS Offline Button:

Description: The SOS button can be activated offline. When clicked, it sends an alert with the user’s location to emergency contacts or authorities as soon as the user is back online. This provides a reliable way for users to send an emergency signal even when there is no internet connectivity.

Risk Analysis:

Description: The app analyzes crime data based on crime rates across different areas of India. When a user enters a high-risk area, they receive notifications about the crime risk level. The app categorizes areas as:

High Risk

Medium Risk

No Risk

This feature ensures the user is always informed about their surroundings and can take necessary precautions.

Emergency Numbers:

Description: The app provides a list of emergency numbers for police, hospitals, fire services, and other emergency contacts. Users can easily access these numbers in case of an emergency.

Shake to Alert:

Description: In case of danger, users can shake their phone to send an alert message to their guardian or selected emergency contacts. The app uses the accelerometer to detect the shaking motion and send an immediate alert.

Camera Detection using Magnetometer:

Description: The app uses the phone's magnetometer sensor to detect nearby metal objects and unusual magnetic fields. This feature is used for camera detection, ensuring users are aware if someone is attempting to take unauthorized pictures or videos.

Self-Defense Articles and Training:

Description: The app provides resources for self-defense, including articles, videos, and interactive training materials. These resources are designed to help women learn how to protect themselves in various situations.

Users:

Guardians: They can monitor the safety of their children, receive alerts, and view location-based safety data.

Children: They can use the app for emergency alerts, risk analysis, and accessing self-defense resources.

Admin: The admin has control over app settings, managing users, and viewing activity reports.

User Reviews:

Description: Users can review locations, providing feedback on whether a place is safe or unsafe. These reviews help others make informed decisions about where to go, based on the experiences of the community.

Technology Stack
Flutter: Used for building cross-platform mobile applications for both Android and iOS.

Firebase: Used for authentication, real-time database, and cloud storage.

SQLite: Used for local data storage (e.g., storing emergency contacts and reviews).

Sensors: For implementing shake-to-alert and magnetometer-based camera detection.

Web Scraping: Used to gather real-time crime data and risk analysis from reliable sources.

Dart: Programming language used with Flutter to build the app.

Setup Instructions
Clone the repository:

bash
Copy
git clone https://github.com/your-repo/SHEild.git
Install dependencies:

Navigate to the project folder and run the following command to install required dependencies:

bash
Copy
flutter pub get
Set up Firebase:

Follow the Firebase setup instructions for Flutter on Firebase for Flutter to configure Firebase Authentication, Firestore, and Firebase Storage.

Run the app:

To run the app on your device or emulator, use:

bash
Copy
flutter run
Contributions
SHEild is an open-source project. Feel free to contribute by:

Forking the repository

Creating issues and pull requests

Improving the app’s features and performance

License
This project is licensed under the MIT License - see the LICENSE file for details.

Acknowledgments
Firebase for their suite of cloud services.

Flutter for providing a powerful and fast framework for building cross-platform apps.

Google Maps API for location-based services and mapping features.

