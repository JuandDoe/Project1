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

tasks.named<JavaExec>("run") {
    environment("APP_PORT", project.findProperty("appPort")?.toString() ?: "42000")
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
                username = property("repsyRepoUsername") as String
                password = property("repsyRepoPassword") as String
            }
        }
    }
}

repositories {
    maven {
        url = uri(property("repsyUrl") as String)
        credentials {
            username = property("repsyRepoUsername") as String
            password = property("repsyRepoPassword") as String
        }
    }
    mavenCentral()
}

dependencies {
    implementation("io.fusionauth:java-http:1.4.0")
    implementation("ch.qos.logback:logback-classic:1.5.32")

    testImplementation(platform("org.junit:junit-bom:5.10.0"))
    testImplementation("org.junit.jupiter:junit-jupiter")
    testRuntimeOnly("org.junit.platform:junit-platform-launcher")

    // My own hello world dependencie
    implementation("org.example:hw_dependencie:1.0.0")
}

tasks.test {
    useJUnitPlatform()
}