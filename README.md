# Demo re:Invent 2020

- [Demo re:Invent 2020](#demo-reinvent-2020)
  - [Demo re:Invent](#demo-reinvent)
  - [MacOS Screens](#macos-screens)
  - [Preparation](#preparation)
  - [Malware Downloads](#malware-downloads)
  - [Demoing with Tags](#demoing-with-tags)
  - [Query Logs](#query-logs)
  - [Clean Up](#clean-up)

## Demo re:Invent

*C1 = The worlds leading security services platform for all organizations builind in the cloud*

S3 scanning in AWS

1. Management and shortly Operations on Cloud One
   1. Simplicity
   2. Files never leave the AWS Account
   3. Straight forward integration into own services
2. Architecture
3. Performance
4. Demo
   1. S3 scanning in AWS
   2. Done via Cloud Formation Template
   3. Deployed from the C1 FSS console  
      Show:
      1. Deploy
      2. In the template, the only optional change you need to make is to define your temporary ingress bucket for all new files
   4. The template also creates a SNS topic which you can watch for the result of the file scan
   5. Show S3 Buckets
   6. Cloud9
      1. `. ./setup.sh`
      2. `for i in * ; do aws s3 cp $i s3://${SCANNING_BUCKET}/$i ; done`
   7. MCS
      1. `. ./setup.sh`
      2. `./tags.sh`
      3. `./postscanaction-logs.sh`
      4. `./scanner-logs.sh`
   8. Emails

## MacOS Screens

1. Browser
   1. Cloud One FSS
   2. Cloud9 with malicious files
2. Architecture and Scan Times
3. iTerm with authenticated terminal to AWS (Fontsize 20)
4. Mail filtered to `C1FSS Malware Detection`

## Preparation

```sh
./setup.sh
```

or

```sh
export REGION=us-east-1
export SCANNING_BUCKET=filestoragesecurity-scanning-bucket-a5sck3lb
export PROMOTE_BUCKET=filestoragesecurity-promote-bucket-lfnfoiak
export QUARANTINE_BUCKET=filestoragesecurity-quarantine-bucket-x0g3d5fu
```

```sh
cd ./files2scan
for i in * ; do aws s3 cp $i s3://${SCANNING_BUCKET}/$i ; done
```

## Malware Downloads

**!!! ATTENTION: REAL MALWARE !!!**

- [Gen:Variant.Strictor.171520](https://s3.eu-central-1.amazonaws.com/dasmalwerk/downloads/c0242d686b4c1707f9db2eb5afdd306507ceb5637d72662dff56c439330dbdf1/c0242d686b4c1707f9db2eb5afdd306507ceb5637d72662dff56c439330dbdf1.zip)

- [Adware ( 004f7c2e1 )](https://s3.eu-central-1.amazonaws.com/dasmalwerk/downloads/37ea273266aa2d28430194fca27849170d609d338abc9c6c43c4e6be1bcf51f9/37ea273266aa2d28430194fca27849170d609d338abc9c6c43c4e6be1bcf51f9.zip)

Password: `infected`

**!!! ATTENTION: REAL MALWARE !!!**

## Demoing with Tags

```sh
./tags.sh
```

or

```sh
echo "aws s3api get-object-tagging --bucket ${QUARANTINE_BUCKET} --key eicarcom2.zip | jq -r '.TagSet'"
aws s3api get-object-tagging --bucket ${QUARANTINE_BUCKET} --key eicarcom2.zip | jq -r '.TagSet'

echo
echo "aws s3api get-object-tagging --bucket ${PROMOTE_BUCKET} --key handler.py | jq -r '.TagSet'"
aws s3api get-object-tagging --bucket ${PROMOTE_BUCKET} --key handler.py | jq -r '.TagSet'
```

## Query Logs

Let's query the scan results.

```sh
./postscanaction-logs.sh
```

or

```sh
# PostScanAction Logs
LOGGROUP_PSA=$(aws logs describe-log-groups --region ${REGION} | \
  jq -r '.logGroups[] | select(.logGroupName | contains("PostScanAction")) | .logGroupName')

# LOGSTREAM_PSA=$(aws logs describe-log-streams --region ${REGION} --log-group-name ${LOGGROUP_PSA} | \
#   jq -r '.logStreams | sort_by(.lastEventTimestamp)[-1].logStreamName')

LOGSTREAMS_PSA=$(aws logs describe-log-streams --region ${REGION} --log-group-name ${LOGGROUP_PSA} | \
  jq -r '.logStreams[] | select(.logStreamName | startswith("2020/12/01")) | .logStreamName')

for ls in ${LOGSTREAMS_PSA} ; do
  echo "aws logs get-log-events --region ${REGION} --log-group-name ${LOGGROUP_PSA} --log-stream-name $ls"
  aws logs get-log-events --region ${REGION} --log-group-name ${LOGGROUP_PSA} --log-stream-name $ls | \
    jq -r '.events[].message' | grep Findings | jq .
done
```

If you are interested on the total time spent to scan the files, we need to dig into a different log group, which you can identify with the "ScannerLambda" within its name.

```sh
./scanner-logs.sh
```

or

```sh
# Scanner Logs
LOGGROUP_SL=$(aws logs describe-log-groups --region ${REGION} | \
  jq -r '.logGroups[] | select(.logGroupName | contains("ScannerLambda")) | .logGroupName')

# LOGSTREAM_SL=$(aws logs describe-log-streams --region ${REGION} --log-group-name ${LOGGROUP_SL} | \
#   jq -r '.logStreams | sort_by(.lastEventTimestamp)[-1].logStreamName')

LOGSTREAMS_SL=$(aws logs describe-log-streams --region ${REGION} --log-group-name ${LOGGROUP_SL} | \
  jq -r '.logStreams[] | select(.logStreamName | startswith("2020/12/01")) | .logStreamName')

for ls in ${LOGSTREAMS_SL} ; do
  echo "aws logs get-log-events --region ${REGION} --log-group-name ${LOGGROUP_SL} --log-stream-name $ls"
  aws logs get-log-events --region ${REGION} --log-group-name ${LOGGROUP_SL} --log-stream-name $ls | \
    jq -r '.events[] | select(.message | startswith("scan context") or startswith("scanner result") ) | .message' | \
    sed -e 's/^scan\scontext:\s//' | sed -e 's/^scanner\sresult:\s//' | jq .
done
```

## Clean Up

```sh
./cleanup.sh
```

or

```sh
for i in $(aws s3api list-objects --bucket ${SCANNING_BUCKET} | jq -r '.Contents[].Key') ; do \
  aws s3api delete-object --bucket ${SCANNING_BUCKET} --key $i && echo file deleted $i ; done
for i in $(aws s3api list-objects --bucket ${QUARANTINE_BUCKET} | jq -r '.Contents[].Key') ; do \
  aws s3api delete-object --bucket ${QUARANTINE_BUCKET} --key $i && echo file deleted $i ; done
for i in $(aws s3api list-objects --bucket ${PROMOTE_BUCKET} | jq -r '.Contents[].Key') ; do \
  aws s3api delete-object --bucket ${PROMOTE_BUCKET} --key $i && echo file deleted $i ; done
```
