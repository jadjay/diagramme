allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

// Force les modules Android des PLUGINS (chacun résolu comme un
// sous-projet Gradle distinct avec sa propre configuration) à compiler
// contre la même version d'API que l'app (voir compileSdk dans
// android/app/build.gradle.kts).
//
// Le défaut fourni par Flutter (flutter.compileSdkVersion, actuellement
// 34) ne suit pas forcément les dépendances transitives d'un plugin :
// file_picker exige ici compileSdk >= 36 via flutter_plugin_android_
// lifecycle ("checkReleaseAarMetadata" sinon). Changer uniquement
// android/app/build.gradle.kts NE SUFFIT PAS, car le module du plugin
// lui-même garde son propre compileSdk par défaut.
//
// ":app" est exclu ici : evaluationDependsOn(":app") ci-dessus force ce
// module à être évalué en premier, avant même que cette boucle
// n'atteigne son tour — y appeler afterEvaluate() échouerait
// ("project is already evaluated"). Il garde donc son compileSdk = 36
// propre, déclaré directement dans son build.gradle.kts.
//
// Ceci ne change que la version des API compilées contre : targetSdk et
// minSdk restent inchangés (définis dans android/app/build.gradle.kts),
// donc pas d'impact sur le comportement runtime ni sur les appareils
// compatibles.
subprojects {
    if (project.name == "app") {
        return@subprojects
    }

    afterEvaluate {
        extensions.findByType(com.android.build.gradle.BaseExtension::class.java)
            ?.compileSdkVersion(36)
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
