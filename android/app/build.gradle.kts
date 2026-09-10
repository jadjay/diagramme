plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "local.jerome.diagramme"
    // Le compileSdk effectif de CE module est forcé à 36 par le
    // sous-projet racine (voir android/build.gradle.kts, nécessaire
    // aussi pour les modules de plugins comme file_picker) : la valeur
    // ici ne sert que de repli si ce hook ne s'appliquait pas.
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    // Requis par AGP pour pouvoir utiliser resValue(...) dans les
    // productFlavors ci-dessous (app_name par flavor).
    buildFeatures {
        resValues = true
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "local.jerome.diagramme"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        // Uses the version code from pubspec.yaml. When using split APKs, 1000 * ABI_VERSION
        // is added automatically by Flutter. (https://developer.android.com/studio/build/configure-apk-splits#configure-APK-versions)
        // You can force using the value of versionCode by specifying the `-P force-version-code-ignoring-abi=true`
        // flag during build.
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // Deux flavors avec des applicationId différents, pour pouvoir installer
    // en parallèle sur le même appareil :
    // - prod : la release publiée (applicationId inchangé)
    // - dev  : artefact de test généré à la demande sur une PR
    //          (voir .github/workflows/build-dev.yml)
    flavorDimensions += "distribution"
    productFlavors {
        create("prod") {
            dimension = "distribution"
            resValue("string", "app_name", "diagramme")
        }
        create("dev") {
            dimension = "distribution"
            applicationIdSuffix = ".dev"
            versionNameSuffix = "-dev"
            resValue("string", "app_name", "diagramme-dev")
        }
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
