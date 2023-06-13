data "aws_iam_policy_document" "eb_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "eb_policy_document" {


  statement {
    effect = "Allow"

    actions = [
      "states:*"
    ]

    resources = [
    aws_sfn_state_machine.sfn_state_machine.arn
    ]
  }
}


resource "aws_iam_role" "event_bridge_role"{
  name = "event_bridge_role"
  assume_role_policy = data.aws_iam_policy_document.eb_assume_role.json
}

resource "aws_iam_role_policy" "eb_role_policy" {
  name = "eb_role_policy"
  policy = data.aws_iam_policy_document.eb_policy_document.json
  #role   = aws_iam_policy_document.eb_assume_role.arn
  role = aws_iam_role.event_bridge_role.name
}
  


resource "aws_iam_role" "state_machine_role" {
  name               = "state_machine_role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "states.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_sfn_state_machine" "sfn_state_machine" {
  name       = "file-ingestion"
  role_arn   = aws_iam_role.state_machine_role.arn
  definition = <<EOF
{
  "Comment": "A description of my state machine",
  "StartAt": "Lambda Invoke",
  "States": {
    "Lambda Invoke": {
      "Type": "Task",
      "Resource": "arn:aws:states:::lambda:invoke",
      "OutputPath": "$.Payload",
      "Parameters": {
        "Payload.$": "$",
        "FunctionName": "arn:aws:lambda:us-east-2:867838412845:function:ingest-movielens-raw:$LATEST"
      },
      "Retry": [
        {
          "ErrorEquals": [
            "Lambda.ServiceException",
            "Lambda.AWSLambdaException",
            "Lambda.SdkClientException",
            "Lambda.TooManyRequestsException"
          ],
          "IntervalSeconds": 2,
          "MaxAttempts": 6,
          "BackoffRate": 2
        }
      ],
      "End": true
    }
  }
}
EOF
}

resource "aws_iam_role_policy" "lambda-execution" {
  name = "lambda-execution"
  role = aws_iam_role.state_machine_role.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "lambda:*",
        "states:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}


resource "aws_iam_role_policy" "lambda_step_function" {
  name   = "ingestion_lambda_step_funtion"
  policy = data.aws_iam_policy_document.eb_policy_document.json
  role   = aws_iam_role.state_machine_role.id
}