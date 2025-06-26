#!/bin/bash

set -xe

echo "-----------------------------------------------------"
echo "--- Running Maven Package for PetClinic ---"
echo "--- Building commit: ${GIT_COMMIT_HASH} ---"
echo "-----------------------------------------------------"
mvn spring-javaformat:apply
mvn clean package -DskipTests

echo "-----------------------------------------------------"
echo "--- Maven package completed successfully. ---"
echo "-----------------------------------------------------"

echo "search for jar file"
FOUND_JARS=$(find target -maxdepth 1 -name "*.jar" ! -name "*-sources.jar" ! -name "*-javadoc.jar" -print -quit)
if [ -n "$FOUND_JARS" ]; then
    SOURCE_JAR_PATH="$FOUND_JARS"
    echo "Found JAR: $SOURCE_JAR_PATH"
else
    echo "ERROR: No JAR file found in target/ directory after build."
    ls -R target/
    exit 1
fi


echo "Upload file to nexus"
repsonse_status=$(curl -v -u $NEXUS_USER:$NEXUS_PASSWORD\
  --upload-file "${SOURCE_JAR_PATH}" \
  http://nexus:8081/repository/petclinic-project/petclinic-${GIT_COMMIT_HASH}.jar)

if [ $? -ne 0 ]; then
  echo "ERROR: curl upload failed."
  exit 1
fi

#check if file was uploaded
repsonse_status=$(curl -s -v -u $NEXUS_USER:$NEXUS_PASSWORD -o /dev/null -w "%{http_code}" \
  http://nexus:8081/repository/petclinic-project/petclinic-${GIT_COMMIT_HASH}.jar)

case $repsonse_status in
    200) echo "Upload succesfully to nexus"
        ;;
    404) echo "Upload didn't happen...retrying.."
            exit 1
        ;;
esac