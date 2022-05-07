resource "aws_apprunner_service" "apprunner_service" {
  service_name = "rails-apprunner"

  source_configuration {
    authentication_configuration {
      access_role_arn = aws_iam_role.apprunner_role.arn
    }
    image_repository {
      image_configuration {
        port = "3000"
        start_command = "bundle exec rails s -b 0.0.0.0"
      }
      image_identifier      = "${aws_ecr_repository.ecr_image_repository.repository_url}:latest"
      image_repository_type = "ECR"
    }
  }

  tags = {
    Name = "rails-apprunner"
  }
}