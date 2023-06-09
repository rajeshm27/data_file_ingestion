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



