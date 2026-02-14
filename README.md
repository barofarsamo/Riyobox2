# RIYOBOX - Premium Streaming App

RIYOBOX is a production-grade movie streaming application prototype built with Flutter and Node.js. It features a modern, emoji-free UI designed for high-quality user experiences.

## 🚀 Key Features

*   **Authentication & Onboarding:** Complete flow with splash animations, multi-page onboarding, and secure login/signup.
*   **Advanced Video Player:** Custom-built player with volume/brightness gestures, playback speed controls, and quality/audio/subtitle selection.
*   **Casting:** Seamless TV casting using Google Cast SDK.
*   **Downloads & Offline Mode:** Robust download manager with progress tracking and a dedicated Offline Mode to watch saved content without internet.
*   **Admin Panel:** Secure panel for administrators to upload movies and manage content in real-time.
*   **User Web App:** A complete streaming website for users to watch content on any browser.
*   **Cloudflare R2 Storage:** Direct integration for high-performance video and image hosting with direct-to-cloud uploads.
*   **Multi-Language Support:** Global support for English, Arabic (RTL), and Somali.

## 🛠 Tech Stack

*   **Frontend:** Flutter (State management via Provider, Navigation via GoRouter).
*   **Backend:** Node.js, Express.js.
*   **Database:** MongoDB (via Mongoose).
*   **Auth:** JWT (JSON Web Tokens).

## 🌍 Cloud Deployment (Render)

The backend is configured for easy deployment on [Render](https://render.com).

1.  **Connect GitHub Repository:** Connect your repository to Render.
2.  **Environment Variables:** Add the following variables in Render dashboard:
    *   `MONGO_URI`: Your MongoDB Atlas connection string.
    *   `JWT_SECRET`: A secure random string for signing tokens.
    *   `PORT`: `5000` (Render will set this automatically).
3.  **Update Frontend:** The frontend is currently pointing to `https://riyobox1-1.onrender.com`. You can change this in `lib/core/constants.dart`.

## 📂 Project Structure

```text
riyobox/
├── lib/                      # Flutter source code
│   ├── models/               # Data models
│   ├── presentation/         # UI Screens and Widgets
│   ├── providers/            # State management
│   └── services/             # API and Casting services
├── backend/                  # Node.js source code
├── web_admin/                # React-based Admin Dashboard
├── web_user/                 # React-based User Streaming Website
└── test/                     # Widget and Unit tests
```

## ⚙️ Setup & Installation

### 1. Backend Setup
For detailed instructions on running the Node.js backend and MongoDB, please refer to the [Backend Setup Guide](./backend/README.md).

### 2. Frontend Setup
1.  Ensure you have Flutter installed (`flutter --version`).
2.  Install dependencies:
    ```bash
    flutter pub get
    ```
3.  Run the app:
    ```bash
    flutter run
    ```

## 🛡 Admin Panel Access

The Admin Panel is hidden from regular users and only appears for accounts with the `admin` role.

*   **Default Admin Credentials:**
    *   **Email:** `admin@example.com`
    *   **Password:** `admin123`

To access it, log in with the credentials above, go to **My RIYOBOX** (Profile tab), and click on **Admin Panel**.

## 📺 Casting Setup
For detailed instructions on configuring TV casting for Android and iOS, see [CAST_SETUP.md](./CAST_SETUP.md).
# Riyobox2
