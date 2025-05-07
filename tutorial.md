# Building a Simple CI/CD Pipeline with GitHub Actions and AWS EC2

This tutorial walks you through setting up a basic Continuous Integration and Continuous Deployment (CI/CD) pipeline using GitHub Actions to automatically deploy a Node.js application to an AWS EC2 instance via SSH.

Automating your deployment process saves time, reduces manual errors, and allows you to deliver updates faster and more reliably.

## What You'll Achieve

By the end of this tutorial, you will have a pipeline that:

- Triggers automatically when you push code to the main branch of your GitHub repository
- Checks out your code
- Connects securely to your AWS EC2 instance via SSH
- Pulls the latest code onto the EC2 instance
- Installs/updates Node.js dependencies
- Runs automated tests
- Restarts the Node.js application using PM2

## Prerequisites

Before you start, make sure you have:

- A GitHub account
- An AWS account
- An active AWS EC2 instance (Ubuntu or similar Linux distribution recommended) where you have SSH access
- Basic knowledge of Node.js, Git, and the command line
- Node.js and PM2 installed on your EC2 instance. If not, the deployment script will attempt to install them, but it's good to be familiar with the process
- An SSH key pair. You'll need the private key for GitHub Actions and the public key authorized on your EC2 instance (~/.ssh/authorized_keys)
- A GitHub Personal Access Token (PAT) with repo scope, needed if your repository is private, to allow the EC2 instance to pull the code

## Step 1: Set up Your Node.js Application

You'll need a simple Node.js application hosted in a GitHub repository. For this tutorial, we'll use a basic Express app with a test.

Ensure your project includes:

- `server.js`: Your main application file
- `package.json`: Defines your project dependencies and includes test and start scripts
- `server.test.js`: Your test file using Jest and Supertest

Make sure your package.json has scripts similar to this:

```json
{
  "name": "your-app-name",
  "version": "1.0.0",
  "main": "server.js",
  "scripts": {
    "test": "jest",
    "start": "node server.js"
  },
  "dependencies": {
    "express": "^5.1.0"
    // other dependencies
  },
  "devDependencies": {
    "jest": "^29.0.0",
    "supertest": "^6.3.0"
    // other dev dependencies
  }
}
```

Commit this code to the main branch of your GitHub repository.

![Sample Node.js Project Structure](images/nodejs-project-structure.png)

<!-- Add an actual screenshot of a basic Node.js project structure here -->

## Step 2: Prepare Your AWS EC2 Instance

Your EC2 instance needs to be ready to receive the application code and run it.

1. **Ensure SSH Access**: Verify you can SSH into your EC2 instance from your local machine using your SSH key.

2. **Install Node.js and npm**: If not already installed, follow the official Node.js documentation to install them. Using NVM (Node Version Manager) is recommended for easier version management.

3. **Install PM2**: PM2 is a process manager for Node.js applications that keeps them alive forever, reloads them without downtime, and simplifies common system admin tasks. Install it globally:

   ```bash
   npm install -g pm2
   ```

4. **Authorize GitHub's SSH Key**: The GitHub Actions runner will connect using an SSH key. You need to generate a new SSH key pair specifically for this deployment or use an existing one. Add the public key (id_rsa.pub content) to the ~/.ssh/authorized_keys file on your EC2 instance.

5. **Create Deployment Directory**: Decide where you want to deploy your application on the EC2 instance (e.g., /home/ubuntu/your-app). The workflow will clone the repository into this directory.

![EC2 Instance Setup](images/ec2-setup.png)

<!-- Add a screenshot showing an EC2 instance dashboard or SSH connection -->

## Step 3: Configure GitHub Repository Secrets

To allow GitHub Actions to securely connect to your EC2 instance and pull private repository code (if applicable), you need to store sensitive information as GitHub Secrets.

1. Go to your GitHub repository
2. Navigate to **Settings > Secrets and variables > Actions**
3. Click **New repository secret**
4. Add the following secrets:
   - `EC2_PRIVATE_KEY`: Paste the entire content of your SSH private key file, including the -----BEGIN... and -----END... lines
   - `EC2_HOST`: Enter the public IP address or hostname of your EC2 instance
   - `EC2_USER`: Enter the username you use to SSH into the EC2 instance (e.g., ubuntu, ec2-user)
   - `PER_TOKEN`: If your repository is private, create a GitHub Personal Access Token (PAT) with the repo scope and paste it here

![GitHub Secrets Setup](images/github-secrets.png)

<!-- Add a screenshot showing the GitHub secrets interface with these secrets -->

## Step 4: Create the GitHub Actions Workflow (deploy.yml)

Now, let's define the CI/CD workflow using a YAML file in your repository.

1. In your GitHub repository, create a directory named `.github/workflows`
2. Inside the workflows directory, create a file named `deploy.yml`
3. Paste the following content into deploy.yml:

```yaml
name: Deploy to EC2

on:
  push:
    branches: [main] # Trigger the workflow on pushes to the 'main' branch

jobs:
  deploy:
    runs-on: ubuntu-latest # Use a fresh Ubuntu runner provided by GitHub Actions

    steps:
      - name: Checkout Code
        uses: actions/checkout@v2 # Step to checkout the code from the repository

      - name: Deploy to EC2
        env:
          # Access the secrets you configured in GitHub repository settings
          PRIVATE_KEY: ${{ secrets.EC2_PRIVATE_KEY }}
          HOST: ${{ secrets.EC2_HOST }}
          USER: ${{ secrets.EC2_USER }}
          GITHUB_PAT: ${{ secrets.PER_TOKEN }} # Your Personal Access Token secret
        run: |
          # --- Securely set up SSH key ---
          # Write the private key to a file and set correct permissions
          echo "$PRIVATE_KEY" > github-ec2.pem
          chmod 600 github-ec2.pem

          # --- Connect to EC2 and execute deployment commands ---
          # Use ssh to connect and run commands.
          # StrictHostKeyChecking=no is used here for simplicity in a tutorial,
          # but for production, you should manage known_hosts properly.
          ssh -o StrictHostKeyChecking=no -i github-ec2.pem ${USER}@${HOST} '

          echo "--- Starting Deployment on EC2 ---"

          # --- Install Node.js and PM2 if not present ---
          # Check if nvm is installed, install if not
          echo "Checking/Installing Node.js (via NVM)..."
          if ! command -v nvm &> /dev/null; then
            curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.5/install.sh | bash
            # Source nvm script to make nvm command available in the current session
            export NVM_DIR="$HOME/.nvm"
            [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
            [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
          fi
          # Install the latest stable Node.js version
          nvm install node

          # Check if pm2 is installed, install if not
          echo "Checking/Installing PM2..."
          if ! command -v pm2 &> /dev/null; then
            npm install -g pm2
          fi

          # --- Clone or update the repository ---
          # Set Git to use HTTPS and include PAT for authentication (needed for private repos)
          # Replace 'YOUR_GITHUB_USERNAME/YOUR_REPOSITORY_NAME' with your GitHub username and repository name
          REPO_URL="https://${GITHUB_PAT}@github.com/YOUR_GITHUB_USERNAME/YOUR_REPOSITORY_NAME.git"
          BRANCH="main"
          REPO_DIR="$HOME/your-app-directory" # Directory on EC2 where app will live

          # Configure git to not prompt for credentials (useful when using PAT in URL)
          git config --global credential.helper store

          echo "Cloning or updating repository in $REPO_DIR..."
          if [ -d "$REPO_DIR/.git" ]; then
            # If directory exists, pull latest changes
            cd "$REPO_DIR" || { echo "Failed to change directory to $REPO_DIR"; exit 1; }
            git pull origin "$BRANCH" || echo "Failed to pull updates"
          else
            # If directory doesn't exist, clone the repository
            git clone "$REPO_URL" "$REPO_DIR" || { echo "Failed to clone repository $REPO_URL"; exit 1; }
            cd "$REPO_DIR" || { echo "Failed to change directory to $REPO_DIR"; exit 1; }
          fi

          # --- Navigate to app directory, install dependencies, run tests, and start app ---
          # Assuming your Node.js app code is directly in the cloned repo's root
          # If your app is in a subdirectory (e.g., 'simple-web-server'), adjust the path
          APP_DIR="$REPO_DIR" # Or "$REPO_DIR/simple-web-server" if in a subdirectory

          if [ -d "$APP_DIR" ]; then
            cd "$APP_DIR" || { echo "Failed to change to application directory $APP_DIR"; exit 1; }

            echo "Installing npm dependencies..."
            npm install

            echo "Running tests..."
            npm test || { echo "Tests failed. Aborting deployment."; exit 1; } # Exit if tests fail

            echo "Starting/restarting application with PM2..."
            # Use PM2 to restart the app if it's running, otherwise start it
            pm2 restart server.js || pm2 start server.js

            echo "--- Deployment Complete ---"
          else
            echo "Error: Application directory $APP_DIR not found after cloning."
            exit 1 # Exit with error if app directory is missing
          fi
          ' # End of SSH command block
```

**Important:**

- Replace `YOUR_GITHUB_USERNAME/YOUR_REPOSITORY_NAME` in REPO_URL with your actual GitHub username and repository name
- Replace `your-app-directory` in REPO_DIR with the desired path on your EC2 instance where the application code will be stored
- Adjust APP_DIR if your Node.js application code is in a subdirectory within your repository

Commit and push this deploy.yml file to the main branch of your GitHub repository.

![GitHub Actions Workflow File](images/github-actions-workflow.png)

<!-- Add a screenshot showing the GitHub Actions workflow file -->

## Step 5: Test Your Pipeline

With the workflow file in place and secrets configured, your pipeline should now be active.

1. Make a small, harmless change to your application code (e.g., update the HTML message in server.js)
2. Commit the change and push it to the main branch of your GitHub repository
3. Go to the Actions tab in your GitHub repository
4. You should see a new workflow run triggered by your push. Click on the run to see its progress
5. Click on the deploy job and then the Deploy to EC2 step to view the detailed logs. You can watch the script execute on your EC2 instance

If the workflow completes successfully, access your application running on the EC2 instance's public IP address (and port 3000, or whatever port your app uses and is allowed by security groups) in a web browser. You should see your latest change reflected.

If the workflow fails, examine the logs carefully. Common issues include incorrect secrets, SSH key problems, incorrect file paths in the script, or issues with Node.js/PM2 installation on the EC2.

![GitHub Actions Workflow Run](images/github-actions-run.png)

<!-- Add a screenshot showing a successful GitHub Actions workflow run -->

## Conclusion

Congratulations! You've successfully set up a basic CI/CD pipeline using GitHub Actions and AWS EC2. You now have an automated process that builds, tests, and deploys your Node.js application with every push to the main branch.

This is a foundational pipeline. To make it more robust for production, consider adding:

- **Separate Build Stage**: Build your application and run tests in a dedicated CI job before deployment
- **Artifact Management**: Create a build artifact (e.g., a tarball) and transfer it to the EC2 instead of cloning the repo directly during deployment
- **Containerization**: Dockerize your application for better consistency and easier management
- **Environment-Specific Deployments**: Use different workflows or environments in GitHub Actions for staging and production deployments
- **Advanced Deployment Strategies**: Implement blue/green or canary deployments for zero-downtime updates
- **Monitoring and Rollback**: Add health checks after deployment and automate rollback if issues are detected
- **Dedicated AWS Deployment Services**: Explore services like AWS CodeDeploy or Elastic Beanstalk for more integrated AWS deployment workflows

Building this pipeline is a significant step towards adopting modern DevOps practices and improving your software delivery process.

Happy automating!

![Completed CI/CD Pipeline](images/complete-pipeline.png)

<!-- Add a diagram or visualization of the complete pipeline -->
