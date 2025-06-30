# devsoc_core_assignment

# To-Do List App

A full-stack To-Do List application with user authentication, personal task management, and a clean Flutter frontend.

## ✨ Features
- User registration and login with JWT-based authentication
- Secure password storage
- Create, read, update, and delete personal tasks
- Tasks can be marked as completed or pending
- Tasks grouped and sorted by creation date
- Tasks displayed with clean, minimalist UI using a custom color theme
- Flutter frontend with modal bottom sheets for adding and editing tasks
- Persistent login using SharedPreferences
- Node.js + Express backend with MongoDB for data storage

## 🛠️ Tech Stack
- **Frontend:** Flutter
- **Backend:** Node.js, Express
- **Database:** MongoDB (via Mongoose)
- **Authentication:** JWT

## 🚀 Setup Guide

### Backend
1. Navigate to the backend directory.
2. Install dependencies:
   ```bash
   npm install
   ```
3. Set up environment variables in a `.env` file:
   ```
   MONGO_URI=<your-mongodb-connection-string>
   JWT_SECRET=<your-jwt-secret>
   PORT=3000
   ```
4. Run the server:
   ```bash
   npm run dev
   ```

### Frontend
1. Open the Flutter project in your IDE.
2. Run the app:
   ```bash
   flutter run
   ```
