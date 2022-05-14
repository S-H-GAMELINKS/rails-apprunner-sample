resource "aws_ecr_repository" "ecr_image_repository" {
  name                 = "rails-apprunner"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "null_resource" "default" {
  provisioner "local-exec" {
    command = "$(aws ecr get-login --no-include-email --region us-east-2)"
  }

  provisioner "local-exec" {
    command = "docker build -t rails-apprunner ../"
  }

  provisioner "local-exec" {
    command = "docker tag rails-apprunner:latest ${aws_ecr_repository.ecr_image_repository.repository_url}"
  }

  provisioner "local-exec" {
    command = "docker push ${aws_ecr_repository.ecr_image_repository.repository_url}"
  }

  depends_on = [
    aws_ecr_repository.ecr_image_repository
  ]
}