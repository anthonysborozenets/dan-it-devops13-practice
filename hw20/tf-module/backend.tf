terraform {
  backend "s3" {
    bucket = "terraform-state-danit-devops-anthonysborozenets"
    key    = "anthonysborozenets/terraform.tfstate"
    region = "eu-central-1"
  }
}
