plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

val releaseBuildRequested = gradle.startParameter.taskNames.any {
    it.contains("release", ignoreCase = true)
}
val releaseKeyPropertiesFile = rootProject.file("key.properties")
val releaseKeyProperties = if (releaseBuildRequested) {
    if (!releaseKeyPropertiesFile.exists()) {
        throw GradleException(
            "Release signing is required. Create android/key.properties before building a release.",
        )
    }
    releaseKeyPropertiesFile.readLines(Charsets.UTF_8)
        .filter { it.isNotBlank() && !it.startsWith("#") && !it.startsWith("!") }
        .associate { line ->
            val separator = line.indexOf('=')
            if (separator <= 0) {
                throw GradleException("Invalid release signing property format.")
            }
            line.substring(0, separator).trim() to line.substring(separator + 1)
        }
} else {
    emptyMap()
}

fun releaseSigningProperty(name: String): String =
    releaseKeyProperties[name]
        ?: throw GradleException("Missing release signing property: $name")

android {
    namespace = "com.usisks.mothersword"
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }
    kotlinOptions { jvmTarget = JavaVersion.VERSION_17.toString() }

    defaultConfig {
        applicationId = "com.usisks.mothersword"
        minSdk = 24
        targetSdk = 36
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (releaseBuildRequested) {
            create("release") {
                keyAlias = releaseSigningProperty("keyAlias")
                keyPassword = releaseSigningProperty("keyPassword")
                val configuredStoreFile = file(releaseSigningProperty("storeFile"))
                if (!configuredStoreFile.isFile) {
                    throw GradleException("The configured release keystore does not exist.")
                }
                storeFile = configuredStoreFile
                storePassword = releaseSigningProperty("storePassword")
            }
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.findByName("release")
            if (releaseBuildRequested && signingConfig == null) {
                throw GradleException("Release signing configuration is unavailable.")
            }
        }
    }
}

flutter { source = "../.." }

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
