#! /bin/bash

#create a bucket
function createbucket {
  local bucketname=$1
  local region=$2

  echo "** Creating bucket $bucketname **"

  if [[ -z "$bucketname" ]]
  then
    echo "Error: bucketname is mandatory"
    return 1
  fi
   
  if [[ -z "$region" ]]
  then 
    echo "Error: region is mandatory"
    return 1
  fi

  if (check_bucket_exists $bucketname)
  then
    echo "Error: bucket already exists"
    return 1
  fi

  local res=`aws s3api create-bucket --bucket $bucketname --create-bucket-configuration LocationConstraint=$region`
  
  if [[ "$?" -ne 0 ]]
  then
    echo "Error: create_bucket operation failed: $res"
    return 1
  else
    echo "Bucket $bucketname created successfully !"
    return 0
  fi
}

function check_bucket_exists {
  local bucketname=$1

  echo "** Check whether bucket exisits **"

  if [[ -z "$bucketname" ]]
  then
    echo "Error: bucketname is mandatory"
    return 1
  fi
  
  aws s3api head-bucket --bucket $bucketname 2> /dev/null

  if [[ "$?" -eq 0 ]]
  then
    echo "Bucket $bucketname does exist !"
    return 0
  else
    echo "No bucket $bucketname present"
    return 1
  fi
}

function list_items_in_bucket {
  local bucketname=$1

  echo "** Listing items in bucket $bucketname **"

  if [[ -z "$bucketname" ]]
  then
    echo "Error: bucketname is mandatory"
    return 1
  fi

  local res=`aws s3api list-objects --bucket $bucketname --output text --query 'Contents[].{Key: Key, Size: Size}'`

  if [[ $? -eq 0 ]]
  then
    echo "$res"
  else
    echo "Error: performing list-objects operation\n$res"
    return 1
  fi
}

function upload_file_in_bucket {
  local bucketname=$1
  local sourcefile=$2
  local destinationfile=$3

  echo "** Uploading file $filename to bucket $bucketname **"
 
  if [[ -z "$bucketname" || -z "$sourcefile" || -z "$destinationfile" ]]
  then
    echo "Error: bucketname, sourcefile and destinationfile are mandatory"
    return 1
  fi

  local res=`aws s3api put-object --bucket $bucketname --body $sourcefile --key $destinationfile`

  if [[ "$?" -ne 0 ]]
  then
    echo "Error: uploading file in bucket $bucketname\n$res"
    return 1
  else:
    echo "Upload successful !"
    return 0
  fi
}

function delete_bucket {
  local bucketname=$1
  
  echo "** Deleting bucket **"

  if [[ -z "$bucketname" ]]
  then
    echo "Error: bucketname is mandatory"
    return 1
  fi

  aws s3api delete-bucket --bucket $bucketname

  if [[ $? -ne 0 ]]
  then
    echo "Error: deleting bucket $bucketname"
    return 1
  else
    echo "Bucket $bucketname deleted successfully !"
    return 0
  fi
 
}

function delete_item_bucket {
  local bucketname=$1
  local filename=$2

  echo "** Deleting file $filename from bucket $bucketname **"

  if [[ -z $bucketname || -z $filename ]]
  then
    echo "Error: buckername and filename are mandatory"
    return 1
  fi

  local res=`aws s3api delete-object --bucket $bucketname --key $filename`
  
  if [[ "$?" -ne 0 ]]
  then 
    echo "Error: performing delete object operation\n$res"
    return 1
  else:
    echo "File $filename delete successfully from bucket $bucketname\n"
    return 0
  fi
}

#Delete bucket if exists  
if (check_bucket_exists 'samirsharan')
then
  delete_bucket 'samirsharan'
  sleep 10
fi
#createbucket
createbucket 'samirsharan' 'us-east-2'
sleep 10
#upload a file to the bucket
upload_file_in_bucket 'samirsharan' 'test.txt' 'test.txt'
sleep 10
#list items in bucket
list_items_in_bucket 'samirsharan'
sleep 10
#delete item in bucket
delete_item_bucket 'samirsharan' 'test.txt'
sleep 10
#list items in bucket
list_items_in_bucket 'samirsharan'
sleep 10
#delete bucket
delete_bucket 'samirsharan'
sleep 10

