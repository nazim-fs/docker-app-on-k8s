# Build & Deploy simple web app on kubernetes:

Repository to deploy simple web application on kubernetes built using docker


## Introduction:

This repository contains necessary code and serves as a guide which provides step-by-step instructions to deploy a sample web application using Docker and Kubernetes. The application has three different versions (v1, v2, v3) that demonstrate version control, deployment, and rollback capabilities.


## Pre-requisites:

Ensure you have the following tools installed on your machine before proceeding:

- Git and Git CLI for repository cloning
- Docker for building and managing containers
- kubectl for interacting with Kubernetes clusters
- Minikube as a local Kubernetes cluster


## Build a Docker Image:

Clone the repository to your local machine:
```
git clone https://github.com/nazim-fs/docker-app-on-k8s.git
cd docker-app-on-k8s/
```

Refer to the `app/` folder to access different application versions and the `Dockerfiles/` folder containing Dockerfiles for each version.

Use the `docker_image_build.sh` script to build Docker images for different versions:
```
./docker_image_build.sh v1  # Build image for v1
./docker_image_build.sh all  # Build images for all versions (v1, v2, v3)
```


## Deploy the Application on Kubernetes Cluster (Minikube) & perform rollout/rollback:

Step 1: Install Minikube and kubectl:
Install Minikube using the following commands based on your operating system:
macOS:
```
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-darwin-amd64
sudo install minikube-darwin-amd64 /usr/local/bin/minikube
```
Linux:
```
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube
```

Step 2: Create a Minikube Cluster:
Start Minikube to create a local Kubernetes cluster:
```
minikube start
```

Step 3: Deploy the Sample Application (Version v1):
Create a deployment using the provided YAML file:
```
kubectl apply -f kubefiles/deploy_app.yaml
```
Check the deployment and pod status:
```
kubectl -n testapp get deployments
kubectl -n testapp get pods
```

Step 4: Rollout and Verify Application Upgrade (Version v2):
Update the image in the deployment to a newer version (e.g., "v2"):
```
kubectl -n testapp set image deployment testapp-deployment testapp=test/testapp:v2
```
Check rollout status and verify image version inside the pod:
```
kubectl -n testapp rollout status deployment testapp-deployment
kubectl -n testapp describe deploy testapp-deployment
kubectl -n testapp get pods
```

Step 5: Rollback to Previous Version (Version v1):
Rollback to the previous version (e.g., "v1") using rollout undo command:
```
kubectl -n testapp rollout undo deployment testapp-deployment
```
Check rollout status after rollback and verify image version inside the pod:
```
kubectl -n testapp rollout status deployment testapp-deployment
kubectl -n testapp describe deploy testapp-deployment
kubectl -n testapp get pods
```


## CI/CD Setup

Use the `build_and_deploy.sh` script to build an image with a specific version and deploy it on the Minikube cluster:
```
./build_and_deploy.sh v1  # Build and deploy image for v1
```


## Cleanup

To clean up resources created during deployment and testing, run the following commands:
Delete Minikube cluster:
```
minikube delete
```
Clean up Docker images:
```
sudo docker rmi test/testapp:v1
sudo docker rmi test/testapp:v2
sudo docker rmi test/testapp:v3
```

