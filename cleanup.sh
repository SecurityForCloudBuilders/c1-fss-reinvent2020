#!/bin/bash

for i in $(aws s3api list-objects --bucket ${SCANNING_BUCKET} | jq -r '.Contents[].Key') ; do \
  aws s3api delete-object --bucket ${SCANNING_BUCKET} --key $i && echo file deleted $i ; done
for i in $(aws s3api list-objects --bucket ${QUARANTINE_BUCKET} | jq -r '.Contents[].Key') ; do \
  aws s3api delete-object --bucket ${QUARANTINE_BUCKET} --key $i && echo file deleted $i ; done
for i in $(aws s3api list-objects --bucket ${PROMOTE_BUCKET} | jq -r '.Contents[].Key') ; do \
  aws s3api delete-object --bucket ${PROMOTE_BUCKET} --key $i && echo file deleted $i ; done
