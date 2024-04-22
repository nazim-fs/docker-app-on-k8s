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

# Build Docker image for a specific version
build_image() {
    local version="$1"
    local dockerfile="Dockerfiles/Dockerfile.$version"
    local image_name="test/testapp:$version"

    echo "Building image for Version $version..."
    docker build -t "$image_name" -f "$dockerfile" . || {
        echo "Error building image for Version $version."
        exit 1
    }
    echo "Image for Version $version successfully built."
}

# Main script
if [ $# -ne 1 ]; then
    echo "Usage: $0 <version|all>"
    exit 1
fi

version_arg="$1"

if [ "$version_arg" = "all" ]; then
    for version in v1 v2 v3; do
        check_version_files "$version"
        build_image "$version"
    done
elif [ "$version_arg" = "v1" ] || [ "$version_arg" = "v2" ] || [ "$version_arg" = "v3" ]; then
    check_version_files "$version_arg"
    build_image "$version_arg"
else
    echo "Invalid argument. Specify 'all' or a specific version (v1, v2, v3)."
    exit 1
fi

