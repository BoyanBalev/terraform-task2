#Its not good practice to push this file to git!!!! But to make it easier i will :)

vpc_cidr             = "10.0.0.0/16"
num_frontend_subnets = 2
num_backend_subnets  = 2
num_db_subnets       = 2

db_password = "passwort1234"
db_username = "username1234"

image_name           = "boyanbalev5/containerofcats"
app_name             = "cats"
ecr_repository_name  = "nginx"
execution_role_arn   = "arn:aws:iam::123456789012:role/my-execution-role"