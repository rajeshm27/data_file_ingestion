resource "aws_dynamodb_table" "data_audit_table_tf" {
  name           = "data_audit_table_tf"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "PK"
  range_key      = "SK"
  attribute {
    name = "PK"
    type = "S"
  }
  attribute {
    name = "SK"
    type = "S"
  }
}

data "aws_iam_policy_document" "dynamodb_policy" {
  statement {
    effect = "Allow"
    actions = [
      "dynamodb:*",
    ]

     resources = ["*"]
  }
}

resource "aws_iam_role_policy" "dynamodb_policy_tf" {
  name   = "dynamodb_policy_tf"
  policy = data.aws_iam_policy_document.dynamodb_policy.json
  role   = aws_iam_role.iam_for_lambda.name
}