import boto3
import pprint
import sys
from tabulate import tabulate
#import pandas as pd

def lambda_handler(event, context):
    s3_client = boto3.client("s3",region_name="eu-west-2")
    s3control_client = boto3.client("s3control",region_name="eu-west-2")
    account_id = boto3.client("sts",region_name="eu-west-2").get_caller_identity()["Account"]
    
    buckets = s3_client.list_buckets()["Buckets"]
    
    if not buckets:
        print("No buckets found")
        return {"Message": "No buckets found"}
    
    untagged_buckets = []
    missing_tags_buckets = []

    required_tags = {"Created_By", "Creator", "Repository", "Resource_type", "Name", "Name_Global", "Module" ,"Component" }
    print(f"Required tags: {required_tags}")
    print("")
    print("              s3_Bucket_Name                       ||",     "Module_Name||"  ,    "Components ||",   "   Missing Tags ")
    print("----------------------------------------------------------------------------------------------------------------------")
    for bucket in buckets:
        bucket_name = bucket["Name"]
        try:
            response = s3_client.get_bucket_tagging(Bucket=bucket_name)
            tags = response.get("TagSet", [])
            tag_keys = {tag['Key'] for tag in tags}
            
            module_tag_value = next((tag['Value'] for tag in tags if tag['Key'] == 'Module'), None)
            module_tag_componentvalue = next((tag['Value'] for tag in tags if tag['Key'] == 'Component'), None)
            
           # if module_tag_value:
                #print(f"{bucket_name}: managed by {module_tag_value}")
            
            if not tags:
                untagged_buckets.append(bucket_name)
                print(f"{bucket_name}: No Tagging")
            else:
                missing_tags = required_tags - tag_keys
              
                if missing_tags:
                    missing_tags_buckets.append({
                        "BucketName": bucket_name, 
                        "MissingTags": list(missing_tags)
                    })
                 
                    ##print(f"{bucket_name} | {missing_tags} | {module_tag_value}  | {module_tag_componentvalue}")
                    print(f"{bucket_name} | {module_tag_value} | {module_tag_componentvalue}  | {missing_tags}")
                  
                else:
                    #print("s3_Bucket_Name"   ,    "Module_Name bucket used"  ,    "Components the bucket is coming from")
                    print(f"{bucket_name} | {module_tag_value}  |  {module_tag_componentvalue}" )
                    
        except s3_client.exceptions.ClientError as e:
            if e.response['Error']['Code'] == 'NoSuchTagSet':
                untagged_buckets.append(bucket_name)
                print(f"{bucket_name}: No Tagging")
            else:
                print(f"Error checking tags for bucket {bucket_name}: {e}")

if __name__ == "__main__":
    print(lambda_handler(None, None))