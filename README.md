# 🏝️ VAYCAY - Travel Discovery App

VAYCAY is a visually engaging travel discovery app that allows users to explore destinations, save favorites, and get personalized travel recommendations. It integrates APIs like **Google Places** and **Unsplash** to provide stunning images and detailed place information.

---

## ✨ Features
- 🔎 **Explore Places** – Search for destinations by category and location.
- ❤️ **Save Favorites** – Bookmark and manage favorite places.
- 🖼 **High-Quality Images** – Fetches images from **Unsplash API** and **Google Places API**.
- 🔐 **User Authentication** – Sign in with **Firebase Authentication**.
- 📍 **Detailed Place Info** – View ratings, reviews, and location details.
- 🌍 **Smooth UI & Navigation** – Built with SwiftUI.

---

## 📦 Dependencies
To run this project, ensure you have the following dependencies installed:

| Dependency | Description |
|------------|-------------|
| `SwiftUI` | Used for building the UI. |
| `FirebaseAuth` | Manages user authentication. |
| `Firestore` | Stores user preferences and favorites. |
| `GooglePlacesAPI` | Fetches place details and location-based results. |
| `UnsplashAPI` | Fetches high-quality travel images. |
| `CoreLocation` | Used for location-based searches. |

---

# 🚀 Setup Instructions


## 1️⃣ **Clone the Repository**
```sh
git clone https://github.com/taty1202/VAYCAY.git && cd VAYCAY 
```
## 2️⃣ **Install Dependencies**
Ensure you have **CocoaPods** installed:
```sh
sudo gem install cocoapods
```
## 3️⃣ Set Up Firebase
- Create a Firebase project at [Firebase Console](https://console.firebase.google.com/).
- Download the `GoogleService-Info.plist` file and place it in your Xcode project root.
- Enable Authentication (Email/Google Sign-In) and Firestore Database.

## 4️⃣ Get API Keys
#### Google Places API Key
- Enable the API from the [Google Cloud Console](https://console.cloud.google.com/).
- Add the key in `GooglePlacesAPI.swift`.

#### Unsplash API Key
- Sign up at [Unsplash Developers](https://unsplash.com/developers).
- Add your key in `UnsplashAPI.swift`.

### 5️⃣ Run the App
- Connect a physical iPhone or use an Xcode Simulator.
- In Xcode, select your device/simulator → Click **Run** (▶️).
- If running on an iPhone, ensure you have an **Apple Developer Account** set up.

### 🛠 Troubleshooting

❌ **App won’t install on iPhone?**  
- Ensure you have a valid Apple Developer Account.

🖼 **Images not loading?**  
- Check API keys for Google Places and Unsplash.

---

📜 **License**  
This project is licensed under the [MIT License](https://opensource.org/licenses/MIT).


🚀 **Happy Traveling!** 🌍✈️
