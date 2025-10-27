# Backend - Battlefield Flutter Game

[![style: very good analysis][very_good_analysis_badge]][very_good_analysis_link]
[![License: MIT][license_badge]][license_link]
[![Powered by Dart Frog](https://img.shields.io/endpoint?url=https://tinyurl.com/dartfrog-badge)](https://dartfrog.vgv.dev)

Backend API for Battlefield Flutter Game, built with Dart Frog, Stormberry, and PostgreSQL.

[license_badge]: https://img.shields.io/badge/license-MIT-blue.svg
[license_link]: https://opensource.org/licenses/MIT
[very_good_analysis_badge]: https://img.shields.io/badge/style-very_good_analysis-B22C89.svg
[very_good_analysis_link]: https://pub.dev/packages/very_good_analysis

## Table of Contents

- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Environment Setup](#environment-setup)
- [Database Setup with Docker](#database-setup-with-docker)
- [Stormberry Code Generation](#stormberry-code-generation)
- [Running the Server](#running-the-server)
- [Development Workflow](#development-workflow)
- [Project Structure](#project-structure)

## Prerequisites

Before you begin, ensure you have the following installed:

- [Dart SDK](https://dart.dev/get-dart) (>=3.0.0)
- [Docker](https://www.docker.com/get-started) and Docker Compose
- [Dart Frog CLI](https://dartfrog.vgv.dev/): `dart pub global activate dart_frog_cli`

## Quick Start

1. **Clone the repository and navigate to the backend directory:**
   ```bash
   cd backend
   ```

2. **Install dependencies:**
   ```bash
   dart pub get
   ```

3. **Set up environment variables** (see [Environment Setup](#environment-setup))

4. **Start PostgreSQL with Docker:**
   ```bash
   docker-compose up -d
   ```

5. **Generate Stormberry code:**
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

6. **Run the server:**
   ```bash
   dart_frog dev
   ```

The server will start on `http://localhost:8080`

## Environment Setup

Create a `.env` file in the root directory of the project (same level as `docker-compose.yaml`):

```bash
# PostgreSQL Database Configuration
POSTGRES_DB=postgres
POSTGRES_USER=postgres
POSTGRES_PASSWORD=your_secure_password_here

# Backend Configuration
BACKEND_HOST=localhost

# JWT Secret (for authentication tokens)
SECRET_PARAPHRASE=your_very_secret_phrase_here
```

### Environment Variables Explained

- **POSTGRES_DB**: Name of the PostgreSQL database
- **POSTGRES_USER**: PostgreSQL username
- **POSTGRES_PASSWORD**: PostgreSQL password
- **BACKEND_HOST**: Database host (use `localhost` for local development, or the service name for Docker networking)
- **SECRET_PARAPHRASE**: Secret key used for JWT token signing

**Important:** Never commit the `.env` file to version control. It's already listed in `.gitignore`.

## Database Setup with Docker

The project uses Docker Compose to run PostgreSQL in a container.

### Starting the Database

```bash
# Start PostgreSQL container
docker-compose up -d

# View logs
docker-compose logs -f postgres

# Check if container is running
docker-compose ps
```

### Stopping the Database

```bash
# Stop the container
docker-compose down

# Stop and remove volumes (⚠️ deletes all data)
docker-compose down -v
```

### Database Connection

The PostgreSQL database runs on:
- **Host**: `localhost`
- **Port**: `5432`
- **Database**: As specified in `POSTGRES_DB`
- **Username**: As specified in `POSTGRES_USER`
- **Password**: As specified in `POSTGRES_PASSWORD`

## Stormberry Code Generation

This project uses [Stormberry](https://pub.dev/packages/stormberry) for database operations and migrations.

### Initial Setup

After modifying models (in `lib/models/`), generate the database schema and repository code:

```bash
dart run build_runner build --delete-conflicting-outputs
```

### Watch Mode (Automatic Regeneration)

For automatic regeneration during development:

```bash
dart run build_runner watch --delete-conflicting-outputs
```

### Generated Files

Stormberry generates the following files:
- `lib/database.schema.dart` - Database schema definition
- `lib/models/**/*.schema.dart` - Repository implementations and data transfer objects

### Database Migrations

The generated schema in `lib/database.schema.dart` is used for migrations.

To apply schema changes to the database:

```dart
// Use the generated schema
import 'package:backend/database.dart';
import 'package:stormberry/stormberry.dart';

Future<void> applyMigrations() async {
  final db = Database(
    host: 'localhost',
    database: 'postgres',
    username: 'postgres',
    password: 'postgres',
  );
  
  // Apply migrations using the generated schema
  await db.applyMigrations(schema);
}
```

### Model Definitions

Define your models using Stormberry annotations in `lib/models/`:

```dart
import 'package:stormberry/stormberry.dart';

@Model()
abstract class Player {
  @PrimaryKey()
  String get id;
  
  String get username;
  String get email;
  
  @Default('0')
  int get score;
}
```

## Running the Server

### Development Mode

```bash
# Run with hot reload
dart_frog dev

# Run on a specific port
dart_frog dev --port 8080
```

### Production Build

```bash
# Build the server
dart_frog build

# Run the built server
dart run build/bin/server.dart
```

### Docker Build

```bash
# Build Docker image
docker build -t battlefield-backend .

# Run Docker container
docker run -p 8080:8080 \
  -e POSTGRES_DB=postgres \
  -e POSTGRES_USER=postgres \
  -e POSTGRES_PASSWORD=your_password \
  -e BACKEND_HOST=postgres \
  battlefield-backend
```

## Development Workflow

1. **Make changes to models** in `lib/models/`
2. **Regenerate Stormberry code:**
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```
3. **Update API routes** in `routes/`
4. **Test locally:**
   ```bash
   dart_frog dev
   ```
5. **Run tests:**
   ```bash
   dart test
   ```

### Hot Reload

The server supports hot reload in development mode. Changes to route files will automatically trigger a restart.

## Project Structure

```
backend/
├── lib/
│   ├── database.schema.dart          # Generated database schema
│   ├── entities/                      # Data entities
│   ├── exceptions/                    # Custom exceptions
│   ├── extensions/                    # Dart extensions
│   ├── models/                        # Domain models (with Stormberry)
│   │   └── **/*.schema.dart          # Generated repository code
│   └── repositories/                  # Repository implementations
├── routes/                            # API routes
│   ├── auth/                          # Authentication endpoints
│   │   ├── login/
│   │   └── signup/
│   └── db/                            # Database middleware
├── test/                              # Unit and integration tests
├── build.yaml                         # Build configuration for Stormberry
├── docker-compose.yaml                # Docker Compose configuration
├── Dockerfile                         # Docker image configuration
└── pubspec.yaml                       # Dart dependencies
```

## API Endpoints

- **POST** `/auth/signup` - Create a new player account
- **POST** `/auth/login` - Login and receive authentication token

## Troubleshooting

### Database Connection Issues

- Ensure PostgreSQL is running: `docker-compose ps`
- Check environment variables are set correctly
- Verify database credentials in `.env`

### Stormberry Generation Errors

- Delete generated files: `rm lib/database.schema.dart lib/models/**/*.schema.dart`
- Clean build cache: `dart pub cache repair`
- Regenerate: `dart run build_runner build --delete-conflicting-outputs`

### Port Already in Use

- Change the port: `dart_frog dev --port 8081`
- Kill the process using the port

## Additional Resources

- [Dart Frog Documentation](https://dartfrog.vgv.dev/)
- [Stormberry Documentation](https://pub.dev/packages/stormberry)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)

## License

MIT