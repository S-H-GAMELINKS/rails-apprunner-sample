resource "aws_db_subnet_group" "db-subnet-grp" {
  name        = "rails-apprunner-db-sgrp"
  description = "Database Subnet Group"
  subnet_ids  = aws_subnet.public.*.id
}

resource "aws_db_instance" "db" {
  identifier              = "postgres"
  allocated_storage       = 5
  engine                  = "postgres"
  engine_version          = "12"
  port                    = "5432"
  instance_class          = "db.t3.micro"
  db_name                 = "postgres"
  username                = "postgres"
  password                = "postgres"
  availability_zone       = "us-east-2a"
  vpc_security_group_ids  = [aws_security_group.db-sg.id]
  multi_az                = false
  db_subnet_group_name    = aws_db_subnet_group.db-subnet-grp.id
  publicly_accessible     = true
  skip_final_snapshot     = true
  backup_retention_period = 0

  tags = {
    Name = "rails-apprunner-db"
  }
}