#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print step information
print_step() {
    echo -e "${GREEN}📍 $1${NC}"
}

# Function to check command status
check_status() {
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ Success: $1${NC}"
    else
        echo -e "${RED}❌ Failed: $1${NC}"
        exit 1
    fi
}

# Function to check pod readiness
check_pod_readiness() {
    local namespace=$1
    local pod_name=$2
    local max_attempts=30
    local attempt=1

    print_step "Checking readiness for $pod_name..."
    while [ $attempt -le $max_attempts ]; do
        status=$(kubectl get pod -n $namespace -l app=$pod_name -o jsonpath='{.items[*].status.phase}')
        if [ "$status" == "Running" ]; then
            echo -e "${GREEN}✅ Pod $pod_name is ready${NC}"
            return 0
        fi
        echo "Waiting for pod $pod_name (attempt $attempt/$max_attempts)..."
        sleep 5
        ((attempt++))
    done
    echo -e "${RED}❌ Pod $pod_name failed to become ready${NC}"
    return 1
}

# Start Minikube
print_step "Checking if Minikube is running..."
minikube status > /dev/null 2>&1
if [ $? -ne 0 ]; then
    print_step "Starting Minikube with Docker driver..."
    minikube start --driver=docker
    check_status "Minikube startup"
else
    echo -e "${GREEN}✅ Minikube is already running${NC}"
fi

# Create Kubernetes resources
print_step "Creating Kubernetes namespace..."
kubectl apply -f kubernetes/namespace.yaml
check_status "Namespace creation"

print_step "Creating or updating secrets config from .env file..."
kubectl create secret generic secrets-config --from-env-file=backstage-app/.env -n backstage --dry-run=client -o yaml | kubectl apply -f -
check_status "Secrets config creation or update"

print_step "Creating data directory in Minikube..."
minikube ssh -- sudo mkdir -p /mnt/data
check_status "Data directory creation"

print_step "Setting up Postgres storage..."
kubectl apply -f kubernetes/postgres-storage.yaml
check_status "Storage configuration"

print_step "Deploying Postgres..."
kubectl apply -f kubernetes/postgres.yaml
check_status "Postgres deployment"

# Health check for Postgres
check_pod_readiness "backstage" "postgres"
check_status "Postgres health check"

print_step "Creating Postgres service..."
kubectl apply -f kubernetes/postgres-service.yaml
check_status "Postgres service"

# Build and deploy Backstage
print_step "Setting up Docker environment..."
eval $(minikube docker-env)
check_status "Docker environment setup"

print_step "Building Backstage image..."
docker build -t backstage:latest ./backstage-app
check_status "Backstage image build"

print_step "Deploying Backstage..."
kubectl apply -f kubernetes/backstage.yaml
check_status "Backstage deployment"

# Health check for Backstage
check_pod_readiness "backstage" "backstage"
check_status "Backstage health check"

print_step "Creating Backstage service..."
kubectl apply -f kubernetes/backstage-service.yaml
check_status "Backstage service"

# Security and status checks
print_step "Running security and status checks..."
echo -e "\n${GREEN}Pod Security Contexts:${NC}"
kubectl get pods -n backstage -o custom-columns="NAME:.metadata.name,SECURITY_CONTEXT:.spec.securityContext"

echo -e "\n${GREEN}Service Exposure:${NC}"
kubectl get svc -n backstage -o custom-columns="NAME:.metadata.name,TYPE:.spec.type,EXTERNAL-IP:.status.loadBalancer.ingress[*].ip"

echo -e "\n${GREEN}Pod Resource Usage:${NC}"
kubectl describe pods -n backstage | grep -A 3 "Resources:"

# Show deployment status
print_step "Deployment completed successfully! 🚀"
echo -e "\n${GREEN}Current deployments:${NC}"
kubectl get pods -n backstage

# Get the testing URL
print_step "Getting the testing URL for Backstage..."
minikube service backstage -n backstage --url
