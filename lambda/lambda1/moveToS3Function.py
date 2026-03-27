import json
import boto3
import urllib.parse

s3 = boto3.client('s3')

def lambda_handler(event, context):

    print("EVENT:", json.dumps(event))

    source_bucket = event['Records'][0]['s3']['bucket']['name']
    object_key = urllib.parse.unquote_plus(event['Records'][0]['s3']['object']['key'])

    destination_bucket = "espoir-bucket-middle"

    copy_source = {
        'Bucket': source_bucket,
        'Key': object_key
    }

    s3.copy_object(
        Bucket=destination_bucket,
        Key=object_key,
        CopySource=copy_source
    )

    print("Copy done")

    s3.delete_object(
        Bucket=source_bucket,
        Key=object_key
    )

    print("Delete done")
