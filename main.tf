provider "aws" {
  region = "us-west-2"  # Update with your desired AWS region
}

resource "aws_cloudwatch_event_rule" "start_instances_rule" {
  name                = "start_instances_rule"
  description         = "Rule to trigger Lambda function for starting instances"
  schedule_expression = "cron(0 8 * * ? *)"  # Update your desired start time (GMT)
}

resource "aws_cloudwatch_event_rule" "stop_instances_rule" {
  name                = "stop_instances_rule"
  description         = "Rule to trigger Lambda function for stopping instances"
  schedule_expression = "cron(0 20 * * ? *)"  # Update your desired stop time (GMT)
}

resource "aws_lambda_function" "start_instances_lambda" {    # Start Lambda function Deployment
  filename      = "lambda/start_instances.py"
  function_name = "start_instances_lambda"
  role          = aws_iam_role.lambda_execution_role.arn
  handler       = "start_instances.lambda_handler"
  runtime       = "python3.8"
}

resource "aws_lambda_function" "stop_instances_lambda" {      # Stop Lambda function Deployment
  filename      = "lambda/stop_instances.py"
  function_name = "stop_instances_lambda"
  role          = aws_iam_role.lambda_execution_role.arn
  handler       = "stop_instances.lambda_handler"
  runtime       = "python3.8"
}

resource "aws_cloudwatch_event_target" "start_instances_target" {       # Creating Cloud Watch event to trigger Start Lambda Function
  rule      = aws_cloudwatch_event_rule.start_instances_rule.name
  target_id = aws_lambda_function.start_instances_lambda.function_name
  arn       = aws_lambda_function.start_instances_lambda.arn
}

resource "aws_cloudwatch_event_target" "stop_instances_target" {        # Creating Cloud Watch evennt to trigger Stop Lambda Function
  rule      = aws_cloudwatch_event_rule.stop_instances_rule.name
  target_id = aws_lambda_function.stop_instances_lambda.function_name
  arn       = aws_lambda_function.stop_instances_lambda.arn
}

resource "aws_iam_role" "lambda_execution_role" {
  name = "lambda_execution_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "lambda_policy" {
  name        = "lambda_policy"
  description = "Permissions for Lambda functions to start and stop EC2 instances"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "EC2Permissions",
      "Effect": "Allow",
      "Action": [
        "ec2:StartInstances",
        "ec2:StopInstances",
        "ec2:DescribeInstances"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}
