#THIS IS MY ROOT MODULE!!

module "infra" {
  source               = "./modules/infra"
  vpc_cider            = var.vpc_cidr
  num_frontend_subnets = var.num_frontend_subnets
  num_backend_subnets  = var.num_backend_subnets
  num_db_subnets       = var.num_db_subnets
  db_password          = var.db_password
  db_username          = var.db_username
  image_name           = var.image_name
  app_name             = var.app_name
  # execution_role_arn   = var.execution_role_arn
  execution_role_arn  = module.infra.execution_role_arn 
  ecr_repository_name  = var.ecr_repository_name

}

#If i have time i will create this app module as well
module "app" {
  source               = "./modules/app"
  image_name           = var.image_name
  app_name             = var.app_name
  execution_role_arn  = module.infra.execution_role_arn
  ecr_repository_name  = var.ecr_repository_name
}