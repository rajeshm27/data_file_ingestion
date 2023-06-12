#resource "aws_s3_bucket" "rajesh-indv-movielens-source-dataset-tf-test" {
  #bucket = "rajesh-indv-movielens-source-dataset-tf-test"
  
  #acl    = "private"


#resource "aws_s3_bucket" "rajesh-indv-movielens-raw-dataset-tf-test" {
  #bucket = "rajesh-indv-movielens-raw-dataset-tf-test"
 
  #acl    = "private"



resource "aws_cloudwatch_event_rule" "lambda_trigger" {
  name        = "nightly_lambda_trigger"
  description = "Trigger Lambda function every night at 8 PM"

  schedule_expression = "cron(33 21 * * ? *)"  # Cron expression for 8 PM every day

  # Optionally, you can add tags to the EventBridge rule
  tags = {
    Environment = "Production"
  }
}

resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.lambda_trigger.name
  arn = aws_lambda_function.lambda-src-raw.arn
  target_id = "ingest-movielens-raw"
  input = "{\"dataset\":\"movielens\"}"
}
