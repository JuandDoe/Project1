# Project1

A Java application built with Gradle and containerized with Docker.

---

## Requirements

- Java 25+
- Gradle 9+
- Docker & Docker Compose

---

## Getting Started

### Local build

```bash
cp gradle.example.properties gradle.properties
# Edit gradle.properties with your configuration
./gradlew build
```

### Run with Docker

Export the required environment variables before starting:

```bash
export APP_PORT=42000
export EXPOSED_PORT=43000
docker compose up --build
```

Or override the defaults directly inline:

```bash
APP_PORT=42000 EXPOSED_PORT=43000 docker compose up --build

The application will be available at `http://localhost:43000`.

---

## Project Structure

```
src/main/java/org/example/   # Application source code
documentation/               # Project documentation
code_review/                 # Code review notes
```

---

## Configuration

Copy `gradle.example.properties` to `gradle.properties` and fill in the required values.  
This file is excluded from version control and injected as a Docker secret at build time.
