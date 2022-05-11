resource "aws_apprunner_service" "apprunner_service" {
  service_name = "rails-apprunner"

  source_configuration {
    authentication_configuration {
      access_role_arn = aws_iam_role.apprunner-service-role.arn
    }
    image_repository {
      image_configuration {
        port = "3000"
        start_command = "bundle exec rails db:migrate"
        runtime_environment_variables = {
          RAILS_ENV: "production",
          RAILS_HOSTS: "AppRunner HOST"
          POSTGRES_DB: "postgres"
          POSTGRES_USER: "postgres"
          POSTGRES_PASSWORD: "postgres"
          POSTGRES_HOST: aws_db_instance.db.address
        }
      }
      image_identifier      = "${aws_ecr_repository.ecr_image_repository.repository_url}:latest"
      image_repository_type = "ECR"
    }
    auto_deployments_enabled = true
  }

  network_configuration {
    egress_configuration {
      egress_type       = "VPC"
      vpc_connector_arn = aws_apprunner_vpc_connector.vpc_connector.arn
    }
  }

  tags = {
    Name = "rails-apprunner"
  }

  instance_configuration {
    instance_role_arn = aws_iam_role.apprunner-service-role.arn
  }

  depends_on = [aws_iam_role.apprunner-service-role]
}

resource "aws_apprunner_vpc_connector" "vpc_connector" {
  vpc_connector_name = "rails-apprunner-vpc-connector"
  subnets            = aws_subnet.public.*.id
  security_groups    = [aws_security_group.db-sg.id]
}