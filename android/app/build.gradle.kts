import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Load keystore properties (android/key.properties)
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
    println("[Signing] Loaded key.properties from: ${keystorePropertiesFile.absolutePath}")
    val sp = if (keystoreProperties.getProperty("storePassword") != null) "***" else "<null>"
    val kp = if (keystoreProperties.getProperty("keyPassword") != null) "***" else "<null>"
    println("[Signing] storeFile='${keystoreProperties.getProperty("storeFile")}', keyAlias='${keystoreProperties.getProperty("keyAlias")}', storePassword=$sp, keyPassword=$kp")
} else {
    println("[Signing] key.properties NOT found at: ${keystorePropertiesFile.absolutePath}")
}

android {
    namespace = "com.hirayatech.mobiledev_ecowaste"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.hirayatech.mobiledev_ecowaste"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            val storePath = keystoreProperties.getProperty("storeFile")
            val sp = keystoreProperties.getProperty("storePassword")
            val ka = keystoreProperties.getProperty("keyAlias")
            val kp = keystoreProperties.getProperty("keyPassword")

            if (storePath != null && sp != null && ka != null && kp != null) {
                // Support both 'app/release-keystore.jks' and 'release-keystore.jks'
                val direct = file(storePath)
                val stripped = file(storePath.removePrefix("app/"))
                storeFile = when {
                    direct.exists() -> direct
                    stripped.exists() -> stripped
                    else -> file("release-keystore.jks")
                }
                storePassword = sp
                keyAlias = ka
                keyPassword = kp
            } else {
                logger.warn("[Signing] Missing keystore properties. Ensure android/key.properties has storeFile, storePassword, keyAlias, keyPassword.")
            }
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}

flutter {
    source = "../.."
}
