#!/bin/bash

# Check if a file exists
check_file_exists() {
    local filename="$1"
    if [ ! -f "$filename" ]; then
        echo "Error: File '$filename' not found."
        exit 1
    fi
}

# Check if Dockerfile and application file exist for a specific version
check_version_files() {
    local version="$1"
    check_file_exists "Dockerfiles/Dockerfile.$version"
    check_file_exists "app/app_$version.py"
}

# Rollback function to revert changes in case of failure
rollback() {
    local version="$1"
    local namespace="testapp"

    echo "Rolling back changes for Version $version..."

    # Delete deployment if it exists
    kubectl delete deployment testapp-deployment -n "$namespace" &> /dev/null

    # Delete ConfigMap if it exists
    kubectl delete configmap testapp-config -n "$namespace" &> /dev/null

    # Delete namespace if it was created
    kubectl get namespace "$namespace" &> /dev/null
    if [ $? -eq 0 ]; then
        echo "Deleting namespace $namespace..."
        kubectl delete namespace "$namespace" || {
            echo "Error deleting namespace $namespace."
            exit 1
        }
        echo "Namespace $namespace deleted successfully."
    fi

    # Clean up Docker image if it was created
    cleanup_docker_image "$version"

    echo "Rollback completed."
    exit 1
}

# Build Docker image for a specific version
build_image() {
    local version="$1"
    local dockerfile="Dockerfiles/Dockerfile.$version"
    local image_name="test/testapp:$version"

    echo "Building image for Version $version..."
    docker build -t "$image_name" -f "$dockerfile" . || {
        echo "Error building image for Version $version."
        rollback "$version"
    }
    echo "Image for Version $version successfully built."
}

# Deploy image to Minikube cluster
deploy_to_minikube() {
    local version="$1"
    local namespace="testapp"

    # Check if the namespace exists, create it if not
    kubectl get namespace "$namespace" &> /dev/null
    if [ $? -ne 0 ]; then
        echo "Creating namespace $namespace..."
        kubectl create namespace "$namespace" || {
            echo "Error creating namespace $namespace."
            rollback "$version"
        }
        echo "Namespace $namespace created successfully."
    fi

    echo "Deploying Version $version to Minikube..."
    IMAGE_TAG="$version" envsubst '${IMAGE_TAG}' < kubefiles/testapp-deployment.yaml > kubefiles/final-deployment.yaml
    kubectl apply -f kubefiles/final-deployment.yaml -n "$namespace" || {
        echo "Error deploying Version $version to Minikube."
        rollback "$version"
    }
    echo "Version $version deployed to Minikube successfully."
}

# Clean up Docker image for a specific version
cleanup_docker_image() {
    local version="$1"
    local image_name="test/testapp:$version"

    echo "Cleaning up Docker image for Version $version..."
    docker rmi "$image_name" || {
        echo "Error cleaning up Docker image for Version $version."
        exit 1
    }
    echo "Docker image for Version $version cleaned up successfully."
}

# Main script
if [ $# -ne 1 ]; then
    echo "Usage: $0 <version>"
    exit 1
fi

version_arg="$1"

check_version_files "$version_arg"
build_image "$version_arg"
deploy_to_minikube "$version_arg"

