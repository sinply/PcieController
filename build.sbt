ThisBuild / version      := "1.0.0"
ThisBuild / scalaVersion := "2.11.12"
ThisBuild / organization := "com.pcie"

val spinalVersion = "1.9.4"

lazy val root = (project in file("."))
  .settings(
    name := "pcie-controller",
    libraryDependencies ++= Seq(
      "com.github.spinalhdl" %% "spinalhdl-core" % spinalVersion,
      "com.github.spinalhdl" %% "spinalhdl-lib"  % spinalVersion,
      compilerPlugin("com.github.spinalhdl" %% "spinalhdl-idsl-plugin" % spinalVersion)
    ),
    scalacOptions += "-feature",
    fork := true
  )
