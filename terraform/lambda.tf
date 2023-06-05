data "archive_file" "lambda" {
  type        = "zip"
  source_file = "/Users/rajeshmutyala/Documents/Projects/data_ingestion_project/src/ingestion_lambda_function/ingestion-raw.py"
  output_path = "/Users/rajeshmutyala/Documents/Projects/data_ingestion_project/src/ingestion_lambda_function/ingestion-raw.zip"
} 

resource "aws_lambda_function" "lambda-src-raw" {

  filename         = data.archive_file.lambda.output_path
  function_name    = "ingest-movielens-raw"
  role             = "${aws_iam_role.iam_for_lambda.arn}"
  handler          = "ingestion-raw.lambda_handler"

  source_code_hash = data.archive_file.lambda.output_base64sha256
  runtime          = "python3.10"
  timeout          = 900

  ephemeral_storage {
    size = 512 # Min 512 and the Max 10240 MB
  }

  environment {
    variables = {
      codebucket = "code-bucket-rajesh"
    }
  }
}