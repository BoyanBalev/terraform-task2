# terraform {
#   backend "local" {
#     path = "./state/terraform.tfstate"
#   }
# }

terraform {
  backend "s3" {
    bucket         = "terraform-state-flatrock-555"
    key            = "terraform.tfstate"
    region         = "eu-central-1"
    use_lockfile = true
  }
}