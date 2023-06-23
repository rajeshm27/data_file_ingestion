# data_file_ingestion

Project Description: 
The goal of this project was to develop infrastracurre code which, when launched, will transfer data from a "source" S3 bucket to a
"raw" S3 bucket while keeping track of the transfer date, utilizing an AWS Lambda Function. This operation is a part of a larger picutre, which involves moving the data from the "raw" bucket to the staging environment, and ultimateley to the "data lake" or the "data warehouse." In practice, this process is organizing and properly structuring data for analysis. 

[Process Flow](rajesh_data_ingestion_project.png)

![Process Flow Diagram](rajesh_data_ingestion_project.png)

File Structure Details:

ingestion-raw.py:   
The code interacts with AWS services such as S3 and SNS. It retrieves a dataset from an S3 bucket, reads its configuration in JSON format, and extracts specific values from it. Then, it lists objects in another S3 bucket and processes each object according to a defined pipeline. It constructs a new key for each object based on the specified partition and file pattern, and copies the object to a target bucket. Throughout the process, the code logs information and handles exceptions. It also publishes success and error messages to an SNS topic. Finally, it returns a response indicating the success status and the constructed key.

event-bridge-trigger.tf:
The Terraform code sets up a scheduled CloudWatch Event Rule named "nightly_lambda_trigger" that triggers a Lambda function every night at 8 PM. It also configures an Event Target to invoke an Amazon Step Functions state machine with an input payload of "{ "dataset": "movielens" }".

ingest-movielens-raw-role.tf:
This Terraform code sets up IAM roles and policies for a Lambda function. It defines IAM policy documents for assuming roles, accessing CloudWatch logs, accessing S3 resources, and interacting with SNS. It creates an IAM role named "iam_for_lambda" with an assume role policy based on the "assume_role" policy document. It attaches the CloudWatch policy to the IAM role, creates an S3 policy, and attaches it to the role. Additionally, it attaches the SNS policy to the role. Finally, it creates an SNS topic named "rajesh-data-ingestion-pipeline" and subscribes an email endpoint to the topic.

state-machine-event-bridge-roles.tf:
The Terraform code sets up IAM roles and policies for EventBridge and AWS Step Functions. It creates an EventBridge role and attaches a policy, defines a Step Functions state machine with a Lambda invocation task, and assigns roles and policies for execution.

lambda.tf:
This Terraform code performs two main tasks. First, it creates a zip archive file using the "archive_file" data source. The source file is located at "/Users/rajesh/Documents/Projects/data_file_ingestion/src/ingestion_lambda_function/ingestion-raw.py", and the resulting zip file is saved at "/Users/rajesh/Documents/Projects/data_file_ingestion/src/ingestion_lambda_function/ingestion-raw.zip".

Second, it defines an AWS Lambda function using the "aws_lambda_function" resource. The function uses the previously created zip file as its deployment package. It is named "ingest-movielens-raw" and assumes the IAM role specified by the ARN of "aws_iam_role.iam_for_lambda". The handler is set to "ingestion-raw.lambda_handler", and the source code hash is derived from the archive file. The function runs on the Python 3.10 runtime with a timeout of 900 seconds. Additionally, it specifies ephemeral storage size and sets environment variables for the Lambda function, including the "codebucket" and "sns_topic_notifications" values.

Additionally, the code configures the backend to use S3 for storing the Terraform state. The S3 bucket is named "rajesh-code-tf", and a DynamoDB table named "tf_state_lock" is used for state locking. The Terraform state file is stored at the key "secure-tf/terraform_state/tf_state.json" within the bucket, and the region for the backend is set to "us-east-2".

S3.tf:
The Terraform code creates AWS S3 resources including three buckets: "rajesh-source-tf," "rajesh-raw-tf," and "rajesh-code-tf." It also uploads an object to the "rajesh-code-tf" bucket and dynamically uploads multiple objects to the "rajesh-source-tf" bucket based on local files. The code utilizes file paths, ACL settings, and calculates Etags for the objects.

providers.tf:
This Terraform code configures the AWS provider with the specified region from the variable "aws_region". It sets the required Terraform version to be at least 0.14 and defines a required provider "random" with a minimum version of 3.0.1.

variables.tf
The Terraform code defines two variables. The first variable, "aws_region," represents the desired AWS region and is set to the default value of "us-east-2." The second variable, "account_id," represents the AWS account ID and is set to the value "867838412845" by default. These variables provide flexibility and customization options when deploying infrastructure resources using Terraform.
