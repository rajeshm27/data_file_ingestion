data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

# resource "aws_iam_role" "state_machine_role" {
#   name               = "state_machine_role"
#   assume_role_policy = <<EOF
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Effect": "Allow",
#       "Principal": {
#         "Service": "states.amazonaws.com"
#       },
#       "Action": "sts:AssumeRole"
#     }
#   ]
# }
# EOF
# }

data "aws_iam_policy_document" "cloud_watch_policy" {
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = [
      "arn:aws:logs:us-east-2:867838412845:*",
      "arn:aws:logs:us-east-2:867838412845:log-group:/aws/lambda/ingest-movielens-raw:*",
    ]
  }
}


data "aws_iam_policy_document" "s3_policy" {
  statement {
    effect = "Allow"

    actions = [
      "s3:*",
      "s3-object-lambda:*",
    ]

    resources = ["*"]
  }
}

data "aws_iam_policy_document" "sns_policy" {
  statement {
    effect = "Allow"

    actions = [
      "sns:*"
    ]

    resources = [
      "*"
    ]
  }
}


resource "aws_iam_role" "iam_for_lambda" {
  name               = "iam_for_lambda"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy" "cloud_watch_policy"{
    name="cloud_watch_policy"
    policy=data.aws_iam_policy_document.cloud_watch_policy.json
    role=aws_iam_role.iam_for_lambda.name
}

resource "aws_iam_policy" "s3_policy" {
  name   = "s3_policy"
  policy = data.aws_iam_policy_document.s3_policy.json
}

resource "aws_iam_role_policy_attachment" "s3_access_policy_attachment" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.s3_policy.arn
}

# resource "aws_iam_role_policy" "lambda-execution" {
#   name = "lambda-execution"
#   role = aws_iam_role.state_machine_role.id

#   policy = <<EOF
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Action": [
#         "lambda:InvokeFunction",
#         "states:StartExecution"
#       ],
#       "Effect": "Allow",
#       "Resource": "*"
#     }
#   ]
# }
# EOF
# }

resource "aws_iam_role_policy" "sns_policy_attachment" {
  name   = "sns_policy_attachment"
  policy = data.aws_iam_policy_document.sns_policy.json
  role   = aws_iam_role.iam_for_lambda.name
}
resource "aws_sns_topic" "creating_topic" {
  name = "rajesh-data-ingestion-pipeline"
}

resource "aws_sns_topic_subscription" "user_updates_sqs_target" {
  topic_arn = aws_sns_topic.creating_topic.arn
  protocol  = "email-json"
  endpoint  = "rcmutyala@gmail.com"
}

# resource "aws_sfn_state_machine" "sfn_state_machine" {
#   name     = "ingest-movielens-raw"
#   role_arn = aws_iam_role.state_machine_role.arn

#     definition = <<EOF
# {
#   "Comment": "A description of my state machine",
#   "StartAt": "Lambda Invoke",
#   "States": {
#     "Lambda Invoke": {
#       "Type": "Task",
#       "Resource": "arn:aws:states:::lambda:invoke",
#       "OutputPath": "$.Payload",
#       "Parameters": {
#         "Payload.$": "$",
#         "FunctionName": "arn:aws:lambda:us-east-2:867838412845:function:ingest-movielens-raw:$LATEST"
#       },
#       "Retry": [
#         {
#           "ErrorEquals": [
#             "Lambda.ServiceException",
#             "Lambda.AWSLambdaException",
#             "Lambda.SdkClientException",
#             "Lambda.TooManyRequestsException"
#           ],
#           "IntervalSeconds": 2,
#           "MaxAttempts": 6,
#           "BackoffRate": 2
#         }
#       ],
#       "End": true
#     }
#   }
# }
# EOF
# }



