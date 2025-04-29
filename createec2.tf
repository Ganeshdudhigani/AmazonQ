#Generate a terraform template to create an ECS instance using best practice like "code modularity" and "state management"
# provider.tf
provider "aws" {
  region = var.aws_region
}

terraform {
  backend "s3" {
    bucket         = "XXXXXXXXXXXXXXXXXXXXXX"
    key            = "ecs/terraform.tfstate"
    region         = "us-west-2"
    encrypt        = true
    dynamodb_table = "terraform-state-lock"
  }
}

# variables.tf
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-west-2"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "cluster_name" {
  description = "ECS Cluster name"
  type        = string
  default     = "ecs-cluster"
}

# modules/vpc/main.tf
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "${var.environment}-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["${var.aws_region}a", "${var.aws_region}b"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true

  tags = {
    Environment = var.environment
    Terraform   = "true"
  }
}

# modules/ecs/main.tf
resource "aws_ecs_cluster" "main" {
  name = "${var.environment}-${var.cluster_name}"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = {
    Environment = var.environment
  }
}

resource "aws_ecs_cluster_capacity_providers" "main" {
  cluster_name = aws_ecs_cluster.main.name

  capacity_providers = ["FARGATE", "FARGATE_SPOT"]

  default_capacity_provider_strategy {
    capacity_provider = "FARGATE"
    weight           = 1
    base            = 1
  }
}

# modules/security/main.tf
resource "aws_security_group" "ecs_tasks" {
  name        = "${var.environment}-ecs-tasks-sg"
  description = "Security group for ECS tasks"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Environment = var.environment
  }
}

# main.tf
module "vpc" {
  source      = "./modules/vpc"
  environment = var.environment
  aws_region  = var.aws_region
}

module "ecs" {
  source       = "./modules/ecs"
  environment  = var.environment
  cluster_name = var.cluster_name
}

module "security" {
  source      = "./modules/security"
  environment = var.environment
  vpc_id      = module.vpc.vpc_id
}

# outputs.tf
output "cluster_id" {
  description = "ECS cluster ID"
  value       = module.ecs.cluster_id
}

output "cluster_name" {
  description = "ECS cluster name"
  value       = module.ecs.cluster_name
}

output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}
#add comments to explain the logic and resourcesin the Terraform code."
# provider.tf
# Configure AWS provider with specified region
provider "aws" {
  region = var.aws_region
}

# Configure remote state storage in S3 with state locking using DynamoDB
terraform {
  backend "s3" {
    bucket         = "XXXXXXXXXXXXXXXXXXXXXX"
    key            = "ecs/terraform.tfstate"
    region         = "us-west-2"
    encrypt        = true
    dynamodb_table = "terraform-state-lock" # Table used for state locking
  }
}

# variables.tf
# Define input variables with descriptions and default values
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-west-2"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "cluster_name" {
  description = "ECS Cluster name" 
  type        = string
  default     = "ecs-cluster"
}

# modules/vpc/main.tf
# Create VPC using AWS VPC module with public and private subnets
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "${var.environment}-vpc"
  cidr = "10.0.0.0/16" # VPC CIDR block

  # Create subnets in two availability zones
  azs             = ["${var.aws_region}a", "${var.aws_region}b"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]    # Private subnet CIDR blocks
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"] # Public subnet CIDR blocks

  enable_nat_gateway = true  # Enable NAT Gateway for private subnet internet access
  single_nat_gateway = true  # Use single NAT Gateway to save costs

  tags = {
    Environment = var.environment
    Terraform   = "true"
  }
}

# modules/ecs/main.tf
# Create ECS cluster with container insights enabled
resource "aws_ecs_cluster" "main" {
  name = "${var.environment}-${var.cluster_name}"

  setting {
    name  = "containerInsights"
    value = "enabled"  # Enable CloudWatch Container Insights
  }

  tags = {
    Environment = var.environment
  }
}

# Configure cluster capacity providers to use Fargate and Fargate Spot
resource "aws_ecs_cluster_capacity_providers" "main" {
  cluster_name = aws_ecs_cluster.main.name

  capacity_providers = ["FARGATE", "FARGATE_SPOT"]

  # Set default capacity provider strategy
  default_capacity_provider_strategy {
    capacity_provider = "FARGATE"
    weight           = 1  # Higher weight means more tasks will use this provider
    base            = 1   # Minimum number of tasks to run on this provider
  }
}

# modules/security/main.tf
# Create security group for ECS tasks
resource "aws_security_group" "ecs_tasks" {
  name        = "${var.environment}-ecs-tasks-sg"
  description = "Security group for ECS tasks"
  vpc_id      = module.vpc.vpc_id

  # Allow all inbound traffic (should be restricted in production)
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Environment = var.environment
  }
}

# main.tf
# Initialize all modules with required variables
module "vpc" {
  source      = "./modules/vpc"
  environment = var.environment
  aws_region  = var.aws_region
}

module "ecs" {
  source       = "./modules/ecs"
  environment  = var.environment
  cluster_name = var.cluster_name
}

module "security" {
  source      = "./modules/security"
  environment = var.environment
  vpc_id      = module.vpc.vpc_id
}

# outputs.tf
# Define outputs to expose important resource information
output "cluster_id" {
  description = "ECS cluster ID"
  value       = module.ecs.cluster_id
}

output "cluster_name" {
  description = "ECS cluster name"
  value       = module.ecs.cluster_name
}

output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}
#"Refactor the Terraform code to follow modularity principle."
# modules/vpc/variables.tf
variable "environment" {
  description = "Environment name"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets" 
  type        = list(string)
  default     = ["10.0.101.0/24", "10.0.102.0/24"]
}

# modules/vpc/outputs.tf
output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "private_subnet_ids" {
  description = "IDs of private subnets"
  value       = module.vpc.private_subnets
}

output "public_subnet_ids" {
  description = "IDs of public subnets"
  value       = module.vpc.public_subnets
}

# modules/ecs/variables.tf
variable "environment" {
  description = "Environment name"
  type        = string
}

variable "cluster_name" {
  description = "Name of the ECS cluster"
  type        = string
}

variable "enable_container_insights" {
  description = "Enable CloudWatch Container Insights"
  type        = bool
  default     = true
}

# modules/ecs/outputs.tf
output "cluster_id" {
  description = "ID of the ECS cluster"
  value       = aws_ecs_cluster.main.id
}

output "cluster_name" {
  description = "Name of the ECS cluster"
  value       = aws_ecs_cluster.main.name
}

output "cluster_arn" {
  description = "ARN of the ECS cluster"
  value       = aws_ecs_cluster.main.arn
}

# modules/security/variables.tf
variable "environment" {
  description = "Environment name"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "allowed_cidr_blocks" {
  description = "List of CIDR blocks allowed for ingress"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

# modules/security/outputs.tf
output "security_group_id" {
  description = "ID of the ECS tasks security group"
  value       = aws_security_group.ecs_tasks.id
}

# environments/dev/main.tf
module "vpc" {
  source = "../../modules/vpc"
  
  environment          = var.environment
  aws_region          = var.aws_region
  vpc_cidr            = var.vpc_cidr
  private_subnet_cidrs = var.private_subnet_cidrs
  public_subnet_cidrs  = var.public_subnet_cidrs
}

module "ecs" {
  source = "../../modules/ecs"
  
  environment               = var.environment
  cluster_name             = var.cluster_name
  enable_container_insights = var.enable_container_insights
}

module "security" {
  source = "../../modules/security"
  
  environment         = var.environment
  vpc_id             = module.vpc.vpc_id
  allowed_cidr_blocks = var.allowed_cidr_blocks
}

# environments/dev/variables.tf
variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-west-2"
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.101.0/24", "10.0.102.0/24"]
}

variable "cluster_name" {
  description = "ECS Cluster name"
  type        = string
  default     = "ecs-cluster"
}

variable "enable_container_insights" {
  description = "Enable CloudWatch Container Insights"
  type        = bool
  default     = true
}

variable "allowed_cidr_blocks" {
  description = "List of CIDR blocks allowed for ingress"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

# environments/dev/outputs.tf
output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "cluster_id" {
  description = "ECS cluster ID"
  value       = module.ecs.cluster_id
}

output "cluster_name" {
  description = "ECS cluster name"
  value       = module.ecs.cluster_name
}

output "security_group_id" {
  description = "Security group ID"
  value       = module.security.security_group_id
}
#"Update the code to use AWS secrets manager to store sesitive data."
# modules/secrets/variables.tf
variable "environment" {
  description = "Environment name"
  type        = string
}

variable "secret_name" {
  description = "Name of the secret in Secrets Manager"
  type        = string
}

variable "secret_values" {
  description = "Map of secret key/value pairs to store"
  type        = map(string)
  sensitive   = true
}

# modules/secrets/main.tf
resource "aws_secretsmanager_secret" "app_secrets" {
  name = "${var.environment}/${var.secret_name}"
  
  tags = {
    Environment = var.environment
  }
}

resource "aws_secretsmanager_secret_version" "app_secrets" {
  secret_id     = aws_secretsmanager_secret.app_secrets.id
  secret_string = jsonencode(var.secret_values)
}

# Add IAM policy to allow ECS tasks to access secrets
resource "aws_iam_role_policy" "ecs_task_secrets" {
  name = "${var.environment}-ecs-task-secrets-policy"
  role = var.ecs_task_role_id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Resource = [aws_secretsmanager_secret.app_secrets.arn]
      }
    ]
  })
}

# modules/secrets/outputs.tf
output "secret_arn" {
  description = "ARN of the created secret"
  value       = aws_secretsmanager_secret.app_secrets.arn
}

# environments/dev/secrets.tf
module "secrets" {
  source = "../../modules/secrets"
  
  environment  = var.environment
  secret_name  = "app-secrets"
  secret_values = {
    db_password     = var.db_password
    api_key         = var.api_key
    encryption_key  = var.encryption_key
  }
}

# environments/dev/variables.tf
# Add these variables for secrets
variable "db_password" {
  description = "Database password"
  type        = string
  sensitive   = true
}

variable "api_key" {
  description = "API key"
  type        = string
  sensitive   = true
}

variable "encryption_key" {
  description = "Encryption key"
  type        = string
  sensitive   = true
}

# Example usage in ECS task definition
resource "aws_ecs_task_definition" "app" {
  # ... other configuration ...

  container_definitions = jsonencode([
    {
      name = "app"
      secrets = [
        {
          name      = "DB_PASSWORD"
          valueFrom = "${module.secrets.secret_arn}:db_password::"
        },
        {
          name      = "API_KEY"
          valueFrom = "${module.secrets.secret_arn}:api_key::"
        },
        {
          name      = "ENCRYPTION_KEY"
          valueFrom = "${module.secrets.secret_arn}:encryption_key::"
        }
      ]
    }
  ])
}
# Project Structure and File Flow:

# 1. Root Level Files
# provider.tf
# - Configures AWS provider
# - Sets up S3 backend for state management

# 2. Module Structure
# modules/
#   ├── vpc/
#   │   ├── main.tf         # VPC resource definitions
#   │   ├── variables.tf    # VPC module variables
#   │   └── outputs.tf      # VPC outputs used by other modules
#   │
#   ├── ecs/
#   │   ├── main.tf         # ECS cluster and capacity provider config
#   │   ├── variables.tf    # ECS module variables  
#   │   └── outputs.tf      # ECS cluster outputs
#   │
#   ├── security/
#   │   ├── main.tf         # Security group definitions
#   │   ├── variables.tf    # Security module variables
#   │   └── outputs.tf      # Security group outputs
#   │
#   └── secrets/
#       ├── main.tf         # Secrets Manager resources
#       ├── variables.tf    # Secrets module variables
#       └── outputs.tf      # Secret ARN outputs

# 3. Environment Configuration
# environments/
#   └── dev/
#       ├── main.tf         # Calls all modules with dev config
#       ├── variables.tf    # Environment variables
#       ├── outputs.tf      # Environment outputs
#       └── secrets.tf      # Secrets configuration

# Flow:
# 1. Provider and backend configuration loaded
# 2. Environment variables defined
# 3. VPC module creates network infrastructure
# 4. ECS module creates cluster using VPC outputs
# 5. Security module creates security groups using VPC outputs
# 6. Secrets module creates and manages sensitive data
# 7. Environment outputs expose important resource information
#"Add right-sizing autoscalling and tagging for cost tracking in the Terraform template"
# modules/ecs/variables.tf
variable "min_capacity" {
  description = "Minimum number of tasks"
  type        = number
  default     = 1
}

variable "max_capacity" {
  description = "Maximum number of tasks"
  type        = number
  default     = 10
}

variable "target_cpu_utilization" {
  description = "Target CPU utilization percentage"
  type        = number
  default     = 70
}

variable "target_memory_utilization" {
  description = "Target memory utilization percentage"
  type        = number
  default     = 70
}

variable "cost_center" {
  description = "Cost center for billing"
  type        = string
}

variable "project" {
  description = "Project name for billing"
  type        = string
}

# modules/ecs/main.tf
resource "aws_appautoscaling_target" "ecs_target" {
  max_capacity       = var.max_capacity
  min_capacity       = var.min_capacity
  resource_id        = "service/${aws_ecs_cluster.main.name}/${aws_ecs_service.main.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "ecs_cpu" {
  name               = "${var.environment}-cpu-autoscaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value = var.target_cpu_utilization
  }
}

resource "aws_appautoscaling_policy" "ecs_memory" {
  name               = "${var.environment}-memory-autoscaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }
    target_value = var.target_memory_utilization
  }
}

# Add cost allocation tags to all resources
locals {
  common_tags = {
    Environment = var.environment
    CostCenter  = var.cost_center
    Project     = var.project
    ManagedBy   = "Terraform"
  }
}

resource "aws_ecs_cluster" "main" {
  # Existing configuration
  tags = merge(local.common_tags, {
    Name = "${var.environment}-${var.cluster_name}"
  })
}

resource "aws_ecs_service" "main" {
  name            = "${var.environment}-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.main.arn
  desired_count   = var.min_capacity

  network_configuration {
    security_groups = [var.security_group_id]
    subnets         = var.private_subnet_ids
  }

  tags = merge(local.common_tags, {
    Name = "${var.environment}-ecs-service"
  })
}

# environments/dev/variables.tf
variable "cost_center" {
  description = "Cost center for billing"
  type        = string
  default     = "engineering"
}

variable "project" {
  description = "Project name for billing"
  type        = string
  default     = "ecs-application"
}

variable "min_capacity" {
  description = "Minimum number of tasks"
  type        = number
  default     = 1
}

variable "max_capacity" {
  description = "Maximum number of tasks"
  type        = number
  default     = 10
}

variable "target_cpu_utilization" {
  description = "Target CPU utilization percentage"
  type        = number
  default     = 70
}

variable "target_memory_utilization" {
  description = "Target memory utilization percentage"
  type        = number
  default     = 70
}

# environments/dev/main.tf
module "ecs" {
  source = "../../modules/ecs"
  
  environment               = var.environment
  cluster_name             = var.cluster_name
  enable_container_insights = var.enable_container_insights
  min_capacity             = var.min_capacity
  max_capacity             = var.max_capacity
  target_cpu_utilization   = var.target_cpu_utilization
  target_memory_utilization = var.target_memory_utilization
  cost_center              = var.cost_center
  project                  = var.project
  security_group_id        = module.security.security_group_id
  private_subnet_ids       = module.vpc.private_subnet_ids
}
