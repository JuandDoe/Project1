# ===== BUILD STAGE =====
FROM gradle:9.5.0-jdk-alpine AS build

ENV APP_HOME=/usr/app
WORKDIR $APP_HOME

# dépendances d'abord (cache Docker)
COPY build.gradle.kts settings.gradle.kts $APP_HOME/
COPY gradle $APP_HOME/gradle

# code source
COPY . .

# build propre
RUN gradle clean build --no-daemon

# ===== RUNTIME STAGE =====
FROM amazoncorretto:25-alpine-jdk

ENV APP_HOME=/usr/app
WORKDIR $APP_HOME

COPY --from=build /usr/app/build/libs/*.jar app.jar

EXPOSE 43000

ENTRYPOINT ["java", "-jar", "app.jar"]
