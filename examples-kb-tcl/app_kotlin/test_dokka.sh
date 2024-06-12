
group="org.jetbrains.dokka"
coursier="./.kb/toolchain/coursier/cs-x86_64-pc-linux"

CP="$($coursier fetch -p $group:dokka-base:1.9.20);$($coursier fetch -p $group:analysis-kotlin-descriptors:1.9.20);$($coursier fetch -p org.jetbrains.kotlinx:kotlinx-html-jvm:0.8.0);$($coursier fetch -p org.freemarker:freemarker:2.3.31)"
CP=$(sed 's/:/;/g' <<< "$CP")
echo "CP: $CP"

CLI="$($coursier fetch --classpath $group:dokka-cli:1.9.20)"

echo "CLI: $CLI"

echo "Run"
outdir=".kb/build/dokka"
mkdir -p $outdir
java -jar $CLI -pluginsClasspath $CP -sourceSet "-src .kb/build/javadoc" -outputDir $outdir