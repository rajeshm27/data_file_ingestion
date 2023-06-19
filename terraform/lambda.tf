data "archive_file" "lambda" {
  type        = "zip"
  source_file = "/Users/rajesh/Documents/Projects/data_file_ingestion/src/ingestion_lambda_function/ingestion-raw.py"
  output_path = "/Users/rajesh/Documents/Projects/data_file_ingestion/src/ingestion_lambda_function/ingestion-raw.zip"

# depends_on = [ local_file.ingestion-raw]
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
      sns_topic_notifications = aws_sns_topic.creating_topic.arn
    }
  }
}

# data "template_file" "config_template" {
#   template = file("${path.module}/../src/ingestion_lambda_function/ingestion-raw.py.template")
#   vars = {
#     region = var.aws_region
#     account_id = var.account_id
#   }
# }

# output "rendered_config" {
#   value = data.template_file.config_template.rendered
# }

# resource "local_file" "ingestion-raw" {
#   content  = data.template_file.config_template.rendered
#   filename = "${path.module}/../src/ingestion_lambda_function/ingestion-raw.py.template"
# }