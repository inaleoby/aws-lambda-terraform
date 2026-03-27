import boto3
import os
from PIL import Image
from io import BytesIO

s3_client = boto3.client("s3")

def lambda_handler(event, context):
    bucket_name = event["Records"][0]["s3"]["bucket"]["name"]
    object_key = event["Records"][0]["s3"]["object"]["key"]

    file_byte_string = s3_client.get_object(Bucket=bucket_name, Key=object_key)["Body"].read()

    image = Image.open(BytesIO(file_byte_string))
    image.thumbnail((128, 128))

    buffer = BytesIO()
    image.save(buffer, "JPEG")
    buffer.seek(0)

    thumbnail_key = f"thumbnails/{os.path.basename(object_key)}"
    s3_client.put_object(Bucket="espoir-bucket-destination", Key=thumbnail_key, Body=buffer, ContentType="image/jpeg")

    return {"statusCode": 200, "body": f"Thumbnail created: {thumbnail_key}"}
