import org.gradle.api.publish.maven.MavenPublication

plugins {
    id("java")
    id("application")
    id("maven-publish")
    id("com.gradleup.shadow") version "9.4.1"
}

group = "org.example"
version = "1.0-SNAPSHOT"

java {
    toolchain {
        languageVersion.set(JavaLanguageVersion.of(property("jdk_version").toString().toInt()))
    }
}

application {
    mainClass.set("org.example.Main")
}

publishing {
    publications {
        create<MavenPublication>("maven") {
            from(components["java"])
        }
    }
    repositories {
        maven {
            url = uri(property("repsyUrl") as String)
            credentials {
                username = property("repsyUsername") as String
                password = property("repsyPassword") as String
            }
        }
    }
}

repositories {
    maven {
        url = uri(property("repsyUrl") as String)
        credentials {
            username = property("repsyUsername") as String
            password = property("repsyPassword") as String
        }
    }
    // Plus de mavenCentral() ici — tout passe par Repsy
}

dependencies {
    implementation("io.fusionauth:java-http:1.4.0")
    implementation("ch.qos.logback:logback-classic:1.5.32")

    testImplementation(platform("org.junit:junit-bom:5.10.0"))
    testImplementation("org.junit.jupiter:junit-jupiter")
    testRuntimeOnly("org.junit.platform:junit-platform-launcher")

    // Source: https://mvnrepository.com/artifact/org.junit.jupiter/junit-jupiter-api

    // not used dependencies so far. just here for repo logic testing/understanding
    testImplementation("org.junit.jupiter:junit-jupiter-api:6.0.3")
    // Source: https://mvnrepository.com/artifact/tools.jackson.core/jackson-databind
    implementation("tools.jackson.core:jackson-databind:3.1.2")

    // My own hello world dependencie
    implementation("org.example:hw_dependencie:1.0.0")

    // aded one to see if a wrong username in repo auth make ./gradlew publish goes wrong only after a new dependencie was added
    // Source: https://mvnrepository.com/artifact/org.projectlombok/lombok
    implementation("org.projectlombok:lombok:1.18.46")
}

tasks.test {
    useJUnitPlatform()
}