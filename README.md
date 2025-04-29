# Node.js CI/CD Pipeline

This repository contains a reusable CI/CD pipeline for Node.js applications. The pipeline is designed to build, test, and deploy Node.js applications to AWS ECS.

## Table of Contents

- [Features](#features)
- [Repository Structure](#repository-structure)
- [Getting Started](#getting-started)
- [CI/CD Pipeline](#cicd-pipeline)
- [Docker Image](#docker-image)
- [AWS Deployment](#aws-deployment)
- [Customization](#customization)
- [Best Practices](#best-practices)
- [Troubleshooting](#troubleshooting)

## Features

- **Reusable Workflows**: Modular GitHub Actions workflows that can be reused across projects
- **Multi-Environment Support**: Configurable deployment to development, staging, and production environments
- **Automated Testing**: Unit tests, integration tests, and security scans
- **Docker Integration**: Automated Docker image building and pushing to Amazon ECR
- **AWS ECS Deployment**: Deployment to AWS ECS with task definition updates
- **Security Scanning**: Dependency vulnerability scanning and Docker image scanning

## Repository Structure

```
.
├── .github/
│   └── workflows/
│       ├── nodejs-cicd-pipeline.yml    # Reusable Node.js CI/CD workflow
│       ├── docker-build-push.yml       # Reusable Docker build and push workflow
│       ├── app-cicd.yml                # Example application workflow
│       └── README.md                   # Workflow documentation
├── Dockerfile                          # Docker image definition
├── package.json                        # Node.js application configuration
├── task-definition.json                # AWS ECS task definition
└── README.md                           # This file
```

## Getting Started

### Prerequisites

- GitHub account
- AWS account with appropriate permissions
- Node.js and npm installed locally for development

### Setup

1. **Clone this repository**:
   ```bash
   git clone https://github.com/yourusername/nodejs-cicd-pipeline.git
   cd nodejs-cicd-pipeline
   ```

2. **Configure GitHub Secrets**:
   - `AWS_ACCESS_KEY_ID`: Your AWS access key ID
   - `AWS_SECRET_ACCESS_KEY`: Your AWS secret access key
   - `AWS_REGION`: Your AWS region (e.g., `us-west-2`)

3. **Configure AWS Resources**:
   - Create an ECR repository for your Docker images
   - Set up ECS clusters for your environments (dev, staging, prod)
   - Configure appropriate IAM roles and permissions

4. **Update Configuration Files**:
   - Update `task-definition.json` with your specific configuration
   - Update workflow files with your specific repository and resource names

## CI/CD Pipeline

The CI/CD pipeline consists of the following stages:

1. **Build**: Installs dependencies, runs linting, and builds the application
2. **Test**: Runs unit tests and generates test coverage reports
3. **Security Scan**: Performs security vulnerability scanning of dependencies
4. **Docker Build**: Builds and pushes a Docker image to Amazon ECR
5. **Deployment**: Updates ECS task definitions and deploys to the appropriate environment

### Pipeline Workflow

```
Build → Test → Security Scan → Docker Build → Deploy
```

### Triggering the Pipeline

The pipeline can be triggered in several ways:

- **Push to Main Branch**: Triggers deployment to production
- **Push to Develop Branch**: Triggers deployment to staging
- **Pull Request**: Runs build and tests without deployment
- **Manual Trigger**: Can be triggered manually with specific environment selection

## Docker Image

The Docker image is built using a multi-stage build process:

1. **Build Stage**: Installs dependencies, runs tests, and builds the application
2. **Production Stage**: Creates a minimal production image with only the necessary files

### Building Locally

To build the Docker image locally:

```bash
docker build -t nodejs-app:local .
```

## AWS Deployment

The application is deployed to AWS ECS using the following process:

1. Docker image is built and pushed to Amazon ECR
2. ECS task definition is updated with the new image
3. ECS service is updated to use the new task definition

### Environment Configuration

The pipeline supports multiple environments:

- **Development**: For development and testing
- **Staging**: For pre-production testing
- **Production**: For live production deployment

Each environment has its own ECS cluster and service.

## Customization

### Workflow Inputs

The reusable workflows accept various inputs to customize their behavior:

- `node-version`: Node.js version to use
- `environment`: Environment to deploy to
- `run-lint`: Whether to run linting
- `run-tests`: Whether to run tests
- `build-command`: Custom build command
- `test-command`: Custom test command
- `artifact-path`: Path to artifacts to upload

### Adding Custom Steps

To add custom steps to the workflow, you can modify the workflow files or create new workflows that call the reusable workflows.

## Best Practices

1. **Branch Protection**: Set up branch protection rules for your main and develop branches to require status checks to pass before merging.

2. **Environment Protection**: Configure required reviewers for staging and production environments to ensure proper approval before deployment.

3. **Secrets Management**: Store sensitive information like API keys and credentials as GitHub secrets, not in your code.

4. **Test Coverage**: Aim for high test coverage to ensure your application is well-tested before deployment.

5. **Monitoring**: Set up proper monitoring and alerting for your application in production.

## Troubleshooting

### Common Issues

1. **Workflow Failures**:
   - Check the workflow run logs for detailed error messages
   - Ensure all required secrets are properly configured
   - Verify that your application's build and test commands are correct

2. **Deployment Failures**:
   - Check that your AWS credentials have the necessary permissions
   - Verify that your ECS cluster and service exist and are properly configured
   - Check that your task definition is valid

### Getting Help

If you encounter issues with the pipeline, please:

1. Check the documentation in this repository
2. Review the GitHub Actions and AWS ECS documentation
3. Open an issue in this repository with detailed information about the problem