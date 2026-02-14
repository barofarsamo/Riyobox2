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
    val project = this

    val configureProject = {
        // Enforce JVM target for Java
        project.tasks.withType<JavaCompile>().configureEach {
            sourceCompatibility = "11"
            targetCompatibility = "11"
        }

        // Enforce JVM target for Kotlin
        project.tasks.configureEach {
            if (this.javaClass.name.contains("KotlinCompile")) {
                try {
                    val getKotlinOptions = this.javaClass.getMethod("getKotlinOptions")
                    val kotlinOptions = getKotlinOptions.invoke(this)
                    val setJvmTarget = kotlinOptions.javaClass.getMethod("setJvmTarget", String::class.java)
                    setJvmTarget.invoke(kotlinOptions, "11")
                } catch (e: Exception) {
                }
            }
        }

        if (project.hasProperty("android")) {
            val android = project.extensions.getByName("android")

            // Fix compileOptions JVM target
            try {
                val getCompileOptions = android.javaClass.getMethod("getCompileOptions")
                val compileOptions = getCompileOptions.invoke(android)
                val setSourceCompatibility = compileOptions.javaClass.getMethod("setSourceCompatibility", JavaVersion::class.java)
                val setTargetCompatibility = compileOptions.javaClass.getMethod("setTargetCompatibility", JavaVersion::class.java)
                setSourceCompatibility.invoke(compileOptions, JavaVersion.VERSION_11)
                setTargetCompatibility.invoke(compileOptions, JavaVersion.VERSION_11)
            } catch (e: Exception) {}
        }
    }

    if (project.state.executed) {
        configureProject()
    } else {
        project.afterEvaluate {
            configureProject()
        }
    }

    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)

    if (project.name != "app") {
        try {
            project.evaluationDependsOn(":app")
        } catch (e: Exception) {
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
