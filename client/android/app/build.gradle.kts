import java.util.Properties
import java.io.FileInputStream
import java.util.Base64

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "dev.filipov.social_auth_example"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "dev.filipov.social_auth_example"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        // Читаем код из переменных окружения
        val dartDefinitions = project.properties["dart-defines"]
            ?.toString()
            ?.split(",")
            ?.associate { entry ->
                val decodedBytes = Base64.getDecoder().decode(entry)
                val decodedString = String(decodedBytes, Charsets.UTF_8)
                val parts = decodedString.split("=", limit = 2)
                parts[0] to parts.getOrElse(1) { "" }
            } ?: emptyMap()

        // Установка значений через apply
        manifestPlaceholders.apply {
            put("VK_CLIENT_ID", dartDefinitions["VK_CLIENT_ID"] ?: "")
            put("YA_CLIENT_ID", dartDefinitions["YA_CLIENT_ID"] ?: "")
            put("GOOGLE_APP_ID", dartDefinitions["GOOGLE_APP_ID"] ?: "")
        }
    }

    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String
            keyPassword = keystoreProperties["keyPassword"] as String
            storeFile = keystoreProperties["storeFile"]?.let { file(it) }
            storePassword = keystoreProperties["storePassword"] as String
        }
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            // signingConfig = signingConfigs.getByName("debug")
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

flutter {
    source = "../.."
}
