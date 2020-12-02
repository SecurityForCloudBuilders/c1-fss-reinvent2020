#!/bin/bash

DATE=$(date +"%Y/%m/%d")

# Scanner Logs
LOGGROUP_SL=$(aws logs describe-log-groups --region ${REGION} | \
  jq -r '.logGroups[] | select(.logGroupName | contains("ScannerLambda")) | .logGroupName')

# LOGSTREAM_SL=$(aws logs describe-log-streams --region ${REGION} --log-group-name ${LOGGROUP_SL} | \
#   jq -r '.logStreams | sort_by(.lastEventTimestamp)[-1].logStreamName')

LOGSTREAMS_SL=$(aws logs describe-log-streams --region ${REGION} --log-group-name ${LOGGROUP_SL} | \
  jq -r --arg DATE "${DATE}" '.logStreams[] | select(.logStreamName | startswith($DATE)) | .logStreamName')

for ls in ${LOGSTREAMS_SL} ; do
  echo "aws logs get-log-events --region ${REGION} --log-group-name ${LOGGROUP_SL} --log-stream-name $ls"
  aws logs get-log-events --region ${REGION} --log-group-name ${LOGGROUP_SL} --log-stream-name $ls | \
    jq -r '.events[] | select(.message | startswith("scan context") or startswith("scanner result") ) | .message' | \
    sed -e 's/^scan\scontext:\s//' | sed -e 's/^scanner\sresult:\s//' | jq .
done
