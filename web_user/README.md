# RIYOBOX User Web Application

A high-performance web application for users to stream movies and TV shows from the RIYOBOX ecosystem.

## 🚀 Features

*   **Responsive Design:** Optimized for Desktop, Tablet, and Mobile browsers.
*   **Authentication:** Full Login/Signup flow.
*   **Netflix-style UI:** Hero sections, movie rows with carousels, and detailed movie pages.
*   **Advanced Web Player:** Custom HTML5 video player with seek controls and fullscreen support.
*   **Personalization:** "My List" (Watchlist) synchronization across all devices.
*   **Global Search:** Find content by title or genre.

## 🛠 Tech Stack

*   **Framework:** React (Vite)
*   **Styling:** Tailwind CSS
*   **Icons:** Lucide React
*   **API:** Axios

## 📦 Deployment to Vercel

1.  **Move to the web_user directory:**
    ```bash
    cd web_user
    ```
2.  **Install dependencies:**
    ```bash
    npm install
    ```
3.  **Build the project:**
    ```bash
    npm run build
    ```
4.  **Deploy:**
    Connect this directory to Vercel. It will automatically use the settings from `vercel.json`.

## ⚙️ Configuration

The app is pre-configured to connect to the production backend at `https://riyobox1-1.onrender.com`. To change this, edit `web_user/src/utils/api.js`.
