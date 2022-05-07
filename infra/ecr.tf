resource "aws_ecr_repository" "ecr_image_repository" {
  name                 = "rails-apprunner"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}