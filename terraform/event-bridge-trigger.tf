resource "aws_cloudwatch_event_rule" "lambda_trigger" {
  name        = "nightly_lambda_trigger"
  description = "Trigger Lambda function every night at 8 PM"

  schedule_expression = "cron(50 05 * * ? *)"  # Cron expression for 8 PM every day

  # Optionally, you can add tags to the EventBridge rule
  tags = {
    Environment = "Production"
  }
}

resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.lambda_trigger.name
  arn       = aws_sfn_state_machine.sfn_state_machine.arn
  role_arn  = aws_iam_role.event_bridge_role.arn
  target_id = aws_sfn_state_machine.sfn_state_machine.name
  input = "{\"dataset\":\"movielens\"}"
}

