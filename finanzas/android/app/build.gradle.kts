plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.finanzas"
    compileSdk = 36  // Actualizado a 36
    ndkVersion = flutter.ndkVersion
    
    compileOptions {
        // Habilitar desugaring
        isCoreLibraryDesugaringEnabled = true
        
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }
    
    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }
    
    defaultConfig {
        applicationId = "com.example.finanzas"
        minSdk = flutter.minSdkVersion
        targetSdk = 36  // Actualizado a 36
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        
        // Habilitar multidex por si acaso
        multiDexEnabled = true
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

dependencies {
    // Actualizar a versión 2.1.4 de desugaring
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
