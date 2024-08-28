terraform {
  backend "s3" {
    bucket = "0xkmt-devsecops-backend-codedevops"
    key    = "udacity-lab.tfstae"
    region = "ap-southeast-1"
  }
}

