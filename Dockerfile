# ===== BUILD STAGE =====
# Defines the first stage named "build".
# Uses the official Gradle 9.5.0 image with JDK on Alpine Linux.
# This stage is responsible for compiling the application and producing the JAR.
# A stage contain layers (a bit as objects contains fields)
FROM gradle:9.5.0-jdk-alpine AS build

# Declares an environment variable APP_HOME pointing to the app's working directory.
ENV APP_HOME=/usr/app

# Sets /usr/app as the current working directory for all subsequent instructions in this stage.
WORKDIR $APP_HOME

# Copies only the Gradle configuration files into the container.
# Done before copying source code to create a separate Docker layer for dependency resolution.
# If these files don't change, Docker reuses this cached layer on rebuild.
COPY build.gradle.kts settings.gradle.kts $APP_HOME/

# Copies the Gradle wrapper folder into the container.
# Also isolated in its own layer for caching purposes.
COPY gradle $APP_HOME/gradle

# Downloads all project dependencies and caches them.
# --mount=type=secret: injects gradle.properties at build time only — it is never written
#   into any image layer, so credentials (repo URL, username, password) are never extractable
#   from the final image even with docker history or docker inspect.
# Mount secret  named gradle_props  at /usr/app/gradle.properties. Secret exist only during RUN command execution


# --mount=type=cache: mounts /root/.gradle as a persistent cache volume on the host machine.
#   On subsequent builds, Gradle finds its dependencies already downloaded and skips the download.
# gradle dependencies: resolves and downloads all dependencies without compiling any code.
#   Creates a dedicated Docker layer — if build.gradle.kts doesn't change, this entire
#   step is skipped on rebuild via Docker layer cache.
RUN --mount=type=secret,id=gradle_props,target=/usr/app/gradle.properties \
    --mount=type=cache,target=/root/.gradle \
    gradle dependencies --no-daemon

# Copies only the source code into the container.
# Placed after the dependency download step intentionally — modifying source code only
# invalidates this layer and the ones after it, leaving the dependency layer cached.
COPY src $APP_HOME/src

# Compiles the source code and packages the application into a fat JAR (shadowJar).
# Same secret and cache mounts as above:
# - gradle.properties is injected securely for repo credentials
# - /root/.gradle cache is reused so dependencies are not re-downloaded
# gradle shadowJar: compiles Java sources and bundles all dependencies into a single JAR.
# --no-daemon: prevents Gradle from starting a background daemon, suitable for containers.
RUN --mount=type=secret,id=gradle_props,target=/usr/app/gradle.properties \
    --mount=type=cache,target=/root/.gradle \
    gradle shadowJar --no-daemon

# Okay got it the image worked fine cause the mavenCentral() fallback, once commented build failed
# secrets: gradle_props: file: ./gradle.properties was needed in compose to success

# ===== JLINK STAGE =====
# Defines the second stage named "jre-build".
# Uses the full Corretto 25 JDK image solely to run jlink and produce a custom JRE.
# This stage is discarded after the runtime stage copies its output.
FROM amazoncorretto:25-alpine-jdk AS jre-build

# Installs binutils which provides objcopy, required by jlink's --strip-debug option on Alpine.
# Without this, jlink fails with "Cannot run program objcopy".
# --no-cache: does not cache the apk index locally, keeping the layer smaller.
RUN apk add --no-cache binutils

# Builds a minimal custom JRE containing only the modules the application actually needs,
# as determined by running jdeps on the fat JAR.
# --add-modules: explicitly lists the required Java modules identified by jdeps.
#   java.base        — core Java classes, always required
#   java.instrument  — Java instrumentation API
#   java.naming      — JNDI naming and directory services
#   java.xml         — Java xml
#   java.logging     —  Java log
#   jdk.compiler     — Java compiler API
#   jdk.unsupported  — sun.misc.Unsafe and other unofficial APIs used by many libraries
# --strip-debug: removes debug symbols from the JRE, reducing its size.
# --no-man-pages: excludes man page documentation files.
# --no-header-files: excludes C header files used for native development.
# --compress=zip-6: compresses the JRE resources using ZIP level 6 compression.
# --output /jre-custom: writes the resulting custom JRE to /jre-custom inside this stage.
RUN jlink \
    --add-modules java.base,java.logging,java.instrument,java.naming,java.xml,jdk.compiler,jdk.unsupported \
    --strip-debug \
    --no-man-pages \
    --no-header-files \
    --compress=zip-6 \
    --output /jre-custom

# ===== RUNTIME STAGE =====
# Defines the final stage — the actual image that will be deployed.
# Starts from bare Alpine 3.23 (~5MB) with no Java installed.
# Only artifacts explicitly copied from previous stages are included.
FROM alpine:3.23

# Redeclares APP_HOME — environment variables do not carry over between stages.
ENV APP_HOME=/usr/app

# Sets /usr/app as the working directory for the runtime container.
WORKDIR $APP_HOME

# Copies the custom JRE produced by jlink into /opt/jre.
# This is the only Java runtime in the final image — no full JDK, no unused modules.
COPY --from=jre-build /jre-custom /opt/jre

# Copies the fat JAR produced by the build stage into the working directory.
# The wildcard *.jar matches the shadowJar output file regardless of its exact name.
COPY --from=build /usr/app/build/libs/*.jar app.jar

# Adds /opt/jre/bin to the PATH so the java command is available without its full path.
ENV PATH="/opt/jre/bin:$PATH"

# Creates a system group and a system user with no password, no home directory,
# and no login shell — the container will run as this unprivileged user.
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# Switches to appuser for all subsequent instructions including ENTRYPOINT.
# The application runs without root privileges, limiting the impact of any security breach.
USER appuser

# Documents that the application listens on port $EXPOSED_PORT
# Does not open the port by itself — requires -p flag at docker run time.
ARG EXPOSED_PORT=43000
EXPOSE $EXPOSED_PORT


# Defines the fixed startup command for the container.
# Exec form (JSON array) passes arguments directly to the OS without a shell,
# making java the PID 1 process so it correctly receives signals like SIGTERM.
ENTRYPOINT ["java", "-jar", "app.jar"]