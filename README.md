# 🐦 Twitter Clone - A Flutter-Based Social Media App  

[![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev/)
[![Firebase](https://img.shields.io/badge/Firebase-%23FFCA28.svg?style=for-the-badge&logo=firebase&logoColor=black)](https://firebase.google.com/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

Twitter Clone is a modern **Flutter-based** social media application that replicates key Twitter functionalities. It allows users to **post tweets, like, retweet, follow other users, and interact with a real-time feed**. Built with Firebase, the app ensures **seamless authentication, real-time database updates, and secure data management**.

This project aims to provide a **smooth, interactive, and engaging social media experience** while following **clean architecture principles**.

## 🚀 Features  

✅ **User Authentication** – Secure sign-up and login using **Email & Password or Google Authentication**.  
✅ **Post Tweets** – Users can compose and post tweets with text, images, or GIFs.  
✅ **Like & Retweet** – Engage with tweets using **likes and retweets**.  
✅ **Follow & Unfollow** – Users can follow others to customize their feed.  
✅ **Real-time Timeline** – A dynamically updated feed displaying tweets from followed users.  
✅ **Comment System** – Users can reply to tweets and engage in discussions.  
✅ **Profile Customization** – Users can update their **bio, profile picture, and username**.  
✅ **Search Functionality** – Find users and tweets using the search bar.  
✅ **Dark Mode Support** – Switch between **light and dark themes** for a personalized experience.  

## 🛠️ Built Using  

* **Flutter** – For a beautiful and cross-platform user interface.  
* **Dart** – The powerful language behind Flutter.  
* **Firebase** – Providing a robust backend with:  
    * **Authentication** – Secure user sign-in options.  
    * **Firestore** – Real-time database for storing user profiles, tweets, and interactions.  

## 📂 Project Structure  

- 📦 **lib/**  
  - 📂 **components/** → Reusable widgets (buttons, cards, loaders, etc.)  
  - 📂 **models/** → Data models (User, Tweet, etc.)  
  - 📂 **screens/** → Main screens (Home, Profile, Notifications, etc.)  
  - 📂 **services/** → Firebase integration (Auth, Database)  
  - 📜 **main.dart** → Entry point of the application  

## ⚙️ Getting Started  

### **Prerequisites:**  

Make sure you have Flutter installed:  
```bash
flutter --version

### **1️⃣ Clone the Repository:**  
```bash
git clone https://github.com/Kaushalvadi7/twitter_clone.git
cd twitter_clone

### **2️⃣ Set up Firebase:**  
- Create a new project on the [Firebase Console](https://console.firebase.google.com/).  
- Enable **Authentication, Firestore, Storage, and Cloud Functions**.  
- Download `google-services.json` (for Android) and `GoogleService-Info.plist` (for iOS) and place them in the respective directories.  
- Configure Firestore rules to secure data.  

### **3️⃣ Install Dependencies:**  
```bash
flutter pub get

4.  **Run the Application:**
    ```bash
    flutter run
    ```

    Choose your desired target device or emulator.

## 🚀 Future Enhancements  
  
🔹 **Trending Topics Section** – Display the most popular tweets and hashtags.
🔹 **Push Notification** – Notification for like, comment and mention.
🔹 **Direct Messaging (DMs)** – Allow users to chat privately.  
🔹 **Story Feature** – Add disappearing posts similar to Instagram Stories.  

## ❤️ Contributing  

Contributions are welcome! If you find a bug or have suggestions, feel free to:  

1️⃣ **Fork the repository**  

2️⃣ **Create a new branch:**  
```bash
git checkout -b feature/amazing-feature

3️⃣ **Commit your changes:**  
```bash
git commit -m 'Add some amazing feature'

4️⃣ **Push to the branch:**
```bash
git push origin feature/amazing-feature

5️⃣ **Open a Pull Request**

## 📞 Contact & Support
  - For any queries or issues, reach out:
  - 📧 Email: kaushalvadi7777@gmail.com 
  - 🌐 GitHub: [Kaushalvadi7](https://github.com/Kaushalvadi7)  
