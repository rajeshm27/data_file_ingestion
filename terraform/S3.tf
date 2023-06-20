# resource "aws_s3_bucket" "rajesh-source-bucket" {
#     bucket = "rajesh-source-bucket"
#     #region =var.aws_region
#   lifecycle {
#     prevent_destroy = true
#   }
# } 

# resource "aws_s3_bucket" "rajesh-raw-bucket" {
#     bucket = "rajesh-raw-bucket"
#     #region =var.aws_region
#   lifecycle {
#     prevent_destroy = true
#   }
# } 

# resource "aws_s3_bucket" "rajesh-code-bucket" {
#     bucket = "rajesh-code-bucket"
#     #region =var.aws_region
#   lifecycle {
#     prevent_destroy = true
#   }
# }

# resource "aws_s3_object" "object" {
#   bucket = "rajesh-code-bucket"
#   key    = "movielens/config/config.json"
#   #acl = "private"
#   source = "../src/config/config.json"

#   etag = filemd5("../src/config/config.json")
# }

# resource "aws_s3_object" "process_json" {
#   bucket = "rajesh-code-bucket"
#   key    = "movielens/config/process_config.json"
#   #acl = "private"
#   source = "../src/config/process_config.json"

#   etag = filemd5("../src/config/process_config.json")
# }



resource "aws_s3_bucket" "rajesh-source-tf" {
  bucket = "rajesh-source-tf"
}

resource "aws_s3_bucket" "rajesh-raw-tf" {
  bucket = "rajesh-raw-tf"
}

resource "aws_s3_bucket" "rajesh-code-tf" {
  bucket = "rajesh-code-tf"
}

resource "aws_s3_object" "object" {
  bucket = "rajesh-code-tf"
  key    = "movielens/config/ingest_config.json"
  acl    = "private"
  source = "/Users/rajesh/Documents/Projects/data_file_ingestion/src/config/ingest_config.json"
  etag   = filemd5("/Users/rajesh/Documents/Projects/data_file_ingestion/src/config/ingest_config.json")
}

resource "aws_s3_object" "upload_objects" {
  for_each = local.config_files

  bucket = aws_s3_bucket.rajesh-source-tf.id
  key    = "/movielens_dataset/${each.value}"
  source = "/Users/rajesh/Documents/Projects/data_file_ingestion/movielens_dataset/${each.value}"

  etag = filemd5("/Users/rajesh/Documents/Projects/data_file_ingestion/movielens_dataset/${each.value}")
}

locals {
config_files = fileset("/Users/rajesh/Documents/Projects/data_file_ingestion/movielens_dataset/", "**/*.csv")
}