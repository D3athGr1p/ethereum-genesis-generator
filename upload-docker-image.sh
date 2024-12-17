#!/bin/bash

check_docker_login() {
    # Check if we are logged into Docker
    if ! docker info | grep -q "Username:"; then
        echo "You are not logged in to Docker Hub."
        echo "Please log in with your Docker Hub credentials."

        # Ask for Docker Hub username and password
        echo -n "Username: "
        read username
        echo -n "Password: "
        read -s password
        echo

        # Log in using the provided credentials
        echo "Logging in to Docker Hub..."
        echo "$password" | docker login -u "$username" --password-stdin

        # Check if login was successful
        if [ $? -eq 0 ]; then
            echo "Logged in successfully!"
        else
            echo "Login failed. Please check your credentials."
            exit 1
        fi
    else
        echo "You are already logged in to Docker Hub."
    fi
}

check_docker_login

echo "give docker username"
read DOCKER_USERNAME

# Prompt user for the image name
echo "Give image name:"
read IMAGE_NAME

# Prompt user for the tag
echo "Give tag:"
read tag


DOCKER_USERNAME="${DOCKER_USERNAME:-raininfotech14}"

# Check if both name and tag are provided
if [[ -z "$IMAGE_NAME" || -z "$tag" ]]; then
  echo "Both image name and tag are required."
  exit 1
fi

DOCKER_REPO="${DOCKER_USERNAME}/${IMAGE_NAME}"

# Build Docker image with the specified tag
echo "Building Docker image: ${DOCKER_REPO}:${tag}..."
docker build -t "$DOCKER_REPO:$tag" .

# Build Docker image with the 'latest' tag (optional)
echo "Building Docker image: ${DOCKER_REPO}:latest..."
docker build -t "$DOCKER_REPO:latest" .


# Push Docker image to Docker Hub
echo "Pushing Docker image to Docker Hub: ${DOCKER_REPO}:${tag}..."
docker push "$DOCKER_REPO:$tag"

# Push Docker image with the 'latest' tag (optional)
echo "Pushing Docker image to Docker Hub: ${DOCKER_REPO}:latest..."
docker push "$DOCKER_REPO:latest"

# Success message
echo "Docker image successfully pushed to Docker Hub: ${DOCKER_REPO}:${tag}"
echo "Docker image successfully pushed to Docker Hub: ${DOCKER_REPO}:latest"
