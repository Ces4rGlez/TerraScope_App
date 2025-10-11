allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Cambiar directorio de build de manera segura
val newBuildDir = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.buildDir = newBuildDir.asFile

subprojects {
    // Cambiar buildDir de cada subproyecto
    project.buildDir = File(newBuildDir.asFile, project.name)

    // Evaluar app antes que los subproyectos
    project.evaluationDependsOn(":app")
}

// Tarea clean
tasks.register<Delete>("clean") {
    delete(rootProject.buildDir)
}
