#!/bin/bash

MALWARE=eicarcom2.zip
CLEAN=handler.py

echo "aws s3api get-object-tagging --bucket ${QUARANTINE_BUCKET} --key eicarcom2.zip | jq -r '.TagSet'"
aws s3api get-object-tagging --bucket ${QUARANTINE_BUCKET} --key ${MALWARE} | jq -r '.TagSet'

echo
echo "aws s3api get-object-tagging --bucket ${PROMOTE_BUCKET} --key handler.py | jq -r '.TagSet'"
aws s3api get-object-tagging --bucket ${PROMOTE_BUCKET} --key ${CLEAN} | jq -r '.TagSet'
