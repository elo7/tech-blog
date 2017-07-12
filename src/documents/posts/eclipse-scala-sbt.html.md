---
title: Configuring Eclipse scala project with SBT
date: 2013-08-13
authors: [davidrobert]
layout: post
category: back-end
description: Recently we started a new project here in Elo7 and this is a quick guide to help you to configure a new Scala project using SBT to manage your project dependencies and Eclipse as your IDE...
tags:
  - bootstrapping
  - eclipse
  - sbt
  - scala
  - simple-build-tool
---

Recently we started a new project here in Elo7 and this is a quick guide to help you to configure a new Scala project using SBT to manage your project dependencies and Eclipse as your IDE.

### So... what is SBT?

> "sbt is a build tool for Scala and Java projects that aims to do the basics well&" from scala-sbt.org

It manages your dependencies (using Apache Ivy) and supports mixed projects with Scala and Java.

### Installing SBT

If you have homebrew in your mac

``` bash
$ brew install sbt
```

If you are using another platforms [refer to this site](http://www.scala-sbt.org/release/docs/Getting-Started/Setup.html#installing-sbt)

### Create a simple project

Create a new folder for your project

``` bash
$ mkdir hello_scala
```

go to your new project folder and create a build.sbt file

``` bash
$ cd hello_scala
$ vim build.sbt
```

This file describe your project and your dependencies, write the following to your file

``` scala
name := "hello_scala"
version := "1.0"
scalaVersion := "2.10.2"

libraryDependencies ++= Seq(
  "org.specs2" %% "specs2" % "2.1.1" % "test",
  "junit" % "junit" % "4.11" % "test"
)

resolvers ++= Seq(
  "snapshots" at "http://oss.sonatype.org/content/repositories/snapshots",
  "releases" at "http://oss.sonatype.org/content/repositories/releases"
)
```

Here we are adding two dependencies to write unit tests, [junit](http://junit.org/ "JUnit") and [specs2](http://etorreborre.github.io/specs2/ "Specs2"), and two extra resolvers for your dependencies. This is needed since SBT by default only have the Maven default repository in its list.

After this you will need to add a [SBT Eclipse plugin](https://github.com/typesafehub/sbteclipse).

``` bash
$ mkdir project
$ echo "addSbtPlugin("com.typesafe.sbteclipse" % "sbteclipse-plugin" % "2.2.0")" >> plugins.sbt
```

go to your project root directory and

``` bash
$ sbt eclipse
```

This will download all your dependencies, create your eclipse project files and add your dependencies to project library.

### In your eclipse!

Import your project and you are ready to go!

![Alt "Your new scala project"](../images/eclipse-scala-sbt-1.png)

The project generated with sbt adds several source files directories, separating java source files from scala source files and tests from main code.

Saying Hello to the World!

``` scala
object Hi {
  def main(args: Array[String]) = println("Hello World!")
}
```

go to your console and in your project root directory type:

``` bash
$ sbt run
```

![Alt "Hello!"](../images/eclipse-scala-sbt-2.png)

Thank you

[Diego Kurisaki](https://github.com/diegoy) and [David Robert](https://github.com/davidrobert)
