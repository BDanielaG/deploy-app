#!/bin/bash
set -xe 

SONAR_HOST=http://sonarqube:9000
SONAR_PROJECT_KEY=petclinic
COMMIT_MSG=$(git log -1 --pretty=%B)
echo "Commit message of review: $COMMIT_MSG"


echo "Running Maven tests..."
# mvn clean verify
mvn spring-javaformat:apply
mvn clean verify jacoco:report -Dspring.profiles.active=test
ls -l target/site/jacoco/

#sonarqube analysis
if [[ -n "$SONAR_TOKEN" && -n "$SONAR_HOST" && -n "$SONAR_PROJECT_KEY" ]]; then
  echo "Running SonarQube analysis..."
  mvn -X sonar:sonar\
    -Dsonar.projectKey="$SONAR_PROJECT_KEY" \
    -Dsonar.host.url="$SONAR_HOST" \
    -Dsonar.login="$SONAR_TOKEN" \
    -Dsonar.java.coverage.reportPaths=target/site/jacoco/jacoco.xml\
    -Dsonar.coverage.jacoco.xmlReportPaths=target/site/jacoco/jacoco.xml
    # -Dsonar.sources=src/main/java \
    # -Dsonar.tests=src/test/java \
    # -Dsonar.java.binaries=target/classes
else
  echo "SonarQube analysis skipped. Missing SONAR_* environment variables."
fi

#conditionally trigger build job
skip_deploy_keyword="*%RUN_ONLY_TESTS*"
if [[ $COMMIT_MSG == $skip_deploy_keyword ]]; then
  echo -e "\e[1;33mFound keyword to skip tests..\e[0m"
  echo "Tests results can be found here: http://localhost:9000/dashboard?id=${SONAR_PROJECT_KEY}"
else
  echo -e "\e[1;33mWill continue with build and deploy...\e[0m"
  curl -X POST  --user "admin:$JENKINS_TOKEN" http://jenkins:8080/job/petclinic-build/buildWithParameters?GIT_COMMIT_HASH=${GIT_COMMIT}\
  && echo " Successfully triggered build job" \
  || { echo -e "\e[1;31m Something went wrong, failed to trigger job...\e[0m"; exit 1; }
fi


