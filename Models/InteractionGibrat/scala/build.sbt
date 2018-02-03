name := "interaction"

version := "1.0"

//scalaVersion := "2.11.6"
scalaVersion := "2.12.4"

enablePlugins(SbtOsgi)

osgiSettings

OsgiKeys.exportPackage := Seq("interaction.*")

OsgiKeys.importPackage := Seq("*;resolution:=optional")

OsgiKeys.privatePackage := Seq("!scala.*,*")

OsgiKeys.requireCapability := """osgi.ee;filter:="(&(osgi.ee=JavaSE)(version=1.8))""""

//scalariformSettings

//resolvers += "ISC-PIF Release" at "http://maven.iscpif.fr/public/"

//val openMOLEVersion = "5.0-SNAPSHOT"

//libraryDependencies += "org.openmole" %% "org-openmole-core-dsl" % openMOLEVersion

//libraryDependencies += "org.openmole" %% "org-openmole-plugin-task-scala" % openMOLEVersion

//libraryDependencies += "org.apache.commons" % "commons-math3" % "3.5"

libraryDependencies += "gov.nist.math" % "jama" % "1.0.3"

//libraryDependencies += "org.scalaforge" % "scalax" % "0.1"

//libraryDependencies += "org.jaitools" % "jt-all" % "1.2.0"
