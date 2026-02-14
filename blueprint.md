# Blueprint: RIYOBOX - A Netflix Clone

This document outlines the plan for creating a Netflix clone application named RIYOBOX using Flutter.

## 1. Project Overview

RIYOBOX will be a feature-rich, high-quality clone of the popular streaming service, Netflix. It will showcase a modern and responsive UI, dynamic data from a movie API, and a seamless video playback experience.

## 2. Core Features

- **Netflix-style UI**: A dark-themed, visually appealing interface that mimics the look and feel of Netflix.
- **Dynamic Content**: Movie and TV show data will be fetched from a third-party API (e.g., The Movie Database - TMDB) to provide a dynamic and up-to-date content library.
- **Movie Categories**: Browse content by categories such as "Trending," "Top Rated," and "Now Playing."
- **Movie Details**: View detailed information about each movie, including its poster, title, overview, and rating.
- **Video Playback**: A full-featured video player with custom controls for play/pause, seeking, volume, and brightness.
- **Responsive Design**: The app will be responsive and work seamlessly on both mobile and web platforms.

## 3. Architecture

I will follow a clean and scalable architecture to ensure the app is maintainable and easy to expand upon in the future.

- **Model-View-ViewModel (MVVM)**: I will adopt the MVVM pattern to separate the UI from the business logic.
- **Services**: A dedicated service layer for handling API calls and data fetching.
- **Models**: Data models to represent the movie data received from the API.

## 4. Implementation Plan

### Phase 1: Foundation and UI Setup

1.  **Project Setup**: 
    - Create a new `blueprint.md` file.
    - Update the project name to "RIYOBOX" in `pubspec.yaml`, `README.md`, and `web/index.html`.
    - Add necessary dependencies: `http` for API calls.
2.  **Theming**: 
    - Create a dark theme in `lib/main.dart` to match the Netflix aesthetic.
3.  **File Structure**: 
    - Create `lib/models` and `lib/services` directories.
    - Create the necessary screen and widget files.

### Phase 2: Home Screen and Movie Display

1.  **API Service**: 
    - Create a service to fetch movie data from the TMDB API.
2.  **Home Screen**: 
    - Build the home screen with a `FutureBuilder` to display a list of movies.
    - Create horizontal carousels for different movie categories.
3.  **Movie Card Widget**: 
    - Design a `MovieCard` widget to display each movie's poster.

### Phase 3: Movie Details and Navigation

1.  **Movie Details Screen**: 
    - Create a screen to display detailed information about a selected movie.
2.  **Routing**: 
    - Implement routing using `go_router` to navigate between the home screen and the movie details screen.

### Phase 4: Video Playback

1.  **Integrate Video Player**:
    - Connect the "Play" button on the movie details screen to the existing `VideoPlayerScreen`.

## 5. Current Task: Initial Setup

I will now begin by setting up the project, including updating the necessary files and adding the `http` dependency.
