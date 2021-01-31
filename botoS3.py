#! /usr/local/bin/python3
import logging
import boto3
from botocore.exceptions import ClientError


def create_bucket(bucket_name, region=None):
    s3 = boto3.resource('s3')
    try:
        if not region:
            s3_client = boto3.client('s3')
            if s3.Bucket(bucket_name) not in s3.buckets.all():
                s3_client.create_bucket(Bucket=bucket_name)
        else:
            s3_client = boto3.client('s3', region_name=region)
            location = {'LocationConstraint': region}
            if s3.Bucket(bucket_name) not in s3.buckets.all():
                s3_client.create_bucket(Bucket=bucket_name, CreateBucketConfiguration=location)
    except ClientError as e:
        logging.error(e)
        return False
    return True


def list_buckets():
    s3_client = boto3.client('s3')
    response = s3_client.list_buckets()

    for bucket in response['Buckets']:
        print(bucket['Name'])


def upload_file(file_name, bucket, object_name=None):
    # If S3 object_name was not specified, use file_name
    if object_name is None:
        object_name = file_name

    # Upload the file
    s3_client = boto3.client('s3')
    try:
        response = s3_client.upload_file(file_name, bucket, object_name)
    except ClientError as e:
        logging.error(e)
        return False
    return True


def download_file(bucket, file_name, object_name=None):
    if object_name is None:
        object_name = file_name

    s3_client = boto3.client('s3')
    try:
        response = s3_client.download_file(bucket, object_name, file_name)
    except ClientError as e:
        logging.error(e)
        return False
    return True


list_buckets()
create_bucket('samirsharan', 'us-east-2')
list_buckets()
upload_file('text.txt', 'samirsharan')
#download_file('samirsharan', 'text.txt')
