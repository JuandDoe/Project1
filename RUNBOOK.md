# RUNBOOK

Operational guide for maintaining and troubleshooting Project1.

---

# Overview

Project1 is a Java application built with Gradle and deployed using Docker Compose.

This document explains how to:

- build the application,
- run it locally or with Docker,
- diagnose common issues,
- recover from failures.

---

# Requirements

Required tools:

- Java 25+
- Gradle 9+
- Docker
- Docker Compose

Optional:

- pre-commit 4.2.0

Verify installation:

```bash
#Check java toolchain instalation
cd /usr/lib/jvm/java-21-openjdk-amd64
cat bin/javac
#Check gradle wrapper version 
./gradlew --version
# Check docker version
docker --version
# Check docker compose version
docker compose version
```


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
```
# Common failures & fixes 

```bash
1) Container run but /test is unreachable 

- Make sure the java http server is not listening on the 127.0.0.1 /localhost network interface of the container
- Check int Main.java for InetAddress inetAddress = InetAddress.getByName("0.0.0.0");

2) Container uses too much memory and becomes slow or unstable

- If you notice the container taking a while to start runing and end up with "exited with code 137"
- check the root cause as following : 
 docker ps -a 
<your_container_id>  project1:latest   "java -jar app.jar"   30 seconds ago   Exited (137) 30 seconds ago             1task-app-1
docker inspect your_container_id | grep OOMKilled
if you see : → "OOMKilled": true
- The container is in lack of RAM to run properly. Please consider  allowing more RAM


3) Gradle fails to resolve dependencies due to missing/wrong repo credentials.

IN THIS EXACT ORDER :
- Check that have not mysstyped credentials 
- Look the README.md for any change to valid credentials 
- Open an issue labelled as "Credentials_issue"
```




