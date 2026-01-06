plugins {
    id("com.android.application")
    id("kotlin-android")

    // 🔹 Plugin Firebase (harus sebelum flutter plugin)
    id("com.google.gms.google-services")

    // 🔹 Flutter Gradle plugin (harus paling akhir)
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.aeroponikapp"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = "11"
    }

    defaultConfig {
        applicationId = "com.example.aeroponikapp"
        minSdk = flutter.minSdkVersion // ⬅️ pastikan minimal 21 atau lebih tinggi untuk Firebase
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

// 🔹 Wajib di akhir file!
apply(plugin = "com.google.gms.google-services")
