resource "aws_iam_role" "apprunner-service-role" {
  name               = "rails-apprunner-service-role"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.apprunner-service-assume-policy.json
}

data "aws_iam_policy_document" "apprunner-service-assume-policy" {
  statement {
    actions = ["sts:AssumeRole"]
    effect = "Allow"
    sid = ""

    principals {
      type        = "Service"
      identifiers = [
        "tasks.apprunner.amazonaws.com",
        "build.apprunner.amazonaws.com"
      ]
    }
  }
}

resource "aws_iam_role_policy_attachment" "apprunner-service-role-attachment" {
  role       = aws_iam_role.apprunner-service-role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSAppRunnerServicePolicyForECRAccess"
}
