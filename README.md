# 🎬 Backstage Demo

### 🚀 Step 1: Local Deployment

#### 📋 Prerequisites

- 🐳 Docker installed

#### 🛠️ Instructions

1. 📄 Copy the example environment file:

   ```sh
   cp backstage-app/.env.example backstage-app/.env
   ```

   Optionally, if not using Docker:

   ```sh
   cp backstage-app/.env.yarn.example backstage-app/.env.yarn
   ```

2. 🔑 Create a GitHub OAuth App. Follow [this link](https://github.com/settings/applications/new) to create the app. Retrieve the `GITHUB_CLIENT_ID`, `GITHUB_CLIENT_SECRET`, and `GITHUB_USERNAME` from GitHub and paste the values into the `backstage-app/.env` and `backstage-app/.env.yarn` files.

3. 📂 Navigate to the `backstage-app` directory and run docker-compose file:
   ```sh
   cd backstage-app
   docker-compose up --build -d
   ```
4. 🌐 Open your browser and go to [http://localhost:7007](http://localhost:7007).

### 🌐 Step 2: Local Kubernetes Deployment

#### 📋 Prerequisites

- 🐳 Minikube installed ([installation guide](https://minikube.sigs.k8s.io/docs/start/))
- 📦 kubectl installed ([installation guide](https://kubernetes.io/docs/tasks/tools/install-kubectl/))
- ⎈ Helm installed ([installation guide](https://helm.sh/docs/intro/install/))

#### 🛠️ Instructions

1. 📜 Run the deployment script:

   ```sh
   sh deploy.sh
   ```

2. 🌐 Open your browser and go to the testing URL provided by the Kubernetes service.
