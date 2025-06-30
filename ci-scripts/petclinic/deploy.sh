#!/bin/bash
# This script deploys the built PetClinic JAR

set -xe  # Exit on error, show commands

# Set global env
TARGET_USER="daniela"
TARGET_HOST="ip"
TARGET_APP_DIR="/mnt/c/Users/Dani/Desktop/LICENTA/app"
JAR_FILE_NAME="petclinic-${GIT_COMMIT_HASH}.jar"

echo "-----------------------------------------------------"
echo "--- Starting PetClinic Application ---"
echo "-----------------------------------------------------"

# Create working dir and move into it
mkdir -p app
cd app

echo "Downloading artifact from Nexus..."
response_status=$(curl -s -u "$NEXUS_USER:$NEXUS_PASSWORD" -O -w "%{http_code}" \
  "http://nexus:8081/repository/petclinic-project/${JAR_FILE_NAME}")

case $response_status in
    200) echo "Download successful from Nexus" ;;
    404) echo "Artifact not found, exiting..." ; exit 1 ;;
    *) echo "Unexpected response: $response_status" ; exit 1 ;;
esac

ls -la

# Confirm JAR was downloaded
if [ ! -f "$JAR_FILE_NAME" ]; then
    echo "ERROR: JAR file not found!"
    exit 1
fi

echo "Starting the PetClinic application..."

# Remove and Create directory on host machine
ssh -i "$SSH_KEY_FILE" -o StrictHostKeyChecking=no "$TARGET_USER@$TARGET_HOST" \
"rm -rf '$TARGET_APP_DIR' && mkdir -p '$TARGET_APP_DIR'"


# Upload JAR to WSL
scp -i "$SSH_KEY_FILE" -o StrictHostKeyChecking=no \
    "$JAR_FILE_NAME" \
    "$TARGET_USER@$TARGET_HOST:$TARGET_APP_DIR/"

# Start app on remote WSL
REMOTE_PID=$(ssh -i "$SSH_KEY_FILE" -o StrictHostKeyChecking=no "$TARGET_USER@$TARGET_HOST" <<EOF
set -xe
cd "$TARGET_APP_DIR"

if [ -f pid.txt ]; then
    kill \$(cat pid.txt) || true
    rm -f pid.txt
fi

nohup java -jar "$JAR_FILE_NAME" > app.log 2>&1 &
echo \$! > pid.txt
cat pid.txt
EOF
)

echo "Application deployed and running in background."
echo "BUILD_DESCRIPTION=Remote PID: $REMOTE_PID" >> "$WORKSPACE/description.env"
