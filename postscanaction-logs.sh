#!/bin/bash

DATE=$(date +"%Y/%m/%d")

# PostScanAction Logs
LOGGROUP_PSA=$(aws logs describe-log-groups --region ${REGION} | \
  jq -r '.logGroups[] | select(.logGroupName | contains("PostScanAction")) | .logGroupName')

# LOGSTREAM_PSA=$(aws logs describe-log-streams --region ${REGION} --log-group-name ${LOGGROUP_PSA} | \
#   jq -r '.logStreams | sort_by(.lastEventTimestamp)[-1].logStreamName')

LOGSTREAMS_PSA=$(aws logs describe-log-streams --region ${REGION} --log-group-name ${LOGGROUP_PSA} | \
  jq -r --arg DATE "${DATE}" '.logStreams[] | select(.logStreamName | startswith($DATE)) | .logStreamName')

for ls in ${LOGSTREAMS_PSA} ; do
  echo "aws logs get-log-events --region ${REGION} --log-group-name ${LOGGROUP_PSA} --log-stream-name $ls"
  aws logs get-log-events --region ${REGION} --log-group-name ${LOGGROUP_PSA} --log-stream-name $ls | \
    jq -r '.events[].message' | grep Findings | jq .
done

