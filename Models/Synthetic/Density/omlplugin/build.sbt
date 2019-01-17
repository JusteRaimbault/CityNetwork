scalaVersion := "2.12.6"

name := "density"

version := "1.0"

enablePlugins(SbtOsgi)

OsgiKeys.exportPackage := Seq("density.*")

OsgiKeys.importPackage := Seq("*;resolution:=optional")

OsgiKeys.privatePackage := Seq("!scala.*,*")

OsgiKeys.requireCapability := """osgi.ee;filter:="(&(osgi.ee=JavaSE)(version=1.8))""""

resolvers += Resolver.sonatypeRepo("snapshots")
resolvers += Resolver.sonatypeRepo("staging")
resolvers += Resolver.mavenCentral

libraryDependencies += "org.apache.commons" % "commons-math3" % "3.5"
libraryDependencies += "org.scalaforge" % "scalax" % "0.1"
libraryDependencies += "org.jaitools" % "jt-all" % "1.2.0"
