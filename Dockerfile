# ===== BUILD STAGE =====
FROM gradle:9.5.0-jdk-alpine AS build
ENV APP_HOME=/usr/app
WORKDIR $APP_HOME
COPY build.gradle.kts settings.gradle.kts $APP_HOME/
COPY gradle $APP_HOME/gradle
COPY . .
RUN gradle clean shadowJar --no-daemon

# ===== RUNTIME STAGE =====
FROM amazoncorretto:25-alpine-jdk
ENV APP_HOME=/usr/app
WORKDIR $APP_HOME
COPY --from=build /usr/app/build/libs/*.jar app.jar

# Créer user non-root DANS l'image (pas au démarrage)
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
USER appuser

EXPOSE 43000
ENTRYPOINT ["java", "-jar", "app.jar"]