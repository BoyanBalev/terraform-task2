Architecture design :  <br />
I am creating a VPC, a frontend subnet which is public, and a backend and db subnets, which are private  <br />
I am deploying a Internet Gateway for the public subnet, and a NAT gateway for the backend subnet(so it can download the prebuild container from dockerhub)
I am deploying MariaDB managed database inside the db subnet
I am setting up security groups to only allow requested traffic and deny the rest
I am deploying 2 containers inside ECS in FARGATE Mode
I am configuring app auto scaling based on CPU load

The terraform code has a root(main module) which calls the infra module to setup the infrastructure and an app module to setup the container part (work in progress)


How to deploy the infrastructure and cat-container application:
Step 1: Clone the repo (for example git clone https://github.com/BoyanBalev/terraform-task2.git) into your local machine where terraform is installed
Step 2: Navigate to the aws-tf folder
Step 3: Create an S3 bucket and replace the bucket name and the region inside the backend.tf file (if using AWS CLI, use this command to create the bucket: aws s3api create-bucket --bucket your-bucket-name --region your-region)
Step 4: Setup env variables in order to authenticate to AWS. This are managed inside IAM in your AWS Account
export AWS_ACCESS_KEY_ID=your-access-key-id
export AWS_SECRET_ACCESS_KEY=your-secret-access-key
Step 5: Setup your preffered variables inside the terraform.tfvars or use the default ones i provided ( this file should not be commited to git normally)
Step 6: Run terraform init
Step 7: Run terraform plan
Step 8: Run terraform apply
