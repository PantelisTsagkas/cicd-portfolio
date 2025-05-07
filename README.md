# 🚀 CI/CD Pipeline Portfolio Project

[![GitHub Actions](https://img.shields.io/badge/GitHub_Actions-2088FF?style=for-the-badge&logo=github-actions&logoColor=white)](https://github.com/features/actions)
[![AWS](https://img.shields.io/badge/AWS-FF9900?style=for-the-badge&logo=amazonaws&logoColor=white)](https://aws.amazon.com/)
[![Node.js](https://img.shields.io/badge/Node.js-339933?style=for-the-badge&logo=nodedotjs&logoColor=white)](https://nodejs.org/)

## 📋 Overview

This repository showcases my implementation of a Continuous Integration and Continuous Deployment (CI/CD) pipeline. The project automates the deployment of a Node.js web application from GitHub to an AWS EC2 instance, demonstrating modern DevOps practices.

## 🔄 Pipeline Workflow

```mermaid
graph LR
    A[GitHub Push] --> B[GitHub Actions Trigger]
    B --> C[Run Tests]
    C --> D[Build Application]
    D --> E[Deploy to AWS EC2]
    E --> F[Live Application]
    style A fill:#4285f4,color:white
    style B fill:#34a853,color:white
    style C fill:#8e44ad,color:white
    style D fill:#673ab7,color:white
    style E fill:#ff9800,color:white
    style F fill:#ea4335,color:white
```

## 🛠️ Key Components

- **GitHub**: Source control & workflow automation with GitHub Actions
- **Node.js**: Application runtime environment
- **AWS EC2**: Cloud hosting infrastructure
- **SSH**: Secure deployment mechanism
- **PM2**: Process management for Node.js applications

## 🏆 Key Achievements

- **Automated Deployment**: Eliminates manual steps, reducing errors and increasing speed
- **Faster Feedback Loop**: Code changes are tested and deployed rapidly
- **Improved Reliability**: Consistent, repeatable deployment process with automated testing
- **Secure Credential Management**: Utilized GitHub Secrets for sensitive information
- **Foundation for Scalability**: Environment configuration ensures consistent runtime and process management

## 📊 Technical Implementation

The CI/CD pipeline follows these steps:

1. **Trigger**: Code changes pushed to the main branch start the GitHub Actions workflow
2. **Test**: Automated tests run in a controlled environment
3. **Build**: Application is built for production
4. **Deploy**: Secure SSH connection transfers code to AWS EC2
5. **Run**: PM2 starts or restarts the application with health checks

## 📱 Demo & Usage

- 🔗 [Live Demo](https://your-demo-url-here.com)
- 📝 [Step-by-Step Tutorial](tutorial.html)

## 🚀 Getting Started

To set up a similar pipeline:

```bash
# Clone this repository
git clone https://github.com/yourusername/cicd-portfolio.git

# Configure GitHub Secrets for your project
# - AWS_EC2_SSH_KEY
# - AWS_HOST_DNS
# - AWS_USERNAME

# Push to your repository to trigger the pipeline
git push origin main
```

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 📬 Contact

For questions or feedback about this CI/CD implementation, please reach out through [GitHub Issues](https://github.com/PantelisTsagkas/cicd-portfolio/issues).

---

<div align="center">
  <sub>Built with ❤️ showcasing modern deployment automation</sub>
</div>
