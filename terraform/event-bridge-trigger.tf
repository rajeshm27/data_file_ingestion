#resource "aws_s3_bucket" "rajesh-indv-movielens-source-dataset-tf-test" {
  #bucket = "rajesh-indv-movielens-source-dataset-tf-test"
  
  #acl    = "private"


#resource "aws_s3_bucket" "rajesh-indv-movielens-raw-dataset-tf-test" {
  #bucket = "rajesh-indv-movielens-raw-dataset-tf-test"
 
  #acl    = "private"



resource "aws_cloudwatch_event_rule" "lambda_trigger" {
  name        = "nightly_lambda_trigger"
  description = "Trigger Lambda function every night at 8 PM"

  schedule_expression = "cron(05 20 * * ? *)"  # Cron expression for 8 PM every day

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

# resource "aws_lambda_invocation" "lambda_invocation" {
#   function_name = "ingest-movielens-raw"
#   input         = "{\"dataset\":\"movielens\"}"
# }
