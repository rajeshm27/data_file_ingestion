from datetime import datetime
import boto3
import json
import os
import logging


current_date = datetime.now() 
year = current_date.year
month = current_date.month
day = current_date.day

code_bucket = os.environ['codebucket']
print(code_bucket)
sns_envmt = os.environ['sns_topic_notifications']

s3 = boto3.resource('s3')
s3_client=boto3.client('s3')
sns_client = boto3.client('sns')

logging.basicConfig(
    level=logging.INFO, 
    format='%(asctime)s %(levelname)s %(message)s')

log = logging.getLogger("Rajesh-Ingest-Raw")

log.setLevel(logging.INFO)

def publish_sns_message(message, subject):
    try:
        response = sns_client.publish(
            TopicArn=sns_envmt,
            Message=message,
            Subject=subject,
        )
        log.info("SNS message published successfully.")
    except Exception as e:
        log.exception(f"Error occurred while publishing SNS message: {e}")

def lambda_handler(event, context):
    try:
        data_set = event.get("dataset")
        log.info(f"{data_set} This is my key")
        response = s3_client.get_object(Bucket=code_bucket, Key=f"{data_set}/config/ingest_config.json")
        log.info("This step was successful")
    except Exception as e:
        log.exception(f"error occured {e}")
        publish_sns_message('Error occurred while retrieving object', 'Error')
        return {
            'statusCode': 500,
            'body': 'Error occurred while retrieving object'
        }
    
    try:
        config_data = response.get('Body').read().decode('utf-8')
        config_json = json.loads(config_data)
        source_bucket = config_json.get('source_bucket')
        source_folder = config_json.get('source_folder')
        target_bucket = config_json.get('target_bucket')
        log.info(source_bucket)
    except Exception as e:
        log.exception(f"Error occurred while processing configuration: {e}")
        publish_sns_message("Error occurred while processing configuration", "Error")
        return {
            'statusCode': 500,
            'body': 'Error occurred while processing configuration'
        }
 
    try:
        response = s3_client.list_objects_v2(Bucket=source_bucket)
        log.info(response)

        file_list = []

        for obj in response['Contents']:
            file_name = obj['Key']
            file_name = file_name.replace(source_folder + '/', '')
            file_list.append(file_name)
        
        pipeline_test = config_json['pipeline']
        
        data_asset_list = []
        raw_partition_list = []
        file_pattern_list = []
        file_type_list = []
        
        for pipeline_obj in pipeline_test:
            data_asset = pipeline_obj['data_asset']
            data_asset_list.append(data_asset)
            raw_partition = pipeline_obj['raw']['partition']
            raw_partition_list.append(raw_partition)
            file_pattern = pipeline_obj['raw']['file_pattern']
            file_pattern_list.append(file_pattern)
            file_type = pipeline_obj['raw']['file_type']
            file_type_list.append(file_type)
            
            log.info(f"Data Asset: {data_asset_list}")
            log.info(f"Raw Partition: {raw_partition_list}")
            log.info(f"File Pattern: {file_pattern_list}")
            log.info(f"File Type: {file_type_list}")
            
            
        for file_name in file_list:
            log.info(file_name)
            for i, file_pattern in enumerate(file_pattern_list):
                if file_name.find(file_pattern) != -1:
           
                    otherkey = f"{source_folder}/{file_pattern}/{file_pattern}_{current_date}.{file_type_list[i]}"
                    if raw_partition_list[i].upper() == "YEAR":
                        otherkey = f"{source_folder}/{file_pattern}/year={year}/{file_pattern}_{current_date}.{file_type_list[i]}"
                    elif raw_partition_list[i].upper() == "MONTH":
                        otherkey = f"{source_folder}/{file_pattern}/year={year}/month={month}/{file_pattern}_{current_date}.{file_type_list[i]}"
                    elif raw_partition_list[i].upper() == "DAY":
                        otherkey = f"{source_folder}/{file_pattern}/year={year}/month={month}/day={day}/{file_pattern}_{current_date}.{file_type_list[i]}"
                    
                    log.info(otherkey)
                    
                    copy_source = {
                        'Bucket': source_bucket,
                        'Key': f"{source_folder}/{file_name}" 
                    }
                    log.info (copy_source)
                    bucket = s3.Bucket(target_bucket)
                    bucket.copy(copy_source, otherkey)

    except Exception as e:
        log.exception(f"Error occurred during file processing: {e}")
        publish_sns_message("Error occurred during file processing", "Error")
        return {
            'statusCode': 500,
            'body': 'Error occurred during file processing'
        }
        
    response = sns_client.publish(
        TopicArn=sns_envmt,
        Message='Successfully Ingested Raw Data',
        Subject='Ingest Raw Data',)
        
    return {
    'statusCode': 200,
    'body': json.dumps(otherkey)
             
        }