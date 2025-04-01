# Battlefield Flutter Game

A modern multiplayer game built with Flutter and Dart Frog, leveraging Firebase services for real-time gaming experience.

## Architecture

This project follows Clean Architecture principles and is organized into frontend and backend components.

### Frontend Architecture (Flutter)

The frontend follows a layered architecture pattern:

- **Presentation Layer** (`features/`)
  - Contains UI components and BLoC state management
  - Feature-first organization (auth, game, leaderboard, profile)
  - Handles user interactions and state updates

- **Domain Layer** (`domain/`)
  - Business logic and rules
  - Use cases
  - Entity definitions
  - Repository interfaces

- **Data Layer** (`data/`)
  - Repository implementations
  - Data models
  - Remote and local data sources

### Backend Architecture (Dart Frog)

The backend follows an MVC-like pattern:

- **Routes** (`routes/`)
  - API endpoints
  - Webhook handlers

- **Controllers** (`src/controllers/`)
  - Request handling
  - Response formatting

- **Services** (`src/services/`)
  - Business logic
  - External service integration

## Technology Stack

### Frontend

- Flutter SDK
- Casual Game Toolkit
- Firebase Authentication
- Firebase Storage
- Firebase Cloud Messaging (Push Notifications)
- BLoC Pattern (State Management)
- Get It (Dependency Injection)

### Backend

- Dart Frog
- Firebase Admin SDK
- Docker
- Railway (Hosting)

## Project Structure
