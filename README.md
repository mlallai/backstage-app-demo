# 🎬 Backstage Demo

Welcome to the Backstage Demo project! This project showcases a local setup and an automated deployment process for a Backstage instance.

### 📥 Clone the Project

Start by cloning the project repository:

```sh
git clone git@github.com:mlallai/backstage-app-demo.git
```

### 🚀 Step 1: Local Setup and Working Locally

Follow these steps to set up and run the Backstage instance locally:

#### 📋 Prerequisites

- 🐳 Docker installed
- 🐳 Docker Compose installed

#### 🛠️ Instructions

1. 📄 Copy the example environment file:

   ```sh
   cp backstage-app/.env.example backstage-app/.env
   ```

   If not using Docker, use:

   ```sh
   cp backstage-app/.env.yarn.example backstage-app/.env.yarn
   ```

2. 🔑 Create a GitHub OAuth App. Follow [this link](https://github.com/settings/applications/new) to create the app. Retrieve the `GITHUB_CLIENT_ID`, `GITHUB_CLIENT_SECRET`, and `GITHUB_USERNAME` (your username) from GitHub and paste the values into the `backstage-app/.env` and `backstage-app/.env.yarn` files.
   _Note: OAuth App Homepage URL should be `http://localhost:7000` and Authorization callback URL should be `http://localhost:7007/api/auth/github/handler/frame`_

3. 🔑 Generate a GitHub token. Follow [this link](https://github.com/settings/tokens/new) to create a new token. Retrieve the `GITHUB_TOKEN` and paste its value into the `backstage-app/.env` and `backstage-app/.env.yarn` files.

4. 📂 Navigate to the `backstage-app` directory and run the docker-compose file:
   ```sh
   cd backstage-app
   docker compose up --build -d
   ```
5. 🌐 Open your browser and go to [http://localhost:7007](http://localhost:7007).

#### 📋 Technical Implementation Notes

- Use Docker and docker-compose to spin up everything with one command, ensuring consistency across environments.

#### 💡 Potential Improvements

- Opt for a cross-platform / cross-environment declarative tool like Score to define one workload that can used everywhere (docker-compose, kubernetes) and remains stack-agnostic.

### 🌐 Step 2: Checkout the Automated Deployment Process

The application is available here: [Backstage Service](http://backstage-service-3-lb-618052225.eu-west-3.elb.amazonaws.com/)
The automated process in built into a GitHub Action and available on `.github/workflows/build_and_deploy.yml`

#### 📋 Technical Implementation Notes

- A CI/CD process checks out code, tests, builds the Docker image, pushes it to a repository, and deploys it.
- The process is automated and triggered by merges into the main branch.
- The Docker image is pushed to AWS Elastic Container Registry.
- A cluster on AWS Elastic Container Service builds a container with our Docker image and exposes the correct port. AWS ECS is used for its simplicity compared to Kubernetes.
- Each build triggers a deployment on the ECS cluster.
- A load balancer redirects requests to the container.
- The application connects to a managed PostgreSQL database on AWS RDS, which is not publicly accessible but resides in the same VPC as the cluster.
- Fargate is used for serverless management, providing a quick deployment method.
- AWS ECS is chosen for its simplicity in deploying a backend connected to a database, with the potential to add more containers and services as the application grows.

#### 💡 Potential Improvements

- Use Route 53 for DNS.
- Switch from Fargate to AWS EC2 for better cost control if the application scales.
- Optimize steps to reduce duplication between Docker image steps and GitHub Action steps, improving deployment time.
- Implement e2e and/or integration tests, and test coverage (Sonarqube).
- Use Terraform to define the entire architecture.
- Set up replicas for RDS.
- Create separate dev/staging/prod environments.
- Use AWS Secrets Manager.
- Add observability tools.

### 🌐 Step 3: Local Kubernetes Deployment

For technical exercise purposes, we also built the configuration for a full deployment on a Kubernetes cluster. This can be locally deployed on Minikube with a single command that sets up the cluster using the files in the Kubernetes subfolder.

#### 📋 Prerequisites

- 🐳 Minikube installed ([installation guide](https://minikube.sigs.k8s.io/docs/start/))
- 📦 kubectl installed ([installation guide](https://kubernetes.io/docs/tasks/tools/install-kubectl/))
- ⎈ Helm installed ([installation guide](https://helm.sh/docs/intro/install/))

#### 🛠️ Instructions

1. 📜 Run the deployment script:

   ```sh
      sh deploy.sh
   ```

   _Note: If there are issues starting Minikube, run `minikube delete` and then run the script again._

2. 🌐 Open your browser and go to the testing URL for Backstage app provided by the Kubernetes service at the end of the script deployment

3. Optionally, to access Grafana, open a new tab, use port-forward with `kubectl port-forward svc/monitoring-grafana 3000:80 -n backstage`, open your browser and go to [http://localhost:3000](http://localhost:3000) to access the Grafana dashboard (default username: `admin` / default password: `prom-operator`)

#### 📋 Technical Implementation Notes

- kubectl is used to deploy the config files over Helm, bypassing an abstraction layer for simplicity.
- Minikube service and port-forward are used to expose ports (Backstage app & Grafana).

#### 💡 Potential Improvements

- Configure Grafana dashboards.
- Use Helm charts more extensively.
- Implement Argo CD to define all infrastructure and switch to a declarative mode.
- Add a load balancer or ingress file to handle external traffic.
- Implement health checks.
